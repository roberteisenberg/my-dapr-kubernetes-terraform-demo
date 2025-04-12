# Create and apply kubernetes secret for Docker Hub
# Replace with your Docker Hub credentials
DOCKER_USERNAME=your_docker_username  # Replace with your Docker Hub username
DOCKER_PASSWORD=your_docker_password  # Replace with your Docker Hub password
DOCKER_EMAIL=your_email@example.com   # Replace with your email

kubectl create secret docker-registry docker-registry-secret \
  --docker-server=https://docker.io \
  --docker-username=$DOCKER_USERNAME \
  --docker-password=$DOCKER_PASSWORD \
  --docker-email=$DOCKER_EMAIL

# Install Redis into cluster
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install redis bitnami/redis --set image.tag=6.2

# Install Dapr
dapr init --kubernetes --wait
dapr status -k

# Run Helm to add services to cluster
cd deploy/chart
helm install dapr-sample-app ./sampledapr

# Forward backend and Zipkin ports
kubectl port-forward service/backendapi 8080:80
kubectl port-forward svc/zipkin 9411:9411

# Test the backend service
curl http://localhost:8080/ports
curl --request POST --data "@sample.json" --header Content-Type:application/json http://localhost:8080/neworder
curl http://localhost:8080/order

# Expected output
{ "orderId": "42" }

# Observe logs
kubectl logs --selector=app=backend -c backend --tail=-1
kubectl logs --selector=app=backend -c daprd --tail=-1
kubectl logs --selector=app=frontend -c daprd --tail=-1