#!/bin/bash

TOTAL_STEP=4
step=0

kubectl -n kube-system wait pods  --all --for condition=Ready --timeout=300s

kubectl apply -f yamls/kubevirt-operator.yaml
step=$(($step+1))
echo "[$step/$TOTAL_STEP] Succeeded to run kubevirt-operator.yaml"

kubectl apply -f yamls/kubevirt-cr.yaml
step=$(($step+1))
echo "[$step/$TOTAL_STEP] Succeeded to run kubevirt-cr.yaml"

echo "[$step/$TOTAL_STEP] wait for provisioning kubevirt components... (timeout = 6min)"
kubectl -n kubevirt wait kv kubevirt --for condition=Available --timeout=600s
[ $? -ne 0 ] && echo Failed to install kubevirt && exit 1

kubectl apply -f yamls/virtvnc.yaml
step=$(($step+1))
echo "[$step/$TOTAL_STEP] Succeeded to run virtvnc.yaml"

echo "[$step/$TOTAL_STEP] wait for provisioning virtvnc deployments... (timeout = 2min)"
kubectl -n kubevirt wait --for condition=Available deployment/virtvnc --timeout=120s
[ $? -ne 0 ] && echo Failed to install virtvnc && exit 1

step=$(($step+1))
echo "[$step/$TOTAL_STEP] kubevirt installation is done."

sudo cp hack/virtctl /usr/bin
sudo chmod u+ /usr/bin/virtctl
