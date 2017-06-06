```
minikube start --extra-config=apiserver.ServiceNodePortRange=443-32767
minikube dashboard

# optional: weave-scope
kubectl apply -f 'https://cloud.weave.works/launch/k8s/weavescope.yaml'
kubectl edit svc/weave-scope-app
# change type from ClusterIP to NodePort
# ... and launch webui
minikube service weave-scope-app

kubectl create -f mongo
kubectl create -f rabbitmq
kubectl create -f postgres
kubectl create -f redis

kubectl create -f setup/setup_postgres.yml

kubectl create -f st2
minikube service st2 --https

# to access rabbitmq dashboard
minikube service rabbitmq-management
# user: guest
# pass: guest
```

