### windows

```
choco install kubernetes-helm
```

### macos

```
brew install helm
```

# Kubernetes Dashboard

-> Add kubernetes-dashboard repository

```
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
```

-> Deploy a Helm Release named "kubernetes-dashboard" using the kubernetes-dashboard chart

```
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard
```

# Pod Forwarding

-> Pod Name kriegen

```
kubectl get pods -n kubernetes-dashboard
```

-> Pod forwording

```
kubectl -n kubernetes-dashboard port-forward $POD_NAME 8070:8443
```

-> Token kriegen

```
kubectl apply -f config.yml
```

```
kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath={".data.token"} | base64 -d
```

for windows

```
kubectl describe secret/admin-user -n kubernetes-dashboard
```
