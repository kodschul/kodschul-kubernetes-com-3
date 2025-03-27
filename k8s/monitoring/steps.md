```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

helm install prometheus prometheus-community/kube-prometheus-stack -n prometheus

kubectl get pods -n prometheus

kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090 -n prometheus

http://localhost:9090
Benutzername: admin
Passwort: prom-operator (oder das Passwort, das in den Helm-Werten festgelegt wurde).
