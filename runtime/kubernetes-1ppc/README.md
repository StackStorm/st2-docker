# Running StackStorm on Kubernetes using 1ppc

## QuickStart

Tested environment:

- Mac
    - minikube version: v0.21.0
    - Kubernetes v1.7.0

```
# Run following commands in the same directory as this README.md

# Start minikube cluster
# Note: Allow assigning 443 for NodePort service, in order to access st2web
minikube start --vm-driver=xhyve --extra-config=apiserver.ServiceNodePortRange=443-32767 \
  --memory=4096 --cpus=2

# Check cluster is ready...
kubectl get pods --all-namespaces

# Run
kubectl apply -Rf .

# Access Web UI
# Note: You can find default credentials in configmaps.yaml
minikube service st2web --https
```
