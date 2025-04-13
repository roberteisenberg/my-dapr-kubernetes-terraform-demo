# Create and apply kubernetes secret for Docker Hub
# Replace with your Docker Hub credentials
DOCKER_USERNAME=reisenberg123  # Replace with your Docker Hub username
DOCKER_PASSWORD=Pr@gProg55  # Replace with your Docker Hub password

kubectl create secret docker-registry docker-registry-secret \
  --docker-server=https://docker.io \
  --docker-username=$DOCKER_USERNAME \
  --docker-password=$DOCKER_PASSWORD

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
cd ..

# Wait for backendapi and zipkin services to be ready
echo "Waiting for backendapi service..."
until kubectl get service backendapi --output=jsonpath='{.spec.ports}' >/dev/null 2>&1; do
    sleep 2
done
echo "Waiting for zipkin service..."
until kubectl get service zipkin --output=jsonpath='{.spec.ports}' >/dev/null 2>&1; do
    sleep 2
done

# Check if services exist before port forwarding
kubectl get service backendapi || { echo "Error: backendapi service not found"; exit 1; }
kubectl get service zipkin || { echo "Error: zipkin service not found"; exit 1; }

# Forward backend and Zipkin ports
kubectl port-forward service/backendapi 8080:80 & 
PORT_FORWARD_PID1=$!
kubectl port-forward svc/zipkin 9411:9411 &
PORT_FORWARD_PID2=$!

# Test the backend service
curl http://localhost:8080/ports
curl --request POST --data "@sample.json" --header Content-Type:application/json http://localhost:8080/neworder
sleep 2  # Wait for the backend to process the order
curl http://localhost:8080/order

# Expected output
{ "orderId": "42" }

# Clean up port forwarding
kill $PORT_FORWARD_PID1 $PORT_FORWARD_PID2

# Observe logs
kubectl logs --selector=app=backend -c backend --tail=-1
kubectl logs --selector=app=backend -c daprd --tail=-1
kubectl logs --selector=app=frontend -c daprd --tail=-1