## Kubernetes: Rollenbasierte Zugriffskontrolle

Die rollenbasierte Zugriffskontrolle (Role-Based Access Control, RBAC) in Kubernetes ermöglicht es Administratoren, präzise zu definieren, welche Benutzer oder Dienste auf welche Ressourcen zugreifen dürfen. Dies erhöht die Sicherheit und ermöglicht eine feinere Steuerung der Zugriffsrechte im Kubernetes-Cluster. Im Folgenden sind einige grundlegende Konzepte und Codebeispiele zur Einführung in die rollenbasierte Zugriffskontrolle in Kubernetes:

### Rolle

Eine Rolle definiert eine Reihe von Berechtigungen, die auf bestimmte Ressourcen in einem Namespace angewendet werden können.

#### Beispiel 1: Erstellen einer Rolle

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
```

In diesem Beispiel wird eine Rolle mit dem Namen pod-reader definiert, die Berechtigungen zum Lesen von Pods im Standard-Namespace gewährt.

### Rollebindung
Eine Rollebindung weist einer Rolle bestimmte Benutzer oder Dienste zu.

#### Beispiel 2: Erstellen einer Rollebindung

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: default
subjects:
- kind: User
  name: alice
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io

```

In diesem Beispiel wird eine Rollebindung mit dem Namen read-pods erstellt, die die Rolle pod-reader der Benutzerin Alice im Standard-Namespace zuweist.

### Cluster-Rolle
Eine Cluster-Rolle definiert eine Reihe von Berechtigungen, die auf bestimmte Ressourcen im gesamten Cluster angewendet werden können.

#### Beispiel 3: Erstellen einer Cluster-Rolle

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: namespace-reader
rules:
- apiGroups: [""]
  resources: ["namespaces"]
  verbs: ["get", "watch", "list"]

```

In diesem Beispiel wird eine Cluster-Rolle mit dem Namen namespace-reader definiert, die Berechtigungen zum Lesen von Namespaces im gesamten Cluster gewährt.

### Cluster-Rollebindung
Eine Cluster-Rollebindung weist einer Cluster-Rolle bestimmte Benutzer oder Dienste zu.

#### Beispiel 4: Erstellen einer Cluster-Rollebindung

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: read-namespaces
subjects:
- kind: Group
  name: admins
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: namespace-reader
  apiGroup: rbac.authorization.k8s.io

```

In diesem Beispiel wird eine Cluster-Rollebindung mit dem Namen read-namespaces erstellt, die die Cluster-Rolle namespace-reader der Gruppe "admins" im gesamten Cluster zuweist.