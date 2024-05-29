# Build the Docker image

docker build -t external-binding-sample .

az login
az acr login --name containerregistryre

# Tag the Docker image with the Azure Container Registry URL

docker tag external-binding-sample containerregistryre.azurecr.io/external-binding-sample

# Push the Docker image to Azure Container Registry

docker push containerregistryre.azurecr.io/external-binding-sample
