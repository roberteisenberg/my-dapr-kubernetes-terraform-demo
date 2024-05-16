# install Redis into cluster
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install redis bitnami/redis --set image.tag=6.2

# install dapr
dapr init --kubernetes --wait
dapr status -k
kubectl apply -f ./deploy/k8-dapr/redis.yaml
kubectl create deployment zipkin --image openzipkin/zipkin
kubectl expose deployment zipkin --type ClusterIP --port 9411
kubectl apply -f ./deploy/k8-dapr/zipkin.yaml

ACR_FULL_NAME=containerregistryre.azurecr.io
ACR_SHORT_NAME=containerregistryre
az acr update -n $ACR_FULL_NAME --admin-enabled true --resource-group test-minikube-rg

ACR_USERNAME=$ACR_SHORT_NAME
ACR_PASSWORD=Fxacoa9AuGXQIGJtTpVBIrIcOed408uhx6mhOhlRHo+ACRCUdnR3

#docker login containerregistryre.azurecr.io -u containerregistryre

# https://stackoverflow.com/questions/57469214/failed-to-pull-image-unauthorized-authentication-required-imagepullbackoff

kubectl create secret docker-registry acr-auth-secret --docker-server=https://containerregistryre.azurecr.io --docker-username=$ACR_USERNAME --docker-password=$ACR_PASSWORD --docker-email=robert@reaa.onmicrsoft.com

<!-- kubectl create secret docker-registry acr-auth-secret \
        --docker-server=$ACR_FULL_NAME \
        --docker-username=$ACR_USERNAME \
        --docker-password=$ACR_PASSWORD \
        --dry-run=client \
        -o yaml > acr-auth-secret.yaml -->

# deploy node into dapr sidecar
kubectl apply -f ./deploy/k8-dapr/orderbackend.yaml
#this is not the directory 
kubectl rollout status deploy/orderbackendapp

# if running locally (minikube)
kubectl port-forward service/orderbackendapp 8080:80
kubectl port-forward svc/zipkin 9411:9411

# if running on public cloud
kubectl get svc orderbackendapp

# test the node service
curl http://localhost:8080/ports
curl --request POST --data "@sample.json" --header Content-Type:application/json http://localhost:8080/neworder
curl http://localhost:8080/order

# expected output
{ "orderId": "42" }

# frontend app
kubectl apply -f ./deploy/k8-dapr/orderfrontend.yaml

# observe logs

kubectl logs --selector=app=backend -c backend --tail=-1
kubectl logs --selector=app=backend -c daprd --tail=-1
kubectl logs --selector=app=frontend -c daprd --tail=-1
