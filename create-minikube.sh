#!/bin/bash

# ============================================================
# This script automates the process of setting up a Kubernetes 
# environment using Minikube, enabling necessary addons, 
# creating registry secrets, adding Helm repositories, 
# installing Redis and Dapr, deploying a sample Dapr application,
# testing the deployment, and inspecting logs. It also includes
# optional cleanup at the end of the process.
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
    printf '======== Enabling dashboard addon. Please wait...  ====== \n'
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

create_registry_secret() {
    printf '======== Creating cluster secret for Docker registry. Please wait...  ====== \n'

    # Assuming Docker Hub registry; adjust for other registries
    DOCKER_USERNAME=reisenberg123
    DOCKER_PASSWORD=$DOCKER_PAT
    DOCKER_SERVER=docker.io

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

# Add Dapr to the Minikube cluster
adding_dapr_to_cluster() {
    printf '======== Adding dapr to cluster. Please wait...  ====== \n'
    dapr init --kubernetes --wait
    # Wait until Dapr is ready
    dapr status -k | grep "True" >/dev/null
    while [ $? -ne 0 ]; do
        sleep 1
        dapr status -k | grep "True" >/dev/null
    done
}

# Deploy a sample Dapr application using Helm chart
update_helm_chart(){
    printf '======== Deploying helm dapr-sample-app chart. Please wait...  ====== \n'
    cd deploy/chart
    helm install dapr-sample-app ./sampledapr

    # Wait for pods to be ready, with a timeout
    echo "Waiting for backend pod to be ready..."
    for i in {1..60}; do  # Timeout after 120 seconds (60 * 2s)
        if kubectl get pods | grep "backend" | grep "2/2" >/dev/null; then
            break
        fi
        sleep 2
    done
    if ! kubectl get pods | grep "backend" | grep "2/2" >/dev/null; then
        echo "Warning: backend pod not ready after 120 seconds"
        kubectl get pods | grep "backend"
    fi

    echo "Waiting for orderfrontendapp pod to be ready..."
    for i in {1..60}; do
        if kubectl get pods | grep "orderfrontendapp" | grep "2/2" >/dev/null; then
            break
        fi
        sleep 2
    done
    if ! kubectl get pods | grep "orderfrontendapp" | grep "2/2" >/dev/null; then
        echo "Warning: orderfrontendapp pod not ready after 120 seconds"
        kubectl get pods | grep "orderfrontendapp"
    fi

    echo "Waiting for python-subscriber pod to be ready..."
    for i in {1..60}; do
        if kubectl get pods | grep "python-subscriber" | grep "2/2" >/dev/null; then
            break
        fi
        sleep 2
    done
    if ! kubectl get pods | grep "python-subscriber" | grep "2/2" >/dev/null; then
        echo "Warning: python-subscriber pod not ready after 120 seconds"
        kubectl get pods | grep "python-subscriber"
    fi

    cd ../..
}

# Wait for services and port-forward
port_forward_and_test() {
    printf '======== Waiting for services and setting up port forwarding...  ====== \n'

    # Wait for backendapi and zipkin services to be ready
    echo "Waiting for backendapi service..."
    until kubectl get service backendapi --output=jsonpath='{.spec.ports}' >/dev/null 2>&1; do
        sleep 2
    done
    echo "Waiting for zipkin service..."
    until kubectl get service zipkin --output=jsonpath='{.spec.ports}' >/dev/null 2>&1; do
        sleep 2
    done

    # Check if services exist before port forwarding
    kubectl get service backendapi || { echo "Error: backendapi service not found"; exit 1; }
    kubectl get service zipkin || { echo "Error: zipkin service not found"; exit 1; }

    # Forward backend and Zipkin ports
    kubectl port-forward service/backendapi 8080:80 &
    PORT_FORWARD_PID1=$!
    kubectl port-forward svc/zipkin 9411:9411 &
    PORT_FORWARD_PID2=$!

    # Test the backend service
    printf '======== Testing backend service...  ====== \n'
    sleep 2  # Give port forwarding a moment to establish
    curl http://localhost:8080/ports || echo "Warning: /ports endpoint failed"
    curl --request POST --data "@deploy/sample.json" --header Content-Type:application/json http://localhost:8080/neworder
    sleep 2  # Wait for the backend to process the order
    curl http://localhost:8080/order

    # Expected output
    printf 'Expected output: { "orderId": "42" }\n'

    # Clean up port forwarding
    kill $PORT_FORWARD_PID1 $PORT_FORWARD_PID2
}

# Observe logs
observe_logs() {
    printf '======== Observing logs...  ====== \n'
    kubectl logs --selector=app=backend -c backend --tail=-1
    kubectl logs --selector=app=backend -c daprd --tail=-1
    kubectl logs --selector=app=frontend -c daprd --tail=-1
}

# Clean up the environment (commented out for testing)
cleanup() {
    printf '======== Uninstalling minikube and dapr. Please wait...  ====== \n'
    minikube delete
    dapr uninstall all
    docker context use default
}

# Execute the functions to set up the environment
printf '======== Cleaning up previous instances...  ====== \n'
minikube delete
dapr uninstall all
docker context use default

create_minikube_cluster
enable_add_ons
enable_ingress_addon
create_registry_secret
update_helm_repo
install_redis
add_helm_repo
adding_dapr_to_cluster
update_helm_chart
port_forward_and_test
observe_logs

# Uncomment the following line if you want to clean up after testing
# cleanup

printf '======== Done!  ====== \n'