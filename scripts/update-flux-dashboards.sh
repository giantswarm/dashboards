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

# Flux controller deployment names, anchored. Workload clusters prefix them with
# `flux-`. Used to tell Flux's pods apart from every other controller-runtime
# operator that exposes the same generic workqueue metrics.
FLUX_CONTROLLERS='source|kustomize|helm|notification|image-automation|image-reflector'
FLUX_CONTROLLER_PODS="(flux-)?($FLUX_CONTROLLERS)-controller-.*"

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
        # Point every Prometheus reference at the $datasource variable. Upstream
        # hardcodes `uid: "prometheus"` on some *targets* while their panel uses
        # the variable; no datasource with that uid exists in our Grafana, and the
        # target-level datasource wins, so those panels would query nothing. The
        # linter only inspects panel-level datasources and cannot catch it.
        # Rewriting every prometheus-typed reference (not just uid=="prometheus")
        # means a different hardcoded uid upstream cannot reintroduce this.
        | (.. | objects | select(.type? == "prometheus" and has("uid")))
              |= {"type": "prometheus", "uid": "$datasource"}
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
        # clusters (namespace) alike.
        #
        # The fallback branch is pinned to `exported_namespace=""` so the two
        # branches stay mutually exclusive. Without it the branches overlap on a
        # management cluster: there `namespace` is the *controller* namespace
        # (flux-giantswarm), which is also one of the object namespaces the
        # dropdown offers, and `or` only suppresses right-hand series whose exact
        # label set already exists on the left. Selecting flux-giantswarm then
        # pulled in objects from every other namespace (205 series, not 52).
        def dual_namespace:
            if test("gotk_reconcile_duration_seconds") and test("exported_namespace")
            then "(" + . + ")\nor\n("
                 + gsub("exported_namespace=~"; "exported_namespace=\"\",namespace=~")
                 + ")"
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
            #    It must match the `namespace=` label, not the bare substring:
            #    `exported_namespace=` contains "namespace" and would otherwise
            #    look already-scoped, so an exported_namespace-only selector would
            #    silently keep a fleet-wide generic metric.
            | gsub("\\{cluster_id=\"\\$cluster\", (?![^}]*(?<![a-z_])namespace=)";
                   "{cluster_id=\"$cluster\", namespace=\"$namespace\", ")
            # 3. Our scrape interval is 60s, so upstream'"'"'s `[1m]` range windows
            #    contain at most one sample and rate()/increase() return nothing.
            #    Widening the window is not enough for the `increase()` panels:
            #    they are titled "ops/min" with unit `opm`, so the value must stay
            #    per-minute. `increase(m[$__rate_interval])` would report the count
            #    over 4m+ (and grow as the time range widens), reading several
            #    times high. Convert those to a per-second rate scaled to a minute.
            #    The `by (...)` clause belongs to the aggregation, so it has to
            #    stay before the multiplication -- hence the two passes.
            | gsub("sum\\(increase\\((?<body>[^\\[]*)\\[1m\\]\\)\\)\\s*by\\s*\\((?<grp>[^)]*)\\)";
                   "sum(rate(\(.body)[$__rate_interval])) by (\(.grp)) * 60")
            | gsub("sum\\(increase\\((?<body>[^\\[]*)\\[1m\\]\\)\\)";
                   "sum(rate(\(.body)[$__rate_interval])) * 60")
            | gsub("\\[1m\\]"; "[$__rate_interval]");

        (.. | objects | select(has("expr")) | .expr) |= patch_expr
        # The namespace variable must list the *controller* namespace, which
        # differs by cluster type (flux-giantswarm on MCs, flux-system on WCs).
        # workqueue metrics are scraped from the controller pods, so their
        # `namespace` label is the controller namespace on both -- but they are
        # generic controller-runtime metrics, and a loose `.*-controller-.*` pod
        # match also selects unrelated operators (on a management cluster it
        # returns external-secrets, giantswarm and kube-system alongside
        # flux-giantswarm, and Grafana would auto-select the alphabetically first).
        # Anchoring on the Flux controller deployment names yields exactly one
        # namespace per cluster type.
        | (.templating.list[] | select(.name == "namespace")) |= (
              .datasource = {"type": "prometheus", "uid": "$datasource"}
            | .definition = $q
            | .query = {"query": $q, "refId": "StandardVariableQuery"}
            | .label = "Flux namespace"
            | .refresh = 2
            | .sort = 1
            | .current = {"selected": false, "text": "", "value": ""}
          )
    ' --arg q "label_values(workqueue_work_duration_seconds_count{cluster_id=\"\$cluster\", pod=~\"$FLUX_CONTROLLER_PODS\"}, namespace)"
}

# --- logs.json ---------------------------------------------------------------

