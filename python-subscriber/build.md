# Build the Docker image

docker build -t pubsub-python-subscriber .

az login
az acr login --name containerregistryre

# Tag the Docker image with the Azure Container Registry URL

docker tag pubsub-python-subscriber containerregistryre.azurecr.io/pubsub-python-subscriber

# Push the Docker image to Azure Container Registry

docker push containerregistryre.azurecr.io/pubsub-python-subscriber
