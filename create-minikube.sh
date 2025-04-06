#!/bin/bash

spinner()
{
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

function linebreak {
   printf ' \n '
}

create_minikube_cluster() {
    printf '======== Minikube starting. Please wait...  ====== \n'
    minikube start --cpus=4 --memory=4096

    # Wait until the cluster is ready
    minikube status | grep "Running" >/dev/null
    while [ $? -ne 0 ]; do
        sleep 1
        minikube status | grep "Running" >/dev/null
    done

    printf " Minikube started successfully. "
}

enable_add_ons() {
    printf '======== Enabling dashboardaddon. Please wait...  ====== \n'
    minikube addons enable dashboard

    # Wait until the addon is enabled
    minikube addons list | grep "dashboard" | grep "enabled" >/dev/null
    while [ $? -ne 0 ]; do
        sleep 1
        minikube addons list | grep "dashboard" | grep "enabled" >/dev/null
    done
}
enable_ingress_addon() {
    printf '======== Enabling ingress addon. Please wait...  ====== \n'
    minikube addons enable ingress
    # Wait until the addon is enabled
    minikube addons list | grep "ingress" | grep "enabled" >/dev/null
    while [ $? -ne 0 ]; do
        sleep 1
        minikube addons list | grep "ingress" | grep "enabled" >/dev/null
    done
}

function create_registry_secret() {
    printf '======== Creating cluster secret. Please wait...  ====== \n'
    az acr update -n $ACR_FULL_NAME --admin-enabled true --resource-group test-minikube-rg
    ACR_FULL_NAME=containerregistryre.azurecr.io
    ACR_SHORT_NAME=containerregistryre
    ACR_USERNAME=$ACR_SHORT_NAME
    ACR_PASSWORD=foDCxyfogI43r8zB5CnTX+kkTNf16HaJLRVmYdmriQ+ACRBqC1tJ

    kubectl create secret docker-registry acr-auth-secret --docker-server=https://containerregistryre.azurecr.io --docker-username=$ACR_USERNAME --docker-password=$ACR_PASSWORD --docker-email=robert@reaa.onmicrsoft.com

    # Wait until the secret is created
    kubectl get secret acr-auth-secret >/dev/null
    while [ $? -ne 0 ]; do
        sleep 1
        kubectl get secret acr-auth-secret >/dev/null
done
}

function add_helm_repo() {
    printf '======== Add bitnami repo. Please wait...  ====== \n'
    helm repo add bitnami https://charts.bitnami.com/bitnami
    # Wait until the repository is added
    helm repo list | grep "bitnami" >/dev/null
    while [ $? -ne 0 ]; do
        sleep 1
        helm repo list | grep "bitnami" >/dev/null
    done
}

function update_helm_repo() {
    printf '======== Updating helm repo. Please wait...  ====== \n'
    helm repo update
    # Wait until the repository is updated
    helm repo list | grep "bitnami" >/dev/null
    while [ $? -ne 0 ]; do
        sleep 1
        helm repo list | grep "bitnami" >/dev/null
    done
}

function install_redis() {
    printf '======== Installing bitnami/redis. Please wait...  ====== \n'

    helm install redis bitnami/redis --set image.tag=6.2
    # Wait until the installation is complete
    kubectl get pods | grep "redis" | grep "1/1" >/dev/null
    while [ $? -ne 0 ]; do
        sleep 1
        kubectl get pods | grep "redis" | grep "1/1" >/dev/null
    done
}

function install_nginx() {
    printf '======== Installing bitnami/nginx. Please wait...  ====== \n'

    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    # Wait until the installation is complete
    kubectl get pods | grep "nginx" | grep "1/1" >/dev/null
    while [ $? -ne 0 ]; do
        sleep 1
        printf '======== nginx sleeping...  ====== \n'
        kubectl get pods | grep "nginx" | grep "1/1" >/dev/null
    done
}


function adding_dapr_to_cluster() {
    printf '======== Adding dapr to cluster. Please wait...  ====== \n'
    dapr init --kubernetes --wait
}

function update_helm_chart(){
    printf '======== Deploying helm dapr-sample-app chart. Please wait...  ====== \n'
    cd deploy/chart
    helm install dapr-sample-app ./sampledapr
    # # Wait until the installation is complete
    # kubectl get pods | grep "dapr-sample-app" | grep "1/1" >/dev/null
    # while [ $? -ne 0 ]; do
    #     sleep 1
    #     kubectl get pods | grep "dapr-sample-app" | grep "1/1" >/dev/null
    # done

    cd ../..

}


printf '======== Uninstalling minikube and dapr. Please wait...  ====== \n'
minikube delete
dapr uninstall all
docker context use default

create_minikube_cluster
enable_add_ons
enable_ingress_addon

create_registry_secret
update_helm_repo
# install_nginx
install_redis
#    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.3/deploy/static/provider/cloud/deploy.yaml

add_helm_repo
adding_dapr_to_cluster
update_helm_chart
printf '======== Done!  ====== \n'

