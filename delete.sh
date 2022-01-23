#!/bin/bash

kubectl delete -f 1-manifest/1-prometheus/
kubectl delete -f 1-manifest/2-node-export/
kubectl delete -f 1-manifest/3-kube-state-metrics/
kubectl delete -f 1-manifest/4-grafana/
kubectl delete -f 1-manifest/5-alertmanger/

#kubectl delete -f 2-traefik/

#kubectl delete -f 3-cert-manager/