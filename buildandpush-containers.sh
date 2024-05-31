az login
az acr login --name containerregistryre

cd external-binding
docker build -t external-binding-sample .
docker tag external-binding-sample containerregistryre.azurecr.io/external-binding-sample
docker push containerregistryre.azurecr.io/external-binding-sample

cd ../order_backend
docker build -t orderbackendimage .
docker tag orderbackendimage containerregistryre.azurecr.io/orderbackendimage
docker push containerregistryre.azurecr.io/orderbackendimage

cd ../order_frontend
docker build -t orderfrontendimage .
docker tag orderfrontendimage containerregistryre.azurecr.io/orderfrontendimage
docker push containerregistryre.azurecr.io/orderfrontendimage

cd ../python-subscriber
docker build -t pubsub-python-subscriber .
docker tag pubsub-python-subscriber containerregistryre.azurecr.io/pubsub-python-subscriber
docker push containerregistryre.azurecr.io/pubsub-python-subscriber




