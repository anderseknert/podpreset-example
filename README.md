# PodPreset example

Example showing the use of the
[PodPreset](https://kubernetes.io/docs/tasks/inject-data-application/podpreset/)
admission controller to control what environment variables (sourced from
`ConfigMap`s or `Secret`s), volumes and volume mounts are made available inside
of a pod at the moment of its creation.

Using pod presets allows for using light weight pod and container definitions,
adding environment specific configurations based on the labels set on the pod.

# Installing

Since the PodPreset admission controller is a feature in alpha stage it isn't
enabled by default. In order to enable it you'll need to start the kubernetes
`api-server` pods with the following flags added to their container config:

```sh
--runtime-config=settings.k8s.io/v1alpha1=true
--enable-admission-plugins=PodPreset
```

## Kops configuration

When using kops for cluster provisioning, the flags for
[the API server](https://github.com/kubernetes/kops/blob/master/docs/cluster_spec.md#kubeapiserver)
is provided through the cluster spec like below:

```yaml
kubeAPIServer:
    runtimeConfig:
      'settings.k8s.io/v1alpha1': 'true'
    appendAdmissionPlugins:
      - PodPreset
```

# PodPreset config

A PodPreset resource is used to determine what data (secret, config, volumes)
should be attached to which pods.

## PodPreset selector

Which pods are selected is determined by the label selector:

```yaml
apiVersion: settings.k8s.io/v1alpha1
kind: PodPreset
metadata:
  name: common-podpreset
spec:
  selector:
    matchExpressions:
      - {key: app, operator: Exists}
```
The above selector will have the podpreset applied to any pod with an `app`
label, regardless of its value.

## Injecting configuration

### envFrom

With a selector marking all our apps for injection of common config, we may
now specify which config to inject. Environment variables can either be fetched
from `ConfigMap`s, `Secret`s or provided directly in the `PodPreset` resource
definition. To include all variables in a configmap or secret, use `envFrom`
attribute to point to the `ConfigMap` or `Secret` of interest:

```yaml
spec:
  envFrom:
    - configMapRef:
        name: common-env-vars
    - secretRef:
        name: common-env-secrets
```

The snippet above would take all key/value pairs from the `common-env-vars`
configmap and the `common-env-secrets` secret and inject them as environment
variables in any pod matching the `app` label previously specified.

### env

While injecting everything from a `ConfigMap` or `Secret` works in many cases,
sometimes you'll find yourself wanting to expose only a few named variables or
secrets inside of your pod. This can be done with the `env` attribute combined
with either a `name`/`value` pair for defining variables directly, or by
referring to single attribute inside of your configmaps or secrets with
`valueFrom`:

```yaml
spec:
  env:
    - name: MY_VAR
      value: 'hello world'
    - name: SINGLE_VAR_FROM_CONFIGMAP
      valueFrom:
        configMapKeyRef:
          name: common-env-vars
          key: DATACENTER_NAME
    - name: APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY_SPECIFIC
      valueFrom:
        secretKeyRef:
          name: common-env-secrets
          key: APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY
```

See `podpreset/common-podpreset.yaml` for the full example.