patch_logs() {
    local selector='{service_name=~"flux-app|flux-operator", cluster_id="$cluster", pod=~"$controller.*"}'
    local caveat banner
    caveat="Only management-cluster Flux logs are ingested. Workload clusters run Flux in the flux-system namespace, which has no tenant assignment, so their controller logs are dropped before reaching Loki and this dashboard will be empty for them."
    banner=$(cat <<'EOF'
{
  "type": "text",
  "title": "",
  "gridPos": {"h": 3, "w": 24, "x": 0, "y": 0},
  "id": 1000,
  "transparent": true,
  "options": {
    "mode": "markdown",
    "code": {"language": "plaintext", "showLineNumbers": false, "showMiniMap": false},
    "content": "> **Management cluster only.** Flux controller logs are ingested for the management cluster. Workload clusters run Flux in the `flux-system` namespace, which has no tenant assignment, so their logs are dropped before reaching Loki -- selecting a workload cluster below will show no data even when Flux is running there."
  }
}
EOF
)

    jq --arg selector "$selector" --arg caveat "$caveat" --argjson banner "$banner" '
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
        # The Cluster dropdown lists every cluster running Flux, but only
        # management-cluster logs are ingested. A panel description only shows on
        # hover, which is no help to someone looking at two empty panels, so push
        # the existing panels down and put a visible banner on top.
        | .description = $caveat
        | (.. | objects | select(has("targets")) | .description) |= $caveat
        | .panels |= (map(.gridPos.y += 3) | [$banner] + .)
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

    fail() {
        echo "ERROR: $(basename "$file") $1:" >&2
        echo "$2" >&2
        rc=1
    }

    # Every *selector* must be cluster-scoped -- checked per selector rather than
    # per expression, so `count(a{cluster_id=...}) / count(b{})` cannot slip by.
    bad=$(jq -r '[.. | objects | select(has("expr")) | .expr
                  | [match("\\{[^}]*\\}"; "g").string]
                  | map(select(test("(?<![a-z_])cluster_id=") | not)) | .[]] | unique | .[]' "$file")
    [[ -n "$bad" ]] && fail "has selectors with no cluster_id filter" "$bad"

    # A bare metric name with no selector at all is neither patched nor caught by
    # the check above, and would query the whole fleet.
    bad=$(jq -r --arg fams "gotk_|controller_runtime_|workqueue_|rest_client_|go_|process_|container_" '
              [.. | objects | select(has("expr")) | .expr
               | select(test("(^|[^a-z_{\"])(\($fams))[a-z0-9_]*\\s*(\\[|\\)|$|\\s)"))] | unique | .[]' "$file")
    [[ -n "$bad" ]] && fail "has metrics used without a label selector" "$bad"

    # Every selector on the control-plane dashboard must be namespace-scoped,
    # otherwise generic controller-runtime metrics from other operators leak in.
    if [[ "$require_namespace" == "yes" ]]; then
        bad=$(jq -r '[.. | objects | select(has("expr")) | .expr
                      | [match("\\{[^}]*\\}"; "g").string]
                      | map(select(test("(?<![a-z_])namespace=") | not)) | .[]] | unique | .[]' "$file")
        [[ -n "$bad" ]] && fail "has selectors with no namespace filter" "$bad"
    fi

    # 60s scrape interval: a [1m] window cannot hold two samples.
    bad=$(jq -r '[.. | objects | select(has("expr")) | .expr | select(test("\\[1m\\]"))] | unique | .[]' "$file")
    [[ -n "$bad" ]] && fail "still has [1m] range windows" "$bad"

    # `increase()` over $__rate_interval is not a per-minute value; the ops/min
    # panels must use rate() * 60.
    bad=$(jq -r '[.. | objects | select(has("expr")) | .expr | select(test("increase\\("))] | unique | .[]' "$file")
    [[ -n "$bad" ]] && fail "still uses increase() (ops/min panels need rate() * 60)" "$bad"

    # Every $variable referenced must actually exist. This is what catches an
    # upstream rename: the text-anchored rewrites above would silently no-op while
    # the variable they depend on has already been dropped, leaving a dead panel.
    bad=$(jq -r '
        (.templating.list | map(.name)) as $defined
        | ["__rate_interval", "__interval", "__interval_ms", "__auto", "__all",
           "__range", "__from", "__to", "__timeFilter", "__dashboard", "__user", "__org"] as $builtin
        | [.. | objects | (.expr?, .query?, .definition?) | select(type == "string")]
          + [.. | objects | .query? | objects | .query? | select(type == "string")]
        | map([match("\\$\\{?([a-zA-Z_][a-zA-Z0-9_]*)"; "g").captures[0].string]) | add // []
        | unique | map(select(. as $v | ($defined | index($v)) == null and ($builtin | index($v)) == null)) | .[]
    ' "$file")
    [[ -n "$bad" ]] && fail "references undefined dashboard variables" "$bad"

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
