#!/bin/bash

# Update monitoring mixin dashboard
#
# Retreive the dashboard from Upstream 
# # https://monitoring.mixins.dev/
# and update it.
# 

set -e

echo "-- env"
env
echo "-- pwd"
pwd
echo "-- ls"
ls -la
echo "-- end"

main() {
## clone the repo
git clone git@github.com:monitoring-mixins/website.git --depth 1 monitoring-mixins

apps=("alertmanager" "prometheus")

## Copy and overwrite
for app in "${apps[@]}"; do

    echo "copying $app dashboard"

    cp ./monitoring-mixins/assets/"$app"/dashboards/* ./helm/dashboards/dashboards/shared/private/

done

}

