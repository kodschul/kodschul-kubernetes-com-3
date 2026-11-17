# Zugriff und Sicherheit – Cheatsheet (Modul 10)

Alle Befehle aus dem Ordner `project/` (Stand: 11/2026).

## Eigene Identität und Rechte

| Befehl | Wirkung |
| --- | --- |
| `kubectl auth whoami` | eigener Benutzername und Gruppen |
| `kubectl auth can-i '*' '*'` | darf der eigene Benutzer alles? |
| `kubectl auth can-i create deployments -n hello-dev` | eine Aktion für den eigenen Benutzer prüfen |
| `kubectl auth can-i create deployments -n hello-dev --as=anna` | dieselbe Prüfung im Namen von `anna` (Impersonation) |
| `kubectl auth can-i --list -n hello-dev --as=anna` | alle Rechte von `anna` im Namespace |
| `kubectl auth can-i list pods -n hello --as=system:serviceaccount:hello:hello-reader` | Rechte eines ServiceAccounts prüfen |
| `kubectl get pods -n hello-prod --as=ben` | echten Befehl im Namen von `ben` ausführen |
| `kubectl auth can-i list nodes --as=ben --as-group=ops` | Prüfung im Namen von `ben` als Mitglied der Gruppe `ops` |
| `helm list -n hello-dev --kube-as-user anna` | Helm im Namen von `anna` |

## RBAC-Objekte

| Befehl | Wirkung |
| --- | --- |
| `kubectl apply -f playground/k8s/rbac.yaml` | Roles und RoleBindings anlegen |
| `kubectl get role,rolebinding -n hello-dev` | Rollen und Bindungen im Namespace |
| `kubectl get clusterrole,clusterrolebinding` | clusterweite Rollen und Bindungen (ohne `-n`) |
| `kubectl describe clusterrole view` | Regeln einer fertigen Rolle (`view`, `edit`, `admin`, `cluster-admin`) |
| `kubectl api-resources` | Ressourcen-Namen und API-Gruppen für `rules` |

## Bausteine einer Rolle

| Feld | Beispiel | Bedeutung |
| --- | --- | --- |
| `apiGroups` | `[""]`, `["apps"]` | API-Gruppe: `""` = Kern (Pods, Services, ConfigMaps, Secrets), `apps` = Deployments, ReplicaSets |
| `resources` | `["pods", "pods/log", "deployments/scale"]` | Objektarten und Unterressourcen |
| `verbs` | `["get", "list", "watch"]` | erlaubte Aktionen; nur lesen = `get`, `list`, `watch` |
| `subjects[].kind` | `User`, `Group`, `ServiceAccount` | wer die Rolle bekommt |
| `aggregationRule` | `clusterRoleSelectors` mit Label `rbac.authorization.k8s.io/aggregate-to-view: "true"` | ClusterRole sammelt Regeln anderer ClusterRoles ein |
| `roleRef` | `kind: Role`, `name: deployer` | welche Rolle; nicht änderbar |

## ServiceAccounts

| Befehl | Wirkung |
| --- | --- |
| `kubectl get serviceaccounts -n hello` | ServiceAccounts im Namespace (`default` gibt es immer) |
| `kubectl get pod api-test -n hello -o jsonpath='{.spec.serviceAccountName}'` | ServiceAccount eines Pods |
| `kubectl exec -it api-test -n hello -- sh` | Shell im Test-Pod |
| `ls /var/run/secrets/kubernetes.io/serviceaccount` | im Pod: `token`, `ca.crt`, `namespace` |
| `TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)` | im Pod: Token in eine Variable |
| `curl -s --cacert …/ca.crt -H "Authorization: Bearer $TOKEN" https://kubernetes.default.svc/api/v1/namespaces/hello/pods` | im Pod: Pods über die API auflisten |
| `curl … -X DELETE https://kubernetes.default.svc/api/v1/namespaces/hello/pods/api-test` | im Pod: Löschen versuchen (403 erwartet) |
| `kubectl create token hello-reader -n hello --duration=10m` | kurzlebiges Token für einen ServiceAccount erzeugen |
| `automountServiceAccountToken: false` | im Pod-Spec: kein Token einhängen |

## Pod Security

| Befehl | Wirkung |
| --- | --- |
| `kubectl label namespace hello-prod pod-security.kubernetes.io/enforce=restricted` | neue Pods, die `restricted` verletzen, ablehnen |
| `kubectl label namespace hello-dev pod-security.kubernetes.io/warn=restricted` | nur warnen |
| `kubectl label namespace hello-prod pod-security.kubernetes.io/enforce-` | Label wieder entfernen |
| `kubectl get namespace hello-prod --show-labels` | gesetzte Stufe ansehen |
| `kubectl get events -n hello-prod --field-selector reason=FailedCreate` | abgelehnte Pods mit Begründung |
| `kubectl exec deploy/hello-frontend -n hello-prod -- id` | Benutzer im Container prüfen |
| `docker run --rm hello-backend:v1-nonroot id` | Benutzer eines Images prüfen |
| `bash build-images.sh` | alle Hello-Images inklusive `*-nonroot` neu bauen |

## securityContext für `restricted`

| Feld | Ebene | Wert |
| --- | --- | --- |
| `runAsNonRoot` | Pod oder Container | `true` |
| `runAsUser` | Pod oder Container | `10001` (muss zum Image passen) |
| `allowPrivilegeEscalation` | Container | `false` |
| `capabilities.drop` | Container | `["ALL"]` |
| `seccompProfile.type` | Pod oder Container | `RuntimeDefault` |
| `readOnlyRootFilesystem` | Container | `true` (zusätzlich, nicht Pflicht für `restricted`) |
| `fsGroup` | Pod | `10001` (Volumes für die Gruppe beschreibbar) |
