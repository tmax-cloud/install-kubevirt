#!/bin/bash

while read image
do
	image_name=${PREFIX}/${image}:$TAG
	docker pull $image_name
	docker save -o images/${image}.tar $image_name
done < images/image_list.txt
