#!/bin/bash

function save_image() {
	image=$1
	image_name=$2
	docker pull $image_name
	docker save -o images/${image}.tar $image_name
}

# download kubevirt images
while read image
do
	image_name=${PREFIX}/${image}:$KUBEVIRT_TAG
	save_image $image $image_name
done < images/kubevirt_images.txt

# download virtvnc image
image=virtvnc
image_name=${PREFIX}/$image:$VIRTVNC_TAG
save_image $image $image_name
