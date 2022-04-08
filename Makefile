.PHONY: create_kind_cluster delete_kind_cluster start_minikube_cluster stop_minikube_cluster create_docker_local_registry build_kubernetesdemo_image build_kubernetesdemoapi_image connect_docker_local_registry_to_kind_network

build_push_images: build_kubernetesdemo_image build_kubernetesdemoapi_image


create_docker_local_registry:
	 docker run -d -p 5000:5000 --restart=always --name local-registry registry:latest

create_kind_cluster:
	kind create cluster --name kubedemocluster --config "D:\Repos\Kubernetes\kind_config.yaml"

delete_kind_cluster:
	kind delete cluster --name kubedemocluster

connect_docker_local_registry_to_kind_network:
	docker network connect kind local-registry


start_minikube_cluster:
	minikube start --insecure-registry "10.0.0.0/24" && \
	minikube addons enable registry && \
	kubectl get pods --namespace kube-system

port_forward_minikube_registrypod:
	kubectl port-forward --namespace kube-system registry-s4h7n 5000:5000

forward_docker_traffic_minikube_registrypod:
	docker run --rm -it --network=host alpine ash -c "apk add socat && socat TCP-LISTEN:5000,reuseaddr,fork TCP:host.docker.internal:5000"

stop_minikube_cluster:
	minikube stop



build_kubernetesdemo_image:
	docker build -t kubernetesdemo:kindv1 -f "D:\TFVS\KubernetesDemo\Dockerfile" "D:\TFVS\KubernetesDemo" && \
	docker image tag kubernetesdemo:kindv1 localhost:5000/kubernetesdemo/kubernetesdemo:kindv1 && \
	docker image push localhost:5000/kubernetesdemo/kubernetesdemo:kindv1


build_kubernetesdemoapi_image:

	docker build -t kubernetesdemoapi:kindv1 -f "D:\TFVS\KubernetesDemoAPI\Dockerfile" "D:\TFVS\KubernetesDemoAPI" && \
	docker image tag kubernetesdemo:kindv1 localhost:5000/kubernetesdemo/kubernetesdemoapi:kindv1 && \
	docker image push localhost:5000/kubernetesdemo/kubernetesdemoapi:kindv1




connect_local_registry_to_kind:
	kubectl apply -f "D:\Repos\Kubernetes\kind_configmap.yaml"

