module github.com/giantswarm/dashboards

go 1.16

require (
	github.com/google/go-jsonnet v0.17.0
	github.com/grafana/grizzly v0.1.1-0.20210907160355-7ed8cc64c664
	github.com/jsonnet-bundler/jsonnet-bundler v0.4.0
)

replace (
	git.apache.org/thrift.git => github.com/apache/thrift v0.0.0-20180902110319-2566ecd5d999
	// All below replacements are from https://github.com/grafana/grizzly/blob/master/go.mod

	// Cortex Overrides
	github.com/Azure/azure-sdk-for-go => github.com/Azure/azure-sdk-for-go v36.2.0+incompatible

	// Using a 3rd-party branch for custom dialer - see https://github.com/bradfitz/gomemcache/pull/86
	github.com/bradfitz/gomemcache => github.com/themihai/gomemcache v0.0.0-20180902122335-24332e2d58ab

	// Using a fork of gocql that has gokit logs and Prometheus metrics.
	github.com/gocql/gocql => github.com/grafana/gocql v0.0.0-20200605141915-ba5dc39ece85

	// Required for Alertmanager
	github.com/hashicorp/consul => github.com/hashicorp/consul v1.8.1
	github.com/satori/go.uuid => github.com/satori/go.uuid v1.2.0
	k8s.io/api => k8s.io/api v0.20.4

	// Keeping this thhe same as Cortex to avoid dependency issues.
	k8s.io/client-go => k8s.io/client-go v0.20.4
)
