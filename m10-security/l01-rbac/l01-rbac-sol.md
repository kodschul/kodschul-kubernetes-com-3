# Lab 10.1 – Lösung: RBAC

Fertige Datei: [`project/examples/m10-security/l01-rbac/rbac.yaml`](../../project/examples/m10-security/l01-rbac/rbac.yaml)

## Aufgabe 1: Eigener Benutzer

```bash
kubectl auth whoami
kubectl auth can-i '*' '*'
kubectl auth can-i get pods -n hello-prod --as=ben
```

```text
ATTRIBUTE   VALUE
Username    kubernetes-admin
Groups      [kubeadm:cluster-admins system:authenticated]
yes
no
```

Der eigene Benutzer darf alles (`*` = alle Verben auf alle Ressourcen). `ben` existiert nirgends als Objekt; ohne Bindung hat der Name keine Rechte. Name und Gruppe können auf anderen Clustern abweichen.

## Aufgabe 2: Rollen anlegen

Ergänzter Teil von `playground/k8s/rbac.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: viewer
  namespace: hello-prod
rules:
  - apiGroups: ["apps"]
    resources: ["deployments", "replicasets"]
    verbs: ["get", "list", "watch"]         # nur lesende Verben
  - apiGroups: [""]
    resources: ["pods", "pods/log", "services", "configmaps"]   # bewusst ohne secrets
    verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ben-viewer
  namespace: hello-prod
subjects:
  - kind: User
    name: ben
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: viewer
  apiGroup: rbac.authorization.k8s.io
```

```bash
kubectl apply -f playground/k8s/rbac.yaml
kubectl get role,rolebinding -n hello-dev
kubectl get role,rolebinding -n hello-prod
```

```text
role.rbac.authorization.k8s.io/deployer created
rolebinding.rbac.authorization.k8s.io/anna-deployer created
role.rbac.authorization.k8s.io/viewer created
rolebinding.rbac.authorization.k8s.io/ben-viewer created

NAME                                      CREATED AT
role.rbac.authorization.k8s.io/deployer   2026-11-17T12:20:41Z

NAME                                                  ROLE            AGE
rolebinding.rbac.authorization.k8s.io/anna-deployer   Role/deployer   5s

NAME                                    CREATED AT
role.rbac.authorization.k8s.io/viewer   2026-11-17T12:20:41Z

NAME                                               ROLE          AGE
rolebinding.rbac.authorization.k8s.io/ben-viewer   Role/viewer   5s
```

## Aufgabe 3: Rechte-Matrix

Beispiel einer Zeile:

```bash
kubectl auth can-i create deployments -n hello-dev --as=anna
kubectl auth can-i create deployments -n hello-dev --as=ben
```

```text
yes
no
```

| Abfrage | anna | ben | Grund |
| --- | --- | --- | --- |
| `get pods -n hello-dev` | yes | no | anna: Role `deployer` in dev; ben hat in dev nichts |
| `create deployments -n hello-dev` | yes | no | `deployer` erlaubt `create` in Gruppe `apps` |
| `delete deployments -n hello-dev` | yes | no | `deployer` erlaubt `delete` |
| `get pods -n hello-prod` | no | yes | ben: Role `viewer` in prod |
| `delete pods -n hello-prod` | no | no | `viewer` hat nur lesende Verben |
| `get secrets -n hello-prod` | no | no | Secrets stehen in keiner Rolle |
| `list pods -n hello` | no | no | keine Bindung im Namespace `hello` |
| `list nodes` | no | no | Nodes sind clusterweit; dafür bräuchte es eine ClusterRole mit ClusterRoleBinding |

Bei `list nodes` meldet `kubectl` zusätzlich `Warning: resource 'nodes' is not namespace scoped`, wenn ein Namespace gesetzt ist; das Ergebnis bleibt `no`.

## Aufgabe 4: Alle Rechte von anna

```bash
kubectl auth can-i --list -n hello-dev --as=anna
```

```text
Resources                                       Non-Resource URLs   Resource Names   Verbs
selfsubjectreviews.authentication.k8s.io        []                  []               [create]
selfsubjectaccessreviews.authorization.k8s.io   []                  []               [create]
selfsubjectrulesreviews.authorization.k8s.io    []                  []               [create]
configmaps                                      []                  []               [get list watch create update patch delete]
pods                                            []                  []               [get list watch create update patch delete]
services                                        []                  []               [get list watch create update patch delete]
deployments.apps                                []                  []               [get list watch create update patch delete]
deployments.apps/scale                          []                  []               [get list watch create update patch delete]
replicasets.apps                                []                  []               [get list watch create update patch delete]
pods/log                                        []                  []               [get]
                                                [/api/*]            []               [get]
...
```

Die `self…`-Zeilen und die Non-Resource-URLs (z. B. `/healthz`, `/version`) bekommt jede angemeldete Identität über eingebaute Rollen; sie erlauben nur Fragen nach den eigenen Rechten und das Lesen allgemeiner Infos.

```bash
kubectl scale deployment hello-frontend -n hello-dev --replicas=2 --as=anna
kubectl scale deployment hello-frontend -n hello-dev --replicas=1 --as=anna
```

```text
deployment.apps/hello-frontend scaled
deployment.apps/hello-frontend scaled
```

`kubectl scale` ändert die Unterressource `deployments/scale` mit dem Verb `patch`; deshalb steht sie in der Role `deployer` eigens neben `deployments`. Ohne diesen Eintrag endet der Befehl mit `Forbidden … cannot patch resource "deployments/scale"`.

## Aufgabe 5: Echte Befehle als ben

```bash
kubectl get pods -n hello-prod --as=ben
kubectl delete deployment hello-frontend -n hello-prod --as=ben
kubectl get secret hello-secret -n hello-prod --as=ben
```

```text
NAME                              READY   STATUS    RESTARTS   AGE
hello-backend-6f7d8c9b5d-4hx2m    1/1     Running   0          28m
hello-backend-6f7d8c9b5d-9kq7t    1/1     Running   0          28m
hello-backend-6f7d8c9b5d-wz5rn    1/1     Running   0          28m
hello-frontend-5c8d7b6f9d-2lmqp   1/1     Running   0          21m
hello-frontend-5c8d7b6f9d-g7v4x   1/1     Running   0          21m
hello-frontend-5c8d7b6f9d-tn8cs   1/1     Running   0          21m

Error from server (Forbidden): deployments.apps "hello-frontend" is forbidden: User "ben" cannot delete resource "deployments" in API group "apps" in the namespace "hello-prod"

Error from server (Forbidden): secrets "hello-secret" is forbidden: User "ben" cannot get resource "secrets" in API group "" in the namespace "hello-prod"
```

Die Meldung nennt Benutzer, Verb, Ressource, API-Gruppe und Namespace: genau die Angaben, die in einer Role fehlen.

## Erweiterung: Helm braucht Secrets

```bash
helm list -n hello-dev --kube-as-user anna
```

```text
Error: list: failed to list: secrets is forbidden: User "anna" cannot list resource "secrets" in API group "" in the namespace "hello-dev"
```

Ergänzung in der Role `deployer`:

```yaml
  - apiGroups: [""]
    resources: ["secrets"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
```

Nach `kubectl apply -f playground/k8s/rbac.yaml` zeigt `helm list -n hello-dev --kube-as-user anna` das Release `hello`. Wer mit Helm deployen darf, darf damit auch alle Secrets des Namespace lesen; das gehört zur Entscheidung, wem diese Rolle zusteht.
