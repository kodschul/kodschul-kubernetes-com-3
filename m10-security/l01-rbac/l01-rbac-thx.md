# Lab 10.1: RBAC

**Leitfragen:**

<details>
<summary>Wer im Team darf in Produktion etwas ändern, wer nur zuschauen?</summary>

Meist dürfen wenige Personen oder nur die Pipeline in Produktion ändern; Entwicklung und Support schauen zu und lesen Logs. In der Testumgebung dürfen mehr Leute mehr. Rechte hängen also an Person und Umgebung.

</details>

<details>
<summary>Warum reicht ein gemeinsames Admin-Konto nicht?</summary>

Jeder Fehler und jeder gestohlene Laptop hat dann volle Rechte auf alles, und im Protokoll steht bei jeder Änderung derselbe Name. Eigene Konten mit passenden Rechten begrenzen den Schaden und machen Änderungen nachvollziehbar.

</details>

- Bisher lief jeder Befehl mit vollen Rechten: der Benutzer von Docker Desktop ist Cluster-Administrator.
- RBAC (Role-Based Access Control) legt fest, wer in welchem Namespace was mit welchen Objekten tun darf.

## Begriffe

| Begriff | Bedeutung |
| --- | --- |
| Authentifizierung | Wer ist das? Der API-Server prüft die Identität, z. B. über ein Zertifikat oder ein Token |
| Autorisierung | Darf der das? Der API-Server prüft die Rechte der Identität; in Kubernetes über RBAC |
| RBAC | rollenbasierte Rechtevergabe: Rechte hängen an Rollen, Rollen werden Identitäten zugewiesen |
| Role | Liste erlaubter Aktionen in **einem** Namespace, z. B. „Deployments ändern in `hello-dev`" |
| ClusterRole | wie Role, aber clusterweit oder als Vorlage für viele Namespaces |
| RoleBinding | weist eine Role (oder ClusterRole) einer Identität in einem Namespace zu |
| ClusterRoleBinding | weist eine ClusterRole clusterweit zu, in allen Namespaces |
| Subject | Empfänger einer Bindung: `User`, `Group` oder `ServiceAccount` (Lab 10.2) |
| Verb | Aktion auf der API: `get`, `list`, `watch`, `create`, `update`, `patch`, `delete` |
| API-Gruppe | Bereich der API, zu dem eine Objektart gehört: `""` (Kern: Pods, Services), `apps` (Deployments) |
| geringste Rechte | jede Identität bekommt nur die Rechte, die sie für ihre Aufgabe braucht (englisch: least privilege) |
| Impersonation | ein berechtigter Benutzer führt Befehle im Namen eines anderen aus: `kubectl … --as=anna` |

## Weg einer Anfrage zum API-Server

<img src="https://kubernetes.io/images/docs/admin/access-control-overview.svg" alt="Ablauf einer Anfrage: Human User und Pod mit Service Account schicken Anfragen an den Kubernetes API Server; dort nacheinander 1 Authentication, 2 Authorization, 3 Admission Control, danach 4 Speichern" width="620">

_Quelle: Kubernetes-Dokumentation, „Controlling Access to the Kubernetes API" (https://kubernetes.io/docs/concepts/security/controlling-access/), CC BY 4.0, The Kubernetes Authors, abgerufen am 17.11.2026._

| Schritt | Frage | Bei Nein |
| --- | --- | --- |
| 1 Authentifizierung | Wer ist das? | `401 Unauthorized` |
| 2 Autorisierung (RBAC) | Darf diese Identität dieses Verb auf dieser Ressource in diesem Namespace? | `403 Forbidden` |
| 3 Admission | Ist das Objekt selbst erlaubt (Regeln, Grenzen)? | Abweisung mit Begründung; Thema in Lab 10.3 |
| 4 Speichern | Objekt landet in etcd (Lab 2.3) | – |

Jeder `kubectl`-Befehl, jedes `helm install` und jeder Controller nimmt diesen Weg.

## Benutzer in Kubernetes

Kubernetes kennt keine Benutzer-Objekte: Es gibt kein `kubectl create user`. Der Name kommt von außen und RBAC verweist nur auf ihn.

