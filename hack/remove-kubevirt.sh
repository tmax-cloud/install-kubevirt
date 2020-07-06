#!/bin/bash

TOTAL_STEP=2
step=0

kubectl delete -f yamls/kubevirt-cr.yaml
step=$(($step+1))
echo "[$step/$TOTAL_STEP] Succeeded to delete kubevirt-cr.yaml"

kubectl delete -f yamls/kubevirt-operator.yaml
step=$(($step+1))
echo "[$step/$TOTAL_STEP] Succeeded to delete kubevirt-operator.yaml"
