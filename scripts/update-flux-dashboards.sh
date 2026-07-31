#!/bin/bash
#
# Sync the Flux Grafana dashboards from the upstream Flux monitoring example and
# adapt them to the Giant Swarm observability platform.
#
# Source: https://github.com/fluxcd/flux2-monitoring-example
#         monitoring/configs/dashboards/{cluster,control-plane,logs}.json
#
# Usage:
#   ./scripts/update-flux-dashboards.sh [ref]     # ref defaults to "main"
#
# Upstream has no tags, so the resolved commit SHA is printed and written to the
# CHANGELOG entry to keep each sync reproducible.
#
# Why a patch layer is needed (all verified against a live installation):
#
#   * Multi-cluster. Our dashboards live in the management cluster's Grafana,
#     whose Mimir holds metrics for every workload cluster. Upstream is written
#     for a single cluster, so every selector needs a `cluster_id` filter, plus
#     the standard Giant Swarm `organization`/`cluster` variable pair.
#   * Double counting. On a management cluster BOTH `job="flux-ksm"` and
#     `job="kube-state-metrics"` export identical `gotk_resource_info` series, so
#     upstream's unfiltered `count(...)` reads exactly 2x. We aggregate with
#     `max by (<displayed labels>)` which de-duplicates on the MC and is a no-op
#     on workload clusters, where only one exporter is present.
#   * Namespace label is not consistent across cluster types. On
#     `gotk_reconcile_duration_seconds_*` the management cluster carries
#     `namespace` (controller) + `exported_namespace` (object), while workload
#     clusters carry only `namespace` (object) and no `exported_namespace`. The
#     duration panels therefore get an `or` fallback so one query works on both.
#     `gotk_resource_info` is consistent (`exported_namespace` everywhere) and
#     needs no such treatment.
#   * Logs. `stream` is moved to structured metadata by our Alloy config and then
#     label-dropped, and `app` identifies the Helm release (`flux-app`) rather
#     than a controller, so upstream's `{namespace, stream, app}` selector cannot
#     work. We select on `service_name` + `cluster_id` + `pod` instead, matching
#     charts/networking/.../cilium-agent-logs.json.
#
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
REPO_ROOT=$(cd "$SCRIPT_DIR/.." && pwd -P)
DEST_DIR="$REPO_ROOT/helm/dashboards/charts/app_platform/dashboards/Shared Org/GitOps"

UPSTREAM_REPO="fluxcd/flux2-monitoring-example"
UPSTREAM_PATH="monitoring/configs/dashboards"
FLUX_REF="${1:-main}"

TAGS='["flux","component:flux","topic:gitops","owner:team-honeybadger"]'

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# --- shared jq fragments -----------------------------------------------------

# The Giant Swarm standard Prometheus datasource variable.
read -r -d '' VAR_DATASOURCE <<'EOF' || true
{
  "current": {"selected": false, "text": "default", "value": "default"},
  "hide": 0, "includeAll": false, "label": "Data source", "multi": false,
  "name": "datasource", "options": [], "query": "prometheus", "refresh": 1,
  "regex": "", "skipUrlSync": false, "type": "datasource"
}
EOF

# Chained organization -> cluster variables, following
# charts/cloud/dashboards/Shared Org/Kubernetes/nodes-overview.json.
# `gotk_reconcile_duration_seconds_count` is emitted only by Flux controllers, so
# the dropdowns list exactly the clusters that actually run Flux.
gs_cluster_vars() {
    local base="$1"
    cat <<EOF
[
  {
    "current": {"selected": false, "text": "", "value": ""},
    "datasource": {"type": "prometheus", "uid": "\$datasource"},
    "definition": "label_values($base, organization)",
    "hide": 0, "includeAll": false, "label": "Organization", "multi": false,
    "name": "organization", "options": [],
    "query": {"query": "label_values($base, organization)", "refId": "StandardVariableQuery"},
    "refresh": 2, "regex": "", "skipUrlSync": false, "sort": 1, "type": "query"
  },
  {
    "current": {"selected": false, "text": "", "value": ""},
    "datasource": {"type": "prometheus", "uid": "\$datasource"},
    "definition": "label_values($base{organization=\"\$organization\"}, cluster_id)",
    "hide": 0, "includeAll": false, "label": "Cluster", "multi": false,
    "name": "cluster", "options": [],
    "query": {"query": "label_values($base{organization=\"\$organization\"}, cluster_id)", "refId": "StandardVariableQuery"},
    "refresh": 2, "regex": "", "skipUrlSync": false, "sort": 1, "type": "query"
  }
]
EOF
}

