# remove existing instance
minikube delete
dapr uninstall all

# to be used in case of errors
#gets out of sync sometimes and causes many problems. https://github.com/kubernetes/minikube/issues/16788
docker context use default

# Create minikube cluster
minikube start --cpus=4 --memory=4096
minikube addons enable dashboard
minikube addons enable ingress

