

# helper-argocd

  [![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/openshift-bootstraps)](https://artifacthub.io/packages/search?repo=openshift-bootstraps)
  [![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
  [![Lint and Test Charts](https://github.com/tjungbauer/helm-charts/actions/workflows/lint_and_test_charts.yml/badge.svg)](https://github.com/tjungbauer/helm-charts/actions/workflows/lint_and_test_charts.yml)
  [![Release Charts](https://github.com/tjungbauer/helm-charts/actions/workflows/release.yml/badge.svg)](https://github.com/tjungbauer/helm-charts/actions/workflows/release.yml)

  ![Version: 2.0.41](https://img.shields.io/badge/Version-2.0.41-informational?style=flat-square)

 

  ## Description

  Takes care of creation of Applications, Appprojects and ApplicationSets (supporting different generators)

This chart can be used to render Argo CD Applications, ApplicationSets and Appprojects.
It is usually used by the [App-pf-Apps](https://github.com/tjungbauer/openshift-clusterconfig-gitops/tree/main/base/init_app_of_apps) and the configuration
that is used is stored at: [Argo CD Resources Manager](https://github.com/tjungbauer/openshift-clusterconfig-gitops/blob/main/base/argocd-resources-manager/values.yaml)

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| tjungbauer | <tjungbau@redhat.com> | <https://blog.stderr.at/> |

## Sources
Source:
* <https://github.com/tjungbauer/helm-charts>
* <https://charts.stderr.at/>
* <https://github.com/tjungbauer/openshift-clusterconfig-gitops>

Source code: https://github.com/tjungbauer/helm-charts/tree/main/charts/helper-argocd

## Examples

The values.yaml has different examples:

NOTE: Inside the values-file in this lokal Git repository, all examples are "disabled". The real, active values can be found at: https://github.com/tjungbauer/openshift-clusterconfig-gitops/blob/main/base/argocd-resources-manager/values.yaml

### Example: ApplicationSet with Matrix generator using Git and List generators:

```yaml
  mgmt-cluster: # (1)
    # Is the ApplicationSet enabled or not
    enabled: false # (2)

    # Description - always usful
    description: "ApplicationSet that Deploys on Management Cluster Configuration (using Matrix Generator)"

    # Any labels you would like to add to the Application. Good to filter it in the Argo CD UI.
    labels:
      category: configuration
      env: mgmt-cluster

    # Using go text template. See: https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/GoTemplate/
    goTemplate: true
    argocd_project: *mgmtclustername

    # preserve all resources when the application get deleted. This is useful to keep that workload even if Argo CD is removed or severely changed.
    preserveResourcesOnDeletion: true

    # Definition of Matrix Generator. Only 2 generators are supported at the moment
    generatormatrix: # (3)
          # Git: Walking through the specific folder and take whatever is there.
          - git: # (4)
              directories:
                - path: clusters/management-cluster/*
                - path: clusters/management-cluster/waves
                  exclude: true
              repoURL: *repourl
              revision: *branch
          # List: simply define the targetCluster. The name of the cluster must be known by Argo CD
          - list: # (5)
              elements:
                  # targetCluster is important, this will define on which cluster it will be rolled out.
                  # The cluster name must be known in Argo CD
                - targetCluster: *mgmtclustername
    syncPolicy:
      autosync_enabled: false

    # Retrying in case the sync failed.
    retries:
      # number of failed sync attempt retries; unlimited number of attempts if less than 0
      limit: 5
      backoff:
        # the amount to back off. Default unit is seconds, but could also be a duration (e.g. "2m", "1h")
        # Default: 5s
        duration: 5s
        # a factor to multiply the base duration after each failed retry
        # Default: 2
        factor: 2
        # the maximum amount of time allowed for the backoff strategy
        # Default: 3m
        maxDuration: 3m

    # Ignore specific differences in obhects. For example: the randomly generated password string in the secret for Quay.
    ignoreDifferences:
      - kind: Secret
        jsonPointers:
          - /data/password
        name: init-user
        namespace: quay-enterprise
```
1. A unique key, Argo CD will use this key for the name of the Argo CD Application.
2. Enabled true/false.
3. Using Matrix Generator
4. First generator is "git", which is watching the folder *clusters/management-clusters/* and will take anything that can be find inside this folder, unless it is excluded.
5. Second generator is the list generator, that is defining the target cluster.

### Example: Using Git Files Generator

```yaml
  mgmt-cluster-gitgen:
    enabled: true

    # Description - always usful
    description: "ApplicationSet that Deploys on Management Cluster Configuration (using Git Generator)"
    # Any labels you would like to add to the Application. Good to filter it in the Argo CD UI.
    labels:
      category: configuration
      env: mgmt-cluster

    # Using go text template. See: https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/GoTemplate/
    goTemplate: true
    argocd_project: *mgmtclustername

    # preserve all resources when the application get deleted. This is useful to keep that workload even if Argo CD is removed or severely changed.
    preserveResourcesOnDeletion: true

    generatorgit:
      # Git: Walking through the specific folder and take whatever is there.
      - files:
          - clusters/management-cluster/**/config.json
        repourl: *repourl
        revision: *branch

    syncPolicy:
      autosync_enabled: false

    # Retrying in case the sync failed.
    retries:
      # number of failed sync attempt retries; unlimited number of attempts if less than 0
      limit: 5
      backoff:
        # the amount to back off. Default unit is seconds, but could also be a duration (e.g. "2m", "1h")
        # Default: 5s
        duration: 5s
        # a factor to multiply the base duration after each failed retry
        # Default: 2
        factor: 2
        # the maximum amount of time allowed for the backoff strategy
        # Default: 3m
        maxDuration: 3m
```

### Example: ApplicationSet using matrix generator with git files and list
```yaml
  mgmt-cluster-matrix-gitfiles:
    enabled: false

    # Description - always usful
    description: "ApplicationSet that Deploys on Management Cluster Configuration (using Git Generator)"
    # Any labels you would like to add to the Application. Good to filter it in the Argo CD UI.
    labels:
      category: configuration
      env: mgmt-cluster

    # Using go text template. See: https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/GoTemplate/
    goTemplate: true
    argocd_project: *mgmtclustername

    environment: *mgmtclustername

    # preserve all resources when the application get deleted. This is useful to keep that workload even if Argo CD is removed or severely changed.
    preserveResourcesOnDeletion: true

    # Switch to set the namespace to '.namespace' ... must be defined in config.json
    use_configured_namespace: true
   
    # Definition of Matrix Generator. Only 2 generators are supported at the moment
    generatormatrix:
      # Git: Walking through the specific folder and take whatever is there.
      - git:
          files:
            - path: clusters/management-cluster/**/config.json
          repoURL: *repourl
          revision: *branch
      # List: simply define the targetCluster. The name of the cluster must be known by Argo CD
      - list:
          elements:
              # targetCluster is important, this will define on which cluster it will be rolled out.
              # The cluster name must be known in Argo CD
            - targetCluster: *mgmtclustername

    syncPolicy:
      autosync_enabled: false

    # Retrying in case the sync failed.
    retries:
      # number of failed sync attempt retries; unlimited number of attempts if less than 0
      limit: 5
      backoff:
        # the amount to back off. Default unit is seconds, but could also be a duration (e.g. "2m", "1h")
        # Default: 5s
        duration: 5s
        # a factor to multiply the base duration after each failed retry
        # Default: 2
        factor: 2
        # the maximum amount of time allowed for the backoff strategy
        # Default: 3m
        maxDuration: 3m
```

### Example: ApplicationSet using list generator to deploy on ALL clusters:

```yaml
  # Install ETCD Encryption
  enable-etcd-encryption: # (1)
    enabled: false # (2)
    description: "Enable ETCD Encryption on target cluster"
    labels:
      category: security
    path: clusters/all/etcd-encryption # (3)
    generatorlist: [] # (4)
    syncPolicy:
      autosync_enabled: false # (5)
    targetrevision: "main"
```
1. A unique key, Argo CD will use this key for the name of the Argo CD Application. Argo CD will add the clustername as a prefix to the Application name to distiguish different target cluster.
2. Enabled true/false
3. Using the path as source. In this path the configuration of etcd encryption can be found.
4. Using the list generator. Since an empty list is used this ApplicationSet will create Applications for ALL clusters that are configured in Argo CD.
5. Automatic synchronization can be enabled if required.

### Example: ApplicationSet using list generator and a Helm chart:

```yaml
  # Name of the ApplicationSet. The clustername will be appended to the Application
  install_sonarqube: # (1)
    # Is the ApplicationSet enabled or not
    enabled: false # (2)

    # Description - always usful
    description: "Install Sonarqube"

    # Any specific namespace to be used
    namespace: sonarqube # (3)

    # Helm settings
    # These settings are used for single sources MAINLY.
    #
    # "per_cluster_helm_values" (bool, optional): Defines if every cluster known in Argo CD is using a spearate values-file. This values-file must be named <cluster-name>-values.yaml
    # "releasename" (string, optional): Overwrites the releasename of the chart
    # "paramters" (array, optional): Sets custom parameters for this chart. The list looks like:
    #      - name: Name/key of the parameter
    #      - value: value of the parameter
    helm: # (4)
      releasename: sonarqube

    # Any labels you would like to add to the Application. Good to filter it in the Argo CD UI.
    labels:
      category: project
    chartname: sonarqube # (5)
    repourl: "https://charts.stderr.at/"
    targetrevision: 1.0.1

    # List of clusters
    # "clustername" (string): Is the name of the cluster a defined in Argo CD
    # "clusterurl" (string): Is the URL of the cluster API
    # "chart_version" (string, optional): Defines which chart version shall be deployed on each cluster.
    generatorlist: # (6)
      - clustername: *mgmtclustername
        clusterurl: *mgmtcluster
    syncPolicy:
      autosync_enabled: false
```
1. A unique key, Argo CD will use this key for the name of the Argo CD Application. Argo CD will add the clustername as a prefix to the Application name to distiguish different target cluster.
2. Enabled true/false
3. This ApplicationSet is using a specific Namespace to deploy the Application.
4. Configuration of the Helm chart. It is possible to define a values-file per cluster (naming it cluster-name-values.yaml) to distinguish individual configurations between the clusters or define individual parameters are name/value pair.
5. The name of the Helm Chart, the Helm Chart repository and the version of the Chart.
6. The list of target clusters (name and api url)

## Installing the Chart

To install the chart with the release name `my-release`:

```console
helm install my-release tjungbauer/<chart-name>>
```

The command deploys the chart on the Kubernetes cluster in the default configuration.

## Uninstalling the Chart

To uninstall/delete the my-release deployment:

```console
helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.12.0](https://github.com/norwoodj/helm-docs/releases/v1.12.0)
