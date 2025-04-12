# 🔹 Build and Push Docker Images to Docker Hub:
# - The following commands build and push Docker images for different services.
# - Docker Hub is used as the container registry.
# - Services include:
#   - external-binding-sample
#   - orderbackendimage
#   - orderfrontendimage
#   - pubsub-python-subscriber

# 🔹 Commands:
# - Docker build for each service.
# - Docker tag with Docker Hub registry.
# - Docker push to Docker Hub.

# Ensure you're logged into Docker Hub
docker login --username reisenberg123 --password Pr@gProg55

cd ../order_backend
docker build -t orderbackendimage .
docker tag orderbackendimage reisenberg123/orderbackendimage
docker push reisenberg123/orderbackendimage

cd ../order_frontend
docker build -t orderfrontendimage .
docker tag orderfrontendimage reisenberg123/orderfrontendimage
docker push reisenberg123/orderfrontendimage

cd ../python-subscriber
docker build -t pubsub-python-subscriber .
docker tag pubsub-python-subscriber reisenberg123/pubsub-python-subscriber
docker push reisenberg123/pubsub-python-subscriber