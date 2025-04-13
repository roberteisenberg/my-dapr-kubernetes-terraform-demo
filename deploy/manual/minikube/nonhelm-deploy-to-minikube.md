<!-- kubectl apply -f ./deploy/k8-dapr/redis.yaml
kubectl create deployment zipkin --image openzipkin/zipkin
kubectl expose deployment zipkin --type ClusterIP --port 9411
kubectl apply -f ./deploy/k8-dapr/zipkin.yaml

# deploy backend into dapr sidecar
kubectl apply -f ./deploy/k8-dapr/orderbackend.yaml
#this is not the directorybackendapi
kubectl rollout status deploy/orderbackendapp -->

<!-- # frontend app
kubectl apply -f ./deploy/k8-dapr/orderfrontend.yaml -->
