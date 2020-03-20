# PodPreset example

Example showing the use of the
[PodPreset](https://kubernetes.io/docs/tasks/inject-data-application/podpreset/)
admission controller to control what environment variables, volumes and
volume mounts are made available inside of a pod at the moment of its creation.

# Installing

Since the PodPreset admission controller is a feature in alpha stage it isn't
enabled by default. In order to enable it you'll need to start the kubernetes
`api-server` pods with the following flags added to their container config:

```
--runtime-config=settings.k8s.io/v1alpha1=true
--enable-admission-plugins=PodPreset
```

## Kops configuration

When using kops for cluster provisioning, the flags for
[the API server](https://github.com/kubernetes/kops/blob/master/docs/cluster_spec.md#kubeapiserver)
is provided through the cluster spec like below:

```
kubeAPIServer:
    runtimeConfig:
      'settings.k8s.io/v1alpha1': 'true'
    appendAdmissionPlugins:
      - PodPreset
```