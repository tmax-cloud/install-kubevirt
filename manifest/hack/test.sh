#!/bin/bash

VM_NAME=kubevirt
HOST_BASE_DIR=`pwd`
GUEST_BASE_DIR=/home/docker/installer
GUEST_BASE_DIR_ESCAPE=\\/home\\/docker\\/installer
RUN_CMD="minikube -p $VM_NAME ssh "

LOCAL_REGISTRY=localhost:5000

# start mimikube with hostpath mount
minikube stop -p $VM_NAME &> /dev/null
minikube delete -p $VM_NAME &> /dev/null
minikube config -p $VM_NAME set cpus ${MINIKUBE_CPU:-2}
minikube config -p $VM_NAME set memory ${MINIKUBE_MEMORY:-2048}
minikube config -p $VM_NAME set vm-driver kvm2
minikube start -p $VM_NAME
minikube -p $VM_NAME mount $HOST_BASE_DIR:$GUEST_BASE_DIR & # TODO: mount readonly

# wait kubernetes system pods to be ready and block internet for installation test in private network
minikube -p $VM_NAME kubectl -- -n kube-system wait pods  --all --for condition=Ready --timeout=300s

cp hack/install-kubevirt.sh hack/install-kubevirt-minikube.sh
sed -i 's/kubectl/minikube -p '$VM_NAME' kubectl --/g' hack/install-kubevirt-minikube.sh
sed -i 's/sudo/minikube -p '$VM_NAME' ssh sudo/g' hack/install-kubevirt-minikube.sh
sed -i 's/hack\/virtctl/'$GUEST_BASE_DIR_ESCAPE'\/hack\/virtctl/g' hack/install-kubevirt-minikube.sh

hack/install-kubevirt-minikube.sh
if [ $? -ne 0 ]; then
	echo kubevirt installation test with docker hub is failed
	echo minikube isnt deleted because of debug
	exit 1
else
	echo kubevirt installation test with docker hub is succeeded
	rm hack/install-kubevirt-minikube.sh
fi

cp hack/remove-kubevirt.sh hack/remove-kubevirt-minikube.sh
sed -i 's/kubectl/minikube -p '$VM_NAME' kubectl --/g' hack/remove-kubevirt-minikube.sh

hack/remove-kubevirt-minikube.sh
if [ $? -ne 0 ]; then
	echo kubevirt deletion test is failed
	echo minikube isnt deleted because of debug
	exit 1
else
	echo kubevirt deletion test is succeeded
	rm hack/remove-kubevirt-minikube.sh
fi

$RUN_CMD "docker run -itd -p 5000:5000 registry:latest"

# push kubevirt images to private registry
image_list=`cat images/kubevirt_images.txt`
for image in $image_list;
do
	image_name=`echo $image | cut -d'/' -f2 | cut -d'.' -f1`:$KUBEVIRT_TAG
	echo uploads $GUEST_BASE_DIR/images/${image}.tar to $LOCAL_REGISTRY/$PREFIX/$image_name
	$RUN_CMD "docker load -i $GUEST_BASE_DIR/images/${image}.tar"
	$RUN_CMD "docker tag $PREFIX/$image_name $LOCAL_REGISTRY/$PREFIX/$image_name"
	$RUN_CMD "docker push $LOCAL_REGISTRY/$PREFIX/$image_name"
	echo done
done
# push virtvnc image to private registry
image=virtvnc
image_name=$image:$VIRTVNC_TAG
echo uploads $GUEST_BASE_DIR/images/${image}.tar to $LOCAL_REGISTRY/$PREFIX/$image_name
$RUN_CMD "docker load -i $GUEST_BASE_DIR/images/${image}.tar"
$RUN_CMD "docker tag $PREFIX/$image_name $LOCAL_REGISTRY/$PREFIX/$image_name"
$RUN_CMD "docker push $LOCAL_REGISTRY/$PREFIX/$image_name"
echo done

# delete images from docker because minikube is single node so that yamls can use cached docker images
$RUN_CMD "docker images -q |xargs docker rmi -f &> /dev/null"

# copy yamls for testing
cp yamls/kubevirt-operator.yaml yamls/kubevirt-operator-minikube.yaml
cp yamls/kubevirt-cr.yaml yamls/kubevirt-cr-minikube.yaml
sed -i 's/'$PREFIX'/'$LOCAL_REGISTRY'\/'$PREFIX'/g' yamls/kubevirt-operator-minikube.yaml
sed -i 's/'$PREFIX'/'$LOCAL_REGISTRY'\/'$PREFIX'/g' yamls/kubevirt-cr-minikube.yaml

# copy installation shell for testing
cp hack/install-kubevirt.sh hack/install-kubevirt-minikube.sh
sed -i 's/kubectl/minikube -p '$VM_NAME' kubectl --/g' hack/install-kubevirt-minikube.sh
sed -i 's/kubevirt-operator/kubevirt-operator-minikube/g' hack/install-kubevirt-minikube.sh
sed -i 's/kubevirt-cr/kubevirt-cr-minikube/g' hack/install-kubevirt-minikube.sh
sed -i 's/sudo/minikube -p '$VM_NAME' ssh sudo/g' hack/install-kubevirt-minikube.sh
sed -i 's/hack\/virtctl/'$GUEST_BASE_DIR_ESCAPE'\/hack\/virtctl/g' hack/install-kubevirt-minikube.sh

# TODO: make function for duplicated log print
hack/install-kubevirt-minikube.sh
if [ $? -ne 0 ]; then
	echo kubevirt installation test with private registry is failed
	echo minikube isnt deleted because of debug
	exit 1
else
	echo kubevirt installation test with private registry is succeeded	
	rm yamls/*minikube.yaml
	rm hack/install-kubevirt-minikube.sh
	minikube delete -p $VM_NAME
fi

