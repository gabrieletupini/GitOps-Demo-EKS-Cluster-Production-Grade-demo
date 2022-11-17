.PHONY: list bootstrap cleanup

list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'



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

install-jira:
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
	kubectl delete appprojects.argoproj.io --all
	kubectl delete applications.argoproj.io --all
	kubectl delete ns demo-app
	kubectl delete ns monitoring
	kubectl delete ns ingress-nginx
	kubectl delete ns cert-manager
	kubectl delete ns logging
	kubectl delete ns velero
