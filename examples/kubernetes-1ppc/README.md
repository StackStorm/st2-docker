# Running StackStorm on Kubernetes using 1ppc

## QuickStart

Tested environment:

- Mac
    - minikube version: v0.19.1
    - Kubernetes v1.6.4

```
# Start minikube cluster
# Note: Allow assigning 443 for NodePort service, in order to access st2web
minikube start --driver=xhyve --extra-config=apiserver.ServiceNodePortRange=443-32767

# Build 1ppc image
eval $(minikube docker-env)
docker build -t stackstorm/stackstorm-1ppc ../../images/stackstorm-1ppc

# Check cluster is ready...
kubectl get pods --all-namespaces

# Run
kubectl apply -Rf .

# Access Web UI
minikube service st2web --https
```
