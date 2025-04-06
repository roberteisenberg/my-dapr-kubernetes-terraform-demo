#!/bin/bash

# ============================================================
# This script automates the process of setting up a Kubernetes 
# environment using Minikube, enabling necessary addons, 
# creating registry secrets, adding Helm repositories, 
# installing Redis, Nginx, and Dapr, and deploying a sample 
# Dapr application. It also performs cleanup by uninstalling 
# Minikube and Dapr at the end of the process.
# ============================================================

# Function to display a spinner during long-running operations
spinner()
{
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'  # Spinner characters
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"  # Remove spinner character
    done
    printf "    \b\b\b\b"  # Remove spinner and reset position
}

# Function to print a line break
function linebreak {
   printf ' \n '
}

# Create and start a Minikube cluster with specified resources
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

# Enable the dashboard addon in Minikube
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

# Enable the ingress addon in Minikube
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

# Create a secret to authenticate with Docker Registry
create_registry_secret() {
    printf '======== Creating cluster secret for Docker registry. Please wait...  ====== \n'

    # Assuming Docker Hub registry; adjust for other registries
    DOCKER_USERNAME=reisenberg123  # Replace with your Docker Hub username
    DOCKER_PASSWORD=Pr@gProg55  # Replace with your Docker Hub password
    DOCKER_SERVER=docker.io  # Use the default Docker Hub registry, or change for another registry

    kubectl create secret docker-registry docker-registry-secret \
        --docker-server=$DOCKER_SERVER \
        --docker-username=$DOCKER_USERNAME \
        --docker-password=$DOCKER_PASSWORD

    # Wait until the secret is created
    kubectl get secret docker-registry-secret >/dev/null
    while [ $? -ne 0 ]; do
        sleep 1
        kubectl get secret docker-registry-secret >/dev/null
    done
}

# Add the Bitnami Helm repository
add_helm_repo() {
    printf '======== Add bitnami repo. Please wait...  ====== \n'
    helm repo add bitnami https://charts.bitnami.com/bitnami
    # Wait until the repository is added
    helm repo list | grep "bitnami" >/dev/null
    while [ $? -ne 0 ]; do
        sleep 1
        helm repo list | grep "bitnami" >/dev/null
    done
}

# Update the Helm repositories
update_helm_repo() {
    printf '======== Updating helm repo. Please wait...  ====== \n'
    helm repo update
    # Wait until the repository is updated
    helm repo list | grep "bitnami" >/dev/null
    while [ $? -ne 0 ]; do
        sleep 1
        helm repo list | grep "bitnami" >/dev/null
    done
}

# Install Redis using Bitnami Helm chart
install_redis() {
    printf '======== Installing bitnami/redis. Please wait...  ====== \n'

    helm install redis bitnami/redis --set image.tag=6.2
    # Wait until the installation is complete
    kubectl get pods | grep "redis" | grep "1/1" >/dev/null
    while [ $? -ne 0 ]; do
        sleep 1
        kubectl get pods | grep "redis" | grep "1/1" >/dev/null
    done
}

# Install Nginx using Bitnami Helm chart
install_nginx() {
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

# Add Dapr to the Minikube cluster
adding_dapr_to_cluster() {
    printf '======== Adding dapr to cluster. Please wait...  ====== \n'
    dapr init --kubernetes --wait
}

# Deploy a sample Dapr application using Helm chart
update_helm_chart(){
    printf '======== Deploying helm dapr-sample-app chart. Please wait...  ====== \n'
    cd deploy/chart
    helm install dapr-sample-app ./sampledapr
    # Wait until the installation is complete (commented out for now)
    # kubectl get pods | grep "dapr-sample-app" | grep "1/1" >/dev/null
    # while [ $? -ne 0 ]; do
    #     sleep 1
    #     kubectl get pods | grep "dapr-sample-app" | grep "1/1" >/dev/null
    # done

    cd ../..
}

# Clean up the environment by uninstalling Minikube and Dapr
printf '======== Uninstalling minikube and dapr. Please wait...  ====== \n'
minikube delete
dapr uninstall all
docker context use default

# Execute the functions to set up the environment
create_minikube_cluster
enable_add_ons
enable_ingress_addon
create_registry_secret
update_helm_repo
# install_nginx  # Commented out for now
install_redis
add_helm_repo
adding_dapr_to_cluster
update_helm_chart

printf '======== Done!  ====== \n'
