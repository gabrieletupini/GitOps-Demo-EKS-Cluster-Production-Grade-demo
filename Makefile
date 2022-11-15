.PHONY: list bootstrap cleanup

list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

install-argocd:
	kubectl create ns argocd || true
	helm repo add bitnami https://charts.bitnami.com/bitnami 
	helm install --namespace argocd argo-cd bitnami/argo-cd 

check-argocd-ready:
	kubectl wait --for=condition=available deployment -l "app.kubernetes.io/name=argo-cd" -n argocd --timeout=300s

# It is required to login into ArgoCD CLI to be able to deploy the applications
proxy-argocd:
	kubectl port-forward --namespace argocd svc/argo-cd-server 8080:80 &
	export URL=http://127.0.0.1:8080/
	echo "Argo CD URL: http://127.0.0.1:8080/"

bootstrap: add-helm-repo install-demo-app install-prometheus install-grafana install-ingress-nginx install-cert-manager install-fluentd install-elasticsearch install-kibana install-sealed-secrets install-velero 

add-helm-repo:
	argocd repo add https://github.com/gabrieletupini/GitOps-Demo-EKS-Cluster-Production-Grade-demo

install-demo-app:
	kubectl create namespace demo-app || true
	argocd app create demo-app \
	--repo https://github.com/gabrieletupini/GitOps-Demo-EKS-Cluster-Production-Grade-demo \
	--path app \
	--dest-namespace demo-app \
	--dest-server https://kubernetes.default.svc 
	argocd app sync demo-app

install-prometheus:
	kubectl create namespace monitoring || true
	argocd app create prometheus \
	--repo https://github.com/gabrieletupini/GitOps-Demo-EKS-Cluster-Production-Grade-demo \
	--path charts/kube-prometheus --dest-namespace monitoring \
	--dest-server https://kubernetes.default.svc 
	argocd app sync prometheus

install-grafana:
	argocd app create grafana \
	--repo https://github.com/gabrieletupini/GitOps-Demo-EKS-Cluster-Production-Grade-demo \
	--path charts/grafana --dest-namespace monitoring \
	--dest-server https://kubernetes.default.svc 
	argocd app sync grafana

install-ingress-nginx:
	kubectl create namespace ingress-nginx || true
	argocd app create ingress-nginx \
	--repo https://github.com/gabrieletupini/GitOps-Demo-EKS-Cluster-Production-Grade-demo \
	--path charts/nginx-ingress-controller --dest-namespace ingress-nginx \
	--dest-server https://kubernetes.default.svc 
	argocd app sync ingress-nginx

install-cert-manager:
	kubectl create namespace cert-manager || true
	argocd app create cert-manager \
	--repo https://github.com/gabrieletupini/GitOps-Demo-EKS-Cluster-Production-Grade-demo \
	--path charts/cert-manager --dest-namespace cert-manager \
	--dest-server https://kubernetes.default.svc 	
	argocd app sync cert-manager
	kubectl wait --for=condition=available deployment -l "app.kubernetes.io/instance=cert-manager" -n cert-manager --timeout=600s
	kubectl apply -f app-layer/ssl-setup/cert-issuer-nginx-ingress.yaml

install-fluentd:
	kubectl create namespace logging || true
	argocd app create fluentd \
	--repo https://github.com/gabrieletupini/GitOps-Demo-EKS-Cluster-Production-Grade-demo \
	--path charts/fluentd --dest-namespace logging \
	--dest-server https://kubernetes.default.svc 
	argocd app sync fluentd

install-elasticsearch:
	argocd app create elasticsearch \
	--repo https://github.com/gabrieletupini/GitOps-Demo-EKS-Cluster-Production-Grade-demo \
	--path charts/elasticsearch --dest-namespace logging \
	--dest-server https://kubernetes.default.svc 
	argocd app sync elasticsearch

install-kibana:
	argocd app create kibana \
	--repo https://github.com/gabrieletupini/GitOps-Demo-EKS-Cluster-Production-Grade-demo \
	--path charts/kibana --dest-namespace logging \
	--dest-server https://kubernetes.default.svc 
	argocd app sync kibana

install-sealed-secrets:
	argocd app create sealed-secrets \
	--repo https://github.com/gabrieletupini/GitOps-Demo-EKS-Cluster-Production-Grade-demo \
	--path charts/sealed-secrets --dest-namespace kube-system \
	--dest-server https://kubernetes.default.svc 
	argocd app sync sealed-secrets

install-velero:
	kubectl create namespace velero || true
	kubectl create secret generic -n velero credentials --from-file=cloud=credentials
	argocd app create velero \
	--repo https://github.com/gabrieletupini/GitOps-Demo-EKS-Cluster-Production-Grade-demo \
	--path charts/velero --dest-namespace velero \
	--dest-server https://kubernetes.default.svc 
	argocd app sync velero

cleanup:
	helm delete argocd || true
	kubectl delete appprojects.argoproj.io --all
	kubectl delete applications.argoproj.io --all
	kubectl delete ns argocd
	kubectl delete ns demo-app
	kubectl delete ns monitoring
	kubectl delete ns ingress-nginx
	kubectl delete ns cert-manager
	kubectl delete ns logging
	kubectl delete ns velero
