#!/bin/bash

echo "Install Services !!!"


kubectl apply -f 1-manifest/1-prometheus/
kubectl apply -f 1-manifest/2-node-export/
kubectl apply -f 1-manifest/3-kube-state-metrics/
kubectl apply -f 1-manifest/4-grafana/
kubectl apply -f 1-manifest/5-alertmanger/

sleep 120

echo " "
echo "Install Traefik !!!"
echo " "


kubectl apply -f 2-traefik/

sleep 60

echo " "
echo "Install Cert Manager!!!"
echo " "

kubectl apply -f 3-cert-manager/