# Normalise metadata every dashboard shares.
gs_common() {
    local uid="$1"
    jq --arg uid "$uid" --argjson tags "$TAGS" '
        .uid = $uid
        | .tags = $tags
        | .timezone = "UTC"
        # Provisioned dashboards are read-only; the linter enforces this.
        | .editable = false
        | del(.id, .version, .iteration, .__inputs, .__requires, .__elements)
        # Drop upstream'"'"'s datasource-picker variables; we add our own.
        | .templating.list |= map(select(.type != "datasource"))
    '
}

# --- cluster.json ------------------------------------------------------------

patch_cluster() {
    # Labels the readiness/suspended tables actually display (they end with a
    # filterFieldsByName on Namespace|Kind|Name|Status). Aggregating by exactly
    # these de-duplicates the two management-cluster exporters without losing a
    # displayed column.
    local keep='exported_namespace, customresource_kind, name, ready, suspended'

    jq --arg keep "$keep" '
        def patch_expr:
            # 1. gotk_resource_info: scope to the selected cluster and de-duplicate.
            gsub("gotk_resource_info\\{(?<sel>[^}]*)\\}";
                 "max by (" + $keep + ") (gotk_resource_info{cluster_id=\"$cluster\", \(.sel)})")
            # 2. Drop the operator_namespace matcher: on workload clusters
            #    `namespace` is the object namespace, so filtering it by the
            #    controller namespace returns nothing.
            | gsub("namespace=~\"\\$operator_namespace\",\\s*"; "")
            # 3. Scope the duration metrics to the selected cluster.
            | gsub("gotk_reconcile_duration_seconds_(?<s>sum|count)\\{";
                   "gotk_reconcile_duration_seconds_\(.s){cluster_id=\"$cluster\",");

        # For the duration panels, add an `or` fallback so the namespace filter
        # works on management clusters (exported_namespace) and on workload
        # clusters (namespace) alike. Only one branch ever returns series.
        def dual_namespace:
            if test("gotk_reconcile_duration_seconds") and test("exported_namespace")
            then "(" + . + ")\nor\n(" + gsub("exported_namespace=~"; "namespace=~") + ")"
            else . end;

        (.. | objects | select(has("expr")) | .expr) |= (patch_expr | dual_namespace)
        | .templating.list |= map(select(.name != "operator_namespace"))
        | (.templating.list[] | select(.name == "namespace")) |= (
              .datasource = {"type": "prometheus", "uid": "$datasource"}
            | .definition = "label_values(gotk_resource_info{cluster_id=\"$cluster\"}, exported_namespace)"
            | .query = {"query": "label_values(gotk_resource_info{cluster_id=\"$cluster\"}, exported_namespace)", "refId": "StandardVariableQuery"}
            | .label = "Namespace"
            | .refresh = 2
          )
    '
}

# --- control-plane.json ------------------------------------------------------

patch_control_plane() {
    jq '
        def patch_expr:
            # 1. Every selector gets a cluster filter. Metric names are the only
            #    thing followed by `{` in PromQL (aggregations use parentheses),
            #    so this is a safe injection point.
            gsub("(?<m>\\b[a-z_][a-z0-9_]*)\\{(?<sel>[^}]*)\\}";
                 "\(.m){cluster_id=\"$cluster\", \(.sel)}")
            # 2. Every selector also gets the Flux namespace. `controller_runtime_*`
            #    and `workqueue_*` are generic controller-runtime metrics: on a
            #    management cluster dozens of unrelated operators expose them, and
            #    several expose the very same `controller` label values Flux does
            #    (`controller="helmrelease"` is also emitted by dex-operator and
            #    team-stamper). Without this the panels silently mix in other
            #    operators. The lookahead skips selectors already scoped.
            | gsub("\\{cluster_id=\"\\$cluster\", (?![^}]*namespace)";
                   "{cluster_id=\"$cluster\", namespace=\"$namespace\", ")
            # 3. Our scrape interval is 60s, so upstream'"'"'s `[1m]` range windows
            #    contain at most one sample and rate()/increase() return nothing.
            | gsub("\\[1m\\]"; "[$__rate_interval]");

        (.. | objects | select(has("expr")) | .expr) |= patch_expr
        # The namespace variable must list the *controller* namespace, which
        # differs by cluster type (flux-giantswarm on MCs, flux-system on WCs).
        # workqueue metrics are scraped from the controller pods, so their
        # `namespace` label is the controller namespace on both.
        | (.templating.list[] | select(.name == "namespace")) |= (
              .datasource = {"type": "prometheus", "uid": "$datasource"}
            | .definition = "label_values(workqueue_work_duration_seconds_count{cluster_id=\"$cluster\", pod=~\".*-controller-.*\"}, namespace)"
            | .query = {"query": "label_values(workqueue_work_duration_seconds_count{cluster_id=\"$cluster\", pod=~\".*-controller-.*\"}, namespace)", "refId": "StandardVariableQuery"}
            | .label = "Flux namespace"
            | .refresh = 2
            | .current = {"selected": false, "text": "", "value": ""}
          )
    '
}

