#!/bin/bash

REGISTRY=${REGISTRY_ENDPOINT:-localhost:5000}

function push_image() {
	image=$1
	image_name=$2
	docker load -i images/${image}.tar
	docker tag $image_name $REGISTRY/$image_name
	docker push $REGISTRY/$image_name 
}

image_list=`cat images/kubevirt_images.txt`
for image in $image_list;
do
	image_name=${PREFIX}/${image}:$KUBEVIRT_TAG
	push_image $image $image_name
done

image=virtvnc
image_name=${PREFIX}/${image}:$VIRTVNC_TAG
push_image $image $image_name
