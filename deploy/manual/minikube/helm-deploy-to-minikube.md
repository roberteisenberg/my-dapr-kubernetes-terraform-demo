# Create and apply kubernetes secret

ACR_FULL_NAME=containerregistryre.azurecr.io
ACR_SHORT_NAME=containerregistryre
az acr update -n $ACR_FULL_NAME --admin-enabled true --resource-group test-minikube-rg

ACR_USERNAME=$ACR_SHORT_NAME
ACR_PASSWORD=Fxacoa9AuGXQIGJtTpVBIrIcOed408uhx6mhOhlRHo+ACRCUdnR3

# https://stackoverflow.com/questions/57469214/failed-to-pull-image-unauthorized-authentication-required-imagepullbackoff
kubectl create secret docker-registry acr-auth-secret --docker-server=https://containerregistryre.azurecr.io --docker-username=$ACR_USERNAME --docker-password=$ACR_PASSWORD --docker-email=robert@reaa.onmicrsoft.com

# install Redis into cluster
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install redis bitnami/redis --set image.tag=6.2

# install dapr
dapr init --kubernetes --wait
dapr status -k

# run helm to add services to cluster
cd deploy/chart
helm install somename ./sampledapr

# forward backend and zipkins ports
kubectl port-forward service/backendapi 8080:80
kubectl port-forward svc/zipkin 9411:9411

# test the backend service
curl http://localhost:8080/ports
curl --request POST --data "@sample.json" --header Content-Type:application/json http://localhost:8080/neworder
curl http://localhost:8080/order

# expected output
{ "orderId": "42" }


# observe logs
kubectl logs --selector=app=backend -c backend --tail=-1
kubectl logs --selector=app=backend -c daprd --tail=-1
kubectl logs --selector=app=frontend -c daprd --tail=-1
