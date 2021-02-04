#!make

include hack/config
export $(shell sed 's/=.*//' hack/config)

all: help

help:     ## show available command list
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

install:  ## installs kubevirt
	hack/install-kubevirt.sh

uninstall: ## uninstalls kubevirt
	hack/remove-kubevirt.sh

test:     ## tests installer using minikube
	hack/test.sh

download: ## download images that is listed in images/image_list from docker hub
	hack/download-images.sh

upload:   ## upload images in images directory to docker hub
	hack/upload-images.sh