| Woher die Identität kommt | Beispiel |
| --- | --- |
| Client-Zertifikat in der kubeconfig (Lab 2.2) | Feld `CN` = Benutzername, `O` = Gruppe; so bei Docker Desktop und kubeadm |
| Token eines Identitätsanbieters (OIDC) | Anmeldung über Microsoft Entra ID, Google, Keycloak; üblich in Firmen und Cloud-Clustern |
| ServiceAccount-Token | Identität für Programme im Cluster (Lab 10.2) |

```bash
kubectl auth whoami
```

```text
ATTRIBUTE   VALUE
Username    kubernetes-admin
Groups      [kubeadm:cluster-admins system:authenticated]
```

Ausgabe auf Docker Desktop (kubeadm); Name und Gruppe können je nach Cluster abweichen. Die Gruppe ist an die ClusterRole `cluster-admin` gebunden: alle Verben auf alle Ressourcen.

## Role, ClusterRole und Bindungen

| | gilt in einem Namespace | gilt clusterweit |
| --- | --- | --- |
| Rechte beschreiben | Role | ClusterRole |
| Rechte zuweisen | RoleBinding | ClusterRoleBinding |

<img src="https://kubernetes.io/images/docs/multi-tenancy.png" alt="Ein Cluster mit mehreren Teams: Team A und Team B mit je eigenen Anwendungen, Team C mit Anwendungen je Kunde; jede Gruppe in einem eigenen Bereich" width="520">

_Quelle: Kubernetes-Dokumentation, „Multi-tenancy" (https://kubernetes.io/docs/concepts/security/multi-tenancy/), CC BY 4.0, The Kubernetes Authors, abgerufen am 17.11.2026._

Viele Teams teilen sich einen Cluster; Namespaces trennen ihre Objekte (Lab 6.3), RBAC trennt ihre Rechte.

Kubernetes bringt fertige ClusterRoles mit, die per RoleBinding in einem Namespace gelten:

| ClusterRole | darf |
| --- | --- |
| `view` | fast alles lesen, aber keine Secrets |
| `edit` | Anwendungsobjekte anlegen, ändern, löschen, inklusive Secrets; keine Rollen |
| `admin` | wie `edit`, dazu Rollen und Bindungen im Namespace |
| `cluster-admin` | alles, überall |

## Rollen für die Hello-App

Datei `playground/k8s/rbac.yaml` (Auszug, vollständig in der Übung):

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: deployer
  namespace: hello-dev               # gilt nur hier
