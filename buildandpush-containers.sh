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

# Ensure you're logged into Docker Hub
docker login --username reisenberg123 --password Pr@gProg55

cd external-binding
docker build -t reisenberg123/external-binding-sample:1.0 .
docker push reisenberg123/external-binding-sample:1.0

cd ../order_backend
docker build -t reisenberg123/dapr-traffic-control-order-backend:1.0 .
docker push reisenberg123/dapr-traffic-control-order-backend:1.0

cd ../order_frontend
docker build -t reisenberg123/dapr-traffic-control-order-frontend:1.0 .
docker push reisenberg123/dapr-traffic-control-order-frontend:1.0

cd ../python-subscriber
docker build -t reisenberg123/dapr-traffic-control-python-subscriber:1.0 .
docker push reisenberg123/dapr-traffic-control-python-subscriber:1.0