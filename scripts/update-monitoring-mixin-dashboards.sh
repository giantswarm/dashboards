#!/bin/bash

# Update monitoring mixin dashboard
#
# Retreive the dashboard from Upstream 
# # https://monitoring.mixins.dev/
# and update it.
# 

set -e

TMPDIR="$(mktemp -d)"


main() {
## clone the repo
git clone https://github.com/monitoring-mixins/website.git --depth 1 "$TMPDIR"/monitoring-mixins

apps=("alertmanager" "prometheus")

## Copy and overwrite
for app in "${apps[@]}"; do

    echo "copying $app dashboard"

    cp "$TMPDIR"/monitoring-mixins/assets/"$app"/dashboards/* ./helm/dashboards/dashboards/shared/private/

done

echo "------- Status"
if [[ "$(git status --short)" != "" ]]; then
    echo "applying changes"
    echo_changes > "$TMPDIR"/tmp_changes
    sed -i '/^## \[Unreleased\]/r '"$TMPDIR"'/tmp_changes' CHANGELOG.md
fi

}


echo_changes() {
  echo ""
  echo "### Changed"
  echo ""
  echo "- Monitoring Dashboard Updated"
  echo "\`\`\`"
  git status --short
  echo "\`\`\`"
}


main "$@"

# Clean
rm -r "$TMPDIR"