rules:
  - apiGroups: ["apps"]              # Deployments, ReplicaSets
    resources: ["deployments", "deployments/scale", "replicasets"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
  - apiGroups: [""]                  # Kern-API
    resources: ["pods", "services", "configmaps"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: anna-deployer
  namespace: hello-dev
subjects:
  - kind: User
    name: anna                       # Name aus Zertifikat oder Token
    apiGroup: rbac.authorization.k8s.io
roleRef:                             # welche Rolle; nach dem Anlegen nicht änderbar
  kind: Role
  name: deployer
  apiGroup: rbac.authorization.k8s.io
```

Woher die Werte kommen: `kubectl api-resources` zeigt für jede Objektart Namen und API-Gruppe (Spalte `APIVERSION`: `apps/v1` → Gruppe `apps`, `v1` → Gruppe `""`).

| kubectl-Befehl | Verb |
| --- | --- |
| `kubectl get pod <name>` | `get` |
| `kubectl get pods` | `list` |
| `kubectl get pods -w` | `watch` |
| `kubectl create` / `kubectl apply` (neu) | `create` |
| `kubectl apply` (vorhanden), `kubectl edit` | `patch` bzw. `update` |
| `kubectl delete` | `delete` |
| `kubectl logs` | `get` auf `pods/log` |
| `kubectl scale deployment …` | `patch` auf `deployments/scale` |

Unterressourcen wie `pods/log` oder `deployments/scale` stehen einzeln in der Rolle; `deployments` allein deckt sie nicht ab. RBAC kennt nur Erlaubnisse, keine Verbote: Was nicht erlaubt ist, ist verboten. Mehrere Rollen addieren sich.

## ClusterRole für Nodes

Nodes, Namespaces und PersistentVolumes gehören zu keinem Namespace (Spalte `NAMESPACED false` in `kubectl api-resources`). Rechte darauf gehen nur über eine ClusterRole mit ClusterRoleBinding:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: node-reader                  # kein namespace: gilt clusterweit
rules:
  - apiGroups: [""]
    resources: ["nodes"]
    verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ops-node-reader
subjects:
  - kind: Group                      # alle Mitglieder der Gruppe, statt einzelner Benutzer
    name: ops                        # Gruppe aus Zertifikat (Feld O) oder Identitätsanbieter
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: node-reader
  apiGroup: rbac.authorization.k8s.io
```

Sobald beides angelegt ist, prüft `kubectl auth can-i list nodes --as=ben --as-group=ops` die Rechte so, als wäre `ben` Mitglied der Gruppe `ops`: `yes`. Ohne `--as-group` bleibt es bei `no` (wie in der Übung). Bindungen an Gruppen sparen Arbeit: Wer ins Team kommt oder es verlässt, ändert nur die Gruppe beim Identitätsanbieter, nicht die Bindungen im Cluster.

## Rechte prüfen mit `kubectl auth can-i`

```bash
kubectl auth can-i create deployments -n hello-dev --as=anna     # yes
kubectl auth can-i delete pods -n hello-prod --as=ben            # no
kubectl auth can-i --list -n hello-dev --as=anna                 # alle Rechte von anna dort
```

`--as=anna` funktioniert, weil der eigene Benutzer das Recht `impersonate` hat (Teil von `cluster-admin`). Der API-Server prüft die Anfrage dann so, als käme sie von `anna`. In echten Clustern ist dieses Recht nur für Administratoren vorgesehen.

## Typische Fehler

| Symptom | Ursache | Lösung |
| --- | --- | --- |
| `can-i` sagt `no`, obwohl die Role stimmt | RoleBinding in einem anderen Namespace als die Role, oder Tippfehler im Namen | `kubectl get role,rolebinding -n hello-dev`, Namen vergleichen |
| `can-i create deployments` sagt `no` | `apiGroups: [""]` statt `["apps"]` | Gruppe aus `kubectl api-resources` übernehmen |
| `The RoleBinding "…" is invalid: roleRef: Invalid value … cannot change roleRef` | `roleRef` einer bestehenden Bindung geändert | Bindung löschen und neu anlegen |
| `kubectl get pods --as=ben` zeigt `Forbidden` in `hello-dev` | Rechte gelten nur in `hello-prod` | gewollt: `-n hello-prod` |
| alles ist `yes` | `--as` vergessen, Prüfung mit eigenem Admin-Benutzer | `--as=<name>` anhängen |

## Fazit

- Jede Anfrage durchläuft Authentifizierung (wer?), Autorisierung (darf er?) und Admission (ist das Objekt erlaubt?).
- RBAC: Role/ClusterRole beschreiben Rechte, RoleBinding/ClusterRoleBinding weisen sie zu; erlaubt ist nur, was ausdrücklich erlaubt ist.
- Benutzer sind keine Objekte; ihr Name kommt aus Zertifikat oder Token.
- `kubectl auth can-i … --as=<name>` prüft Rechte, ohne sich als diese Person anzumelden.

In der Übung bekommen `anna` (dev deployen) und `ben` (prod lesen) eigene Rollen, und eine Rechte-Matrix zeigt, was jeweils erlaubt ist.

## Vertiefung

### Zusammengesetzte ClusterRoles

Die fertigen Rollen `view`, `edit` und `admin` sind zusammengesetzt (englisch: aggregated): Ihr Feld `aggregationRule` sammelt die Regeln aller ClusterRoles mit einem bestimmten Label ein. Bringt ein Operator eine neue Objektart mit (CRD, Lab 7.3), liefert er meist eine ClusterRole mit diesem Label mit, und wer `view` hat, kann die neuen Objekte sofort lesen:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cnpg-cluster-view
  labels:
    rbac.authorization.k8s.io/aggregate-to-view: "true"   # Regeln wandern in die Rolle view
rules:
  - apiGroups: ["postgresql.cnpg.io"]
    resources: ["clusters"]
    verbs: ["get", "list", "watch"]
```

Entsprechend gibt es `aggregate-to-edit` und `aggregate-to-admin`. `kubectl get clusterrole view -o yaml` zeigt die eingesammelten Regeln.
