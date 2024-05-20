## Kubernetes: Zugriffskontrolle Service Accounts

In Kubernetes ermöglichen Service Accounts die Authentifizierung und Autorisierung von Pods und Controllern, um auf Kubernetes-APIs und andere Ressourcen zuzugreifen. Die Zugriffskontrolle von Service Accounts ist entscheidend für die Sicherheit und Isolation von Kubernetes-Workloads. Im Folgenden sind einige grundlegende Konzepte und Codebeispiele zur Einführung in die Zugriffskontrolle von Service Accounts:

### Service Account erstellen

Um einen Service Account zu erstellen, können Sie die folgende YAML-Definition verwenden:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-service-account
```

Dies erstellt einen Service Account mit dem Namen "my-service-account".

### Service Account zu einem Pod zuweisen
Um einen Service Account einem Pod zuzuweisen, fügen Sie die serviceAccountName-Eigenschaft zur Pod-Spezifikation hinzu:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  serviceAccountName: my-service-account
  containers:
  - name: my-container
    image: my-image:latest
```

In diesem Beispiel wird der Service Account "my-service-account" dem Pod "my-pod" zugewiesen.

### RBAC-Rollen zuweisen
Zusätzlich zur Zuweisung von Service Accounts können Sie Rollen und Berechtigungen mithilfe von Role-Based Access Control (RBAC) steuern.

#### Beispiel: Rolle erstellen

```yaml
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]

```

In diesem Beispiel wird eine Rolle mit dem Namen "pod-reader" definiert, die Leseberechtigungen für Pods gewährt.

#### Beispiel: Rolle an Service Account binden

```yaml
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: read-pods
subjects:
- kind: ServiceAccount
  name: my-service-account
  namespace: default
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```
In diesem Beispiel wird die Rolle "pod-reader" an den Service Account "my-service-account" gebunden.