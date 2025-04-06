# Build the Docker image

docker build -t envoyimage .

az login
az acr login --name containerregistryre

# Tag the Docker image with the Azure Container Registry URL

docker tag envoyimage containerregistryre.azurecr.io/envoyimage

# Push the Docker image to Azure Container Registry

docker push containerregistryre.azurecr.io/envoyimage
