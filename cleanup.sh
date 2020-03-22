#!/usr/bin/env bash

kubectl delete secret/common-env-secrets
kubectl delete configmap/common-env-vars
kubectl delete podpreset/common-podpreset
kubectl delete pod/preset-test-pod