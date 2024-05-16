# Build the Docker image

docker build -t orderbackendimage .

az login
az acr login --name containerregistryre

# Tag the Docker image with the Azure Container Registry URL

docker tag orderbackendimage containerregistryre.azurecr.io/orderbackendimage

# Push the Docker image to Azure Container Registry

docker push containerregistryre.azurecr.io/orderbackendimage
