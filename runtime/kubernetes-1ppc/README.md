# Running StackStorm on Kubernetes using 1ppc

## Note

`kubernetes-1ppc` is deprecated and will be removed early next year, in favor of the official
stackstorm-ha helm chart available at [helm.stackstorm.com](https://helm.stackstorm.com).

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
