# dashboards

All our dashboards for Grafana

To make the dashboards, run:
```
./scripts/make-dashboards.sh
```

To upload the dashboards, run:
```
./scripts/upload-dashboards.sh
```

To upload a dashboard while editing, run:
```
./scripts/upload-dashboard.sh metrics.json
```

## Requirements

* jsonnet: https://github.com/google/jsonnet

`pip install jsonnet`

* grafonnet: https://github.com/grafana/grafonnet-lib

`git clone https://github.com/grafana/grafonnet-lib.git $GOPATH/src/github.com/grafana`
