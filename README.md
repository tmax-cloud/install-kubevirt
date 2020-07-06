# kubevirt-installer

이 프로젝트는 폐쇄망 환경을 포함한 [kubernetes](https://github.com/kubernetes/kubernetes) 환경에 [kubevirt](https://github.com/kubevirt/kubevirt)를 인스톨하기 위한 인스톨러입니다. 

# 사용법
## Kubevirt Installation
### prerequisite
* kubevirt 설치를 위한 image들이 저장될 registry가 생성되어 있어야 합니다. 또한 각 노드가 해당 registry에 접근할 수 있어야 합니다.
### usage
* private network 환경일 경우
    1. 인터넷이 되는 환경에서 ```make download```를 수행하여 설치에 필요한 이미지들을 docker hub로부터 다운로드합니다. 
    2. $REGISTRY_ENDPOINT 환경변수에 image가 저장될 private registry 주소를 입력합니다.\
      ```export REGISTRY_ENDPOINT={registry url}```\
      ```ex) export REGISTRY_ENDPOINT=10.0.0.1:5000
    3. ```make upload```를 수행하여 images 디렉토리에 있는 image tar 파일들을 private registry에 push합니다.
    4. ```make install``` 을 수행하여 설치를 진행합니다.
* public network 환경일 경우
    1. ```make install``` 을 수행하여 설치를 진행합니다.

## Kubevirt Uninstallation
### usage
* ```make uninstall```을 수행하여 언인스톨을 진행합니다.

## Installer Test
### prerequisite
* test에는 [minikube](https://github.com/kubernetes/minikube)가 사용되므로 VM을 생성할 수 있는 환경이어야 합니다. 관련하여 [minikube install guide]([https://minikube.sigs.k8s.io/docs/start/](https://minikube.sigs.k8s.io/docs/start/))를 참고하세요.
* 배포된 kubevirt 환경에서 VM 생성 테스트를 위해선 nested virtualization option이 켜져있는지 확인해야 합니다.  [Nested Virtualization](https://docs.fedoraproject.org/en-US/quick-docs/using-nested-virtualization-in-kvm/) 을 참고하세요.\
  ```cat /sys/module/kvm_intel/parameters/nested``` 
  위의 명령어의 결과가 Y가 나오면 정상적으로 설정된 것입니다.
### usage
1. $MINIKUBE_CPU 환경변수에 minikube의 virtual cpu 수를 설정합니다. default는 2048로 설정되어 있습니다.\
  ```export MINIKUBE_CPU={virtual cpu 수}```\
  ```ex) export MINIKUBE_CPU=2``` 
2. $MINIKUBE_MEMORY 환경변수에 minikube의 memory를 설정합니다. default는 2048(MB)로 설정되어 있습니다.\
  ```export MINIKUBE_MEMORY={memory 크기}```\
  ```ex) export MINIKUBE_MEMORY=2048``` 
3. test 하고자 하는 image tar 파일들을 images 디렉토리에 옮깁니다.
4. ```make test```  를 수행하여 테스트를 실행합니다.

* 총 3가지의 테스트가 수행됩니다.
    * docker hub로부터 이미지를 받아서 kubevirt 인스톨 수행 테스트
    * kubevirt 언인스톨 수행 테스트
    * private registry로 이미지를 업로드하여, 해당 registry를 이용하여 kubevirt 인스톨 수행 테스트

## Developer Guide
- TODO