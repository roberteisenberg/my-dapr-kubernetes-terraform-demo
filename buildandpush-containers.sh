#!/bin/bash

# 🔹 Build and Push Docker Images to Docker Hub:
# - The following commands build and push Docker images for different services.
# - Docker Hub is used as the container registry.
# - Services include:
#   - external-binding-sample
#   - dapr-traffic-control-order-backend
#   - dapr-traffic-control-order-frontend
#   - dapr-traffic-control-python-subscriber

# 🔹 Commands:
# - Docker build for each service.
# - Docker push to Docker Hub.

# Exit on error
set -e

# Ensure DOCKER_PAT environment variable is set
if [ -z "$DOCKER_PAT" ]; then
    echo "Error: DOCKER_PAT environment variable is not set. Please set it with your Docker Hub personal access token."
    exit 1
fi

# Ensure you're logged into Docker Hub
echo "Logging into Docker Hub..."
docker login --username reisenberg123 --password "$DOCKER_PAT" || {
    echo "Error: Docker login failed. Please check your personal access token."
    exit 1
}

# Array of directories containing Dockerfiles
SERVICES=("external-binding" "order_backend" "order_frontend" "python-subscriber")

# Loop through each service and build/push the Docker image
for SERVICE in "${SERVICES[@]}"; do
    echo "Building and pushing Docker image for $SERVICE..."

    # Check if the directory exists
    if [ ! -d "$SERVICE" ]; then
        echo "Error: Directory $SERVICE does not exist."
        exit 1
    fi

    # Navigate to the service directory
    cd "$SERVICE" || {
        echo "Error: Failed to change directory to $SERVICE."
        exit 1
    }

    # Build the Docker image
    IMAGE_NAME="reisenberg123/dapr-traffic-control-${SERVICE//_/-}:1.0"
    # Special case for external-binding
    if [ "$SERVICE" = "external-binding" ]; then
        IMAGE_NAME="reisenberg123/external-binding-sample:1.0"
    fi
    docker build -t "$IMAGE_NAME" . || {
        echo "Error: Failed to build Docker image for $SERVICE."
        exit 1
    }

    # Push the Docker image to Docker Hub
    docker push "$IMAGE_NAME" || {
        echo "Error: Failed to push Docker image $IMAGE_NAME to Docker Hub."
        exit 1
    }

    # Navigate back to the root directory
    cd .. || {
        echo "Error: Failed to change directory back to root."
        exit 1
    }
done

echo "All Docker images have been built and pushed successfully."