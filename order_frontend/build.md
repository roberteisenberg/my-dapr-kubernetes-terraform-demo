# Build the Docker image

docker build -t orderfrontendimage .

az login
az acr login --name containerregistryre

# Tag the Docker image with the Azure Container Registry URL

docker tag orderfrontendimage containerregistryre.azurecr.io/orderfrontendimage

# Push the Docker image to Azure Container Registry

docker push containerregistryre.azurecr.io/orderfrontendimage
