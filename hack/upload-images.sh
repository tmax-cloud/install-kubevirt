#!/bin/bash

REGISTRY=${REGISTRY_ENDPOINT:-localhost:5000}

image_list=`cat images/image_list.txt`
for image in $image_list;
do
	image_name=${PREFIX}/${image}:$TAG
	docker load -i images/${image}.tar
	docker tag $image_name $REGISTRY/$image_name
	docker push $REGISTRY/$image_name 
done