# --- logs.json ---------------------------------------------------------------

patch_logs() {
    local selector='{service_name=~"flux-app|flux-operator", cluster_id="$cluster", pod=~"$controller.*"}'

    jq --arg selector "$selector" '
        # Replace upstream'"'"'s stream selector wholesale: `stream` is dropped by
        # our Alloy config and `app` names the Helm release, not the controller.
        (.. | objects | select(has("expr")) | .expr) |=
            gsub("\\{namespace=~\"\\$namespace\",\\s*stream=~\"\\$stream\",\\s*app\\s*=~\"\\$controller\"\\}"; $selector)
        # Panels query Loki directly; the repo convention for v1 dashboards is a
        # hardcoded gs-loki datasource (see cilium-agent-logs.json).
        | (.. | objects | select(has("datasource")) | .datasource) |=
            (if type == "object" and .type == "grafana" then .
             else {"type": "loki", "uid": "gs-loki"} end)
        # `namespace` and `stream` no longer parameterise anything.
        | .templating.list |= map(select(.name != "namespace" and .name != "stream"))
        # Controller identity comes from the pod name prefix.
        | (.templating.list[] | select(.name == "controller")) |= (
              {
                "allValue": ".*",
                "current": {"selected": true, "text": ["All"], "value": ["$__all"]},
                "hide": 0, "includeAll": true, "label": "Controller",
                "multi": true, "name": "controller",
                "options": [], "query": "source-controller,kustomize-controller,helm-controller,notification-controller,image-automation-controller,image-reflector-controller,flux-operator",
                "skipUrlSync": false, "type": "custom"
              }
          )
    '
}

# --- driver ------------------------------------------------------------------

resolve_sha() {
    curl -sSfL "https://api.github.com/repos/$UPSTREAM_REPO/commits/$FLUX_REF" | jq -r '.sha'
}

fetch() {
    curl -sSfL "https://raw.githubusercontent.com/$UPSTREAM_REPO/$1/$UPSTREAM_PATH/$2"
}

# Fails loudly when upstream adds a panel our injectors did not reach, so the
# monthly PR surfaces the gap instead of silently shipping a fleet-wide query.
assert_scoped() {
    local file="$1" require_namespace="$2" bad rc=0

    bad=$(jq -r '[.. | objects | select(has("expr")) | .expr
                  | select(test("\\{") and (test("cluster_id") | not))] | .[]' "$file")
    if [[ -n "$bad" ]]; then
        echo "ERROR: $(basename "$file") has expressions with no cluster_id filter:" >&2
        echo "$bad" >&2
        rc=1
    fi

    # Every selector on the control-plane dashboard must be namespace-scoped,
    # otherwise generic controller-runtime metrics from other operators leak in.
    if [[ "$require_namespace" == "yes" ]]; then
        bad=$(jq -r '[.. | objects | select(has("expr")) | .expr
                      | select(test("\\{(?![^}]*namespace)"))] | .[]' "$file")
        if [[ -n "$bad" ]]; then
            echo "ERROR: $(basename "$file") has selectors with no namespace filter:" >&2
            echo "$bad" >&2
            rc=1
        fi
    fi

    # 60s scrape interval: a [1m] window cannot hold two samples.
    bad=$(jq -r '[.. | objects | select(has("expr")) | .expr | select(test("\\[1m\\]"))] | .[]' "$file")
    if [[ -n "$bad" ]]; then
        echo "ERROR: $(basename "$file") still has [1m] range windows:" >&2
        echo "$bad" >&2
        rc=1
    fi

    if [[ $rc -ne 0 ]]; then
        echo "Upstream likely changed. Update the patch functions in $(basename "${BASH_SOURCE[0]}")." >&2
    fi
    return $rc
}

