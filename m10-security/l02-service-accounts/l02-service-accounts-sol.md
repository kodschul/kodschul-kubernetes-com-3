# Lab 10.2 – Lösung: ServiceAccounts

Fertiger Stand: [`project/examples/m10-security/l02-service-accounts/`](../../project/examples/m10-security/l02-service-accounts/)

## Aufgabe 1: ServiceAccount, Role, Test-Pod

`playground/k8s/service-account.yaml` (ergänzte Stellen):

```yaml
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list", "watch"]
...
subjects:
  - kind: ServiceAccount
    name: hello-reader
    namespace: hello
```

`playground/k8s/api-test-pod.yaml`:

```yaml
spec:
  serviceAccountName: hello-reader
  containers:
    - name: curl
      image: curlimages/curl:8.23.0
      command: ["sleep", "3600"]
```

```bash
kubectl apply -f playground/k8s/service-account.yaml -f playground/k8s/api-test-pod.yaml
kubectl get serviceaccount,role,rolebinding -n hello
kubectl get pod api-test -n hello -o jsonpath='{.spec.serviceAccountName}'
```

```text
serviceaccount/hello-reader created
role.rbac.authorization.k8s.io/pod-reader created
rolebinding.rbac.authorization.k8s.io/hello-reader-pod-reader created
pod/api-test created

NAME                          SECRETS   AGE
serviceaccount/default        0         2d
serviceaccount/hello-reader   0         5s

NAME                                        CREATED AT
role.rbac.authorization.k8s.io/pod-reader   2026-11-17T12:48:10Z

NAME                                                            ROLE              AGE
rolebinding.rbac.authorization.k8s.io/hello-reader-pod-reader   Role/pod-reader   5s

hello-reader
```

`SECRETS 0`: Es gibt kein dauerhaftes Token-Secret; Pods bekommen projizierte Tokens.

## Aufgabe 2: Rechte von außen prüfen

```bash
kubectl auth can-i list pods -n hello --as=system:serviceaccount:hello:hello-reader
kubectl auth can-i delete pods -n hello --as=system:serviceaccount:hello:hello-reader
```

```text
yes
no
```

## Aufgabe 3: API-Anfrage aus dem Pod

```bash
kubectl exec -it api-test -n hello -- sh
```

Im Pod:

```bash
SA=/var/run/secrets/kubernetes.io/serviceaccount
ls $SA
TOKEN=$(cat $SA/token)
curl -s --cacert $SA/ca.crt -H "Authorization: Bearer $TOKEN" \
  https://kubernetes.default.svc/api/v1/namespaces/hello/pods | head -n 20
```

```text
ca.crt     namespace  token
{
  "kind": "PodList",
  "apiVersion": "v1",
  "metadata": {
    "resourceVersion": "182344"
  },
  "items": [
    {
      "metadata": {
        "name": "api-test",
        "namespace": "hello",
        "uid": "6f1c2d0e-…",
        "resourceVersion": "182101",
        "creationTimestamp": "2026-11-17T12:48:10Z",
        "labels": {
          "app": "api-test"
        },
        "annotations": {
          ...
```

`kind: PodList` mit `items`: dieselbe Liste, die `kubectl get pods -n hello -o json` zeigt; weiter unten folgen `hello-backend-…` und `hello-frontend-…`.

## Aufgabe 4: Löschen wird verboten

```bash
curl -s --cacert $SA/ca.crt -H "Authorization: Bearer $TOKEN" -X DELETE \
  https://kubernetes.default.svc/api/v1/namespaces/hello/pods/api-test
exit
```

```json
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {},
  "status": "Failure",
  "message": "pods \"api-test\" is forbidden: User \"system:serviceaccount:hello:hello-reader\" cannot delete resource \"pods\" in API group \"\" in the namespace \"hello\"",
  "reason": "Forbidden",
  "details": {
    "name": "api-test",
    "kind": "pods"
  },
  "code": 403
}
```

Authentifizierung klappt (der Name steht in der Meldung), die Autorisierung lehnt ab: `pod-reader` erlaubt kein `delete`.

## Aufgabe 5: Kein Token für die Hello-App

`playground/hello/templates/frontend-deployment.yaml` (genauso im Backend):

```yaml
  template:
    metadata:
      ...
    spec:
      automountServiceAccountToken: false      # die App spricht nie mit der Kubernetes-API
      containers:
        - name: frontend
```

`playground/hello/Chart.yaml`:

```yaml
version: 0.2.0
```

```bash
helm upgrade hello playground/hello -n hello
helm list -n hello
kubectl exec deploy/hello-frontend -n hello -- ls /var/run/secrets/kubernetes.io/serviceaccount
```

```text
Release "hello" has been upgraded. Happy Helming!
...
NAME   NAMESPACE  REVISION  UPDATED                            STATUS    CHART        APP VERSION
hello  hello      2         2026-11-17 12:55:31.02 +0100 CET   deployed  hello-0.2.0  v2

ls: /var/run/secrets/kubernetes.io/serviceaccount: No such file or directory
command terminated with exit code 1
```

Die Chart-Version steigt, weil sich ein Template geändert hat (Lab 9.3). Die Pods wurden neu erstellt, die Seite zeigt weiter „Hello-App v2". Die Releases in `hello-dev` und `hello-prod` laufen noch mit Chart 0.1.0; prod bekommt die neue Chart-Version in Lab 10.3.

## Erweiterung: Rechte im Vergleich

```bash
kubectl auth can-i --list -n hello --as=system:serviceaccount:hello:hello-reader | grep pods
kubectl auth can-i --list -n hello --as=system:serviceaccount:hello:default | grep pods
```

```text
pods                                            []                  []               [get list watch]
```

Die zweite Abfrage liefert keine Zeile: `default` hat keine Rechte auf Pods, nur die eingebauten Rechte jeder angemeldeten Identität.
