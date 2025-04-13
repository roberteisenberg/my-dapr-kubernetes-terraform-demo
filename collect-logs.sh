#!/bin/bash

# Script to automate log collection for Kubernetes pods
# Usage: ./collect-logs.sh [--namespace <namespace>] [--pods <pod1,pod2,...>] [--containers <container1,container2,...>]
# Example: ./collect-logs.sh --namespace default --pods orderfrontendapp-6767bb8d54-pnzxj,python-subscriber-6745d57bc9-9hj5h --containers daprd

# Default values
NAMESPACE="default"
PODS=""
CONTAINERS="daprd"  # Default container to collect logs from
OUTPUT_DIR="logs-$(date +%Y%m%d-%H%M%S)"

# Function to display usage
usage() {
    echo "Usage: $0 [--namespace <namespace>] [--pods <pod1,pod2,...>] [--containers <container1,container2,...>]"
    echo "Example: $0 --namespace default --pods orderfrontendapp-6767bb8d54-pnzxj,python-subscriber-6745d57bc9-9hj5h --containers daprd"
    exit 1
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --namespace) NAMESPACE="$2"; shift ;;
        --pods) PODS="$2"; shift ;;
        --containers) CONTAINERS="$2"; shift ;;
        *) usage ;;
    esac
    shift
done

# Validate inputs
if [ -z "$PODS" ]; then
    echo "Error: No pods specified. Use --pods to specify pod names (comma-separated)."
    usage
fi

# Convert comma-separated lists to arrays
IFS=',' read -r -a POD_ARRAY <<< "$PODS"
IFS=',' read -r -a CONTAINER_ARRAY <<< "$CONTAINERS"

# Create output directory
mkdir -p "$OUTPUT_DIR"
echo "Collecting logs in directory: $OUTPUT_DIR"

# Collect general pod status
echo "Collecting pod status..."
kubectl get pods -n "$NAMESPACE" > "$OUTPUT_DIR/pod-status.txt"

# Collect pod descriptions and logs for each specified pod
for POD in "${POD_ARRAY[@]}"; do
    echo "Collecting data for pod: $POD"

    # Collect pod description
    kubectl describe pod "$POD" -n "$NAMESPACE" > "$OUTPUT_DIR/describe-$POD.txt"

    # Collect logs for each specified container in the pod
    for CONTAINER in "${CONTAINER_ARRAY[@]}"; do
        echo "Collecting logs for container $CONTAINER in pod $POD..."
        kubectl logs "$POD" -c "$CONTAINER" -n "$NAMESPACE" > "$OUTPUT_DIR/logs-$POD-$CONTAINER.txt" 2>&1
    done
done

# Optionally collect Dapr control plane logs (dapr-system namespace)
echo "Collecting Dapr control plane pod status..."
kubectl get pods -n dapr-system > "$OUTPUT_DIR/dapr-system-pod-status.txt"

# Collect logs for Dapr control plane components (operator and sidecar-injector)
echo "Collecting Dapr control plane logs..."
OPERATOR_POD=$(kubectl get pods -n dapr-system --selector=app=dapr-operator -o jsonpath='{.items[0].metadata.name}')
SIDECAR_POD=$(kubectl get pods -n dapr-system --selector=app=dapr-sidecar-injector -o jsonpath='{.items[0].metadata.name}')

if [ -n "$OPERATOR_POD" ]; then
    kubectl logs "$OPERATOR_POD" -n dapr-system > "$OUTPUT_DIR/logs-dapr-operator.txt" 2>&1
else
    echo "Warning: dapr-operator pod not found" >> "$OUTPUT_DIR/logs-dapr-operator.txt"
fi

if [ -n "$SIDECAR_POD" ]; then
    kubectl logs "$SIDECAR_POD" -n dapr-system > "$OUTPUT_DIR/logs-dapr-sidecar-injector.txt" 2>&1
else
    echo "Warning: dapr-sidecar-injector pod not found" >> "$OUTPUT_DIR/logs-dapr-sidecar-injector.txt"
fi

echo "Log collection complete. Files are saved in: $OUTPUT_DIR"