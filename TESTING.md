# How to test

* Chose a test cluster (`opsctl login gauss`)
* Open grafana (`opsctl open -i gauss -a grafana`)
* Check your dashboards (if already existing) are working as expected before your changes
* Take screenshots, will be useful for your PR
* Create a draft PR, to trigger build
* Look at the build step `ci/circleci: app-catalog`, step `Push chart archive to OCI registry app catalog`
    * take note of pushed image name
* Deploy on a test cluster
    * suspend flux (`flux suspend kustomization -n flux-giantswarm collection; flux suspend kustomization -n flux-giantswarm flux`)
    * then deploy, either with `opsctl deploy` or edit grafana app (`kubectl -n giantswarm edit app dashboards`)
    * for the later, update catalog name and image version according to the image name shown in build log
    * check it is deployed with `kubectl -n giantswarm get app dashboards`
* Visit your updated dashboards
* Take screenshots, will be useful for your PR
* Resume flux to revert cluster to standard state (`flux resume kustomization -n flux-giantswarm collection; flux resume kustomization -n flux-giantswarm flux`)