main() {
    local sha
    sha=$(resolve_sha)
    echo "====> Syncing Flux dashboards from $UPSTREAM_REPO@$FLUX_REF ($sha)"

    mkdir -p "$DEST_DIR"

    # upstream file : our file : uid : patch function : require namespace scoping
    local specs=(
        "cluster.json:flux-cluster.json:flux-cluster:patch_cluster:no"
        "control-plane.json:flux-control-plane.json:flux-control-plane:patch_control_plane:yes"
        "logs.json:flux-logs.json:flux-logs:patch_logs:no"
    )
    # `gotk_reconcile_duration_seconds_count` is emitted only by Flux controllers,
    # so the organization/cluster dropdowns list exactly the clusters running Flux.
    local base="gotk_reconcile_duration_seconds_count"

    local spec src dst uid fn needs_ns out
    for spec in "${specs[@]}"; do
        IFS=: read -r src dst uid fn needs_ns <<<"$spec"
        echo "  Patching $src -> $dst"
        out="$TMPDIR/$dst"

        fetch "$sha" "$src" \
            | sed -e 's/\${DS_PROMETHEUS}/$datasource/g' -e 's/\$DS_PROMETHEUS/$datasource/g' \
                  -e 's/\${DS_LOKI}/gs-loki/g' -e 's/\$DS_LOKI/gs-loki/g' \
            | "$fn" \
            | gs_common "$uid" \
            | jq --argjson ds "$VAR_DATASOURCE" --argjson cv "$(gs_cluster_vars "$base")" \
                 '.templating.list = ([$ds] + $cv + .templating.list)' \
            > "$out"

        assert_scoped "$out" "$needs_ns"
        # Stable key order keeps the monthly diff to real changes only.
        jq -S . "$out" > "$DEST_DIR/$dst"
    done

    echo "====> Dashboards written to $DEST_DIR"

    local gst entry
    gst=$(cd "$REPO_ROOT" && git status --short -- "$DEST_DIR")
    if [[ -z "$gst" ]]; then
        echo "====> No changes."
        return 0
    fi
    echo "$gst"

    # Re-running the script must not stack duplicate CHANGELOG entries, so skip
    # when this upstream commit is already recorded.
    entry="- Synced Flux dashboards from [$UPSTREAM_REPO@${sha:0:7}](https://github.com/$UPSTREAM_REPO/tree/$sha/$UPSTREAM_PATH)."
    # `--` matters: the entry starts with "- ", which grep would read as an option.
    if grep -qF -- "$entry" "$REPO_ROOT/CHANGELOG.md"; then
        echo "====> CHANGELOG already mentions ${sha:0:7}, not adding a duplicate entry."
    else
        # Add the bullet to the existing "### Changed" block under [Unreleased]
        # when there is one, so we do not leave two identical headings behind.
        awk -v entry="$entry" '
            /^## \[Unreleased\]/ { print; in_unreleased = 1; next }
            in_unreleased && /^## / {
                # Left [Unreleased] without finding a Changed section: add one.
                if (!done) { print "### Changed\n\n" entry "\n"; done = 1 }
                in_unreleased = 0
            }
            in_unreleased && !done && /^### Changed[[:space:]]*$/ {
                print; pending = 1; next
            }
            # Emit the bullet after the blank line that follows the heading, so it
            # joins the existing list instead of starting a detached one.
            pending { print; print entry; pending = 0; done = 1; next }
            { print }
            END { if (in_unreleased && !done) print "### Changed\n\n" entry }
        ' "$REPO_ROOT/CHANGELOG.md" > "$TMPDIR/CHANGELOG.md"
        mv "$TMPDIR/CHANGELOG.md" "$REPO_ROOT/CHANGELOG.md"
    fi

    cat <<'WARN'

====> These dashboards carry Giant Swarm patches. Review the diff.

Known custom changes (see the header of this script for the reasoning):
  - organization/cluster variables added; every selector filtered by cluster_id
  - gotk_resource_info aggregated with `max by (...)` to de-duplicate the two
    management-cluster exporters
  - duration panels carry an `or` fallback for the MC/WC namespace-label split
  - logs dashboard selects on service_name/cluster_id/pod, not namespace/stream/app
  - Flux logs are only ingested for the management cluster: workload-cluster
    `flux-system` has no tenant assignment, so Alloy drops those pod logs
WARN
}

main "$@"
