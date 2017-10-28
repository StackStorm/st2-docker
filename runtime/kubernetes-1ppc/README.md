# Running StackStorm on Kubernetes using 1ppc

## QuickStart

Tested environment:

- Mac
    - minikube version: v0.23.0
    - Kubernetes v1.8.0

```
# Run following commands in the same directory as this README.md

# Start minikube cluster
minikube start --vm-driver=xhyve --memory=4096 --cpus=2

# Check cluster is ready...
kubectl get pods --all-namespaces

# Run
kubectl apply -Rf .

# Access Web UI
# Note: You can find default credentials in configmaps.yaml
minikube service st2web --https
```
