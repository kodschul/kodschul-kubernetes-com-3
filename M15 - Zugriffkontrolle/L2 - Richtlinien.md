## Kubernetes: Zugriffskontrollrichtlinien

Die Zugriffskontrolle ist ein entscheidender Aspekt der Kubernetes-Sicherheit und ermöglicht die Definition von Richtlinien zur Steuerung des Zugriffs auf Ressourcen im Cluster. Kubernetes bietet verschiedene Mechanismen zur Zugriffskontrolle, einschließlich RBAC (Role-Based Access Control) und Netzwerkrichtlinien. Im Folgenden sind einige grundlegende Konzepte und Codebeispiele zur Einführung in Zugriffskontrollrichtlinien in Kubernetes:

### Role-Based Access Control (RBAC)

RBAC ist ein Mechanismus zur Steuerung des Zugriffs auf Kubernetes-Ressourcen basierend auf den Rollen und Berechtigungen von Benutzern oder Serviceaccounts.

#### Beispiel 1: Erstellung einer Rolle

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

In diesem Beispiel wird eine Rolle mit dem Namen pod-reader erstellt, die die Berechtigung zum Lesen von Pods in der Standard-Namespace gewährt.

#### Beispiel 2: Zuweisen einer Rolle zu einem Benutzer

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

Hier wird der Benutzer "alice" der Rolle "pod-reader" in der Standard-Namespace zugewiesen, sodass er Pods in diesem Namespace lesen kann.

### Netzwerkrichtlinien
Netzwerkrichtlinien in Kubernetes ermöglichen die Steuerung des Netzwerkverkehrs zwischen Pods und Services.

#### Beispiel 3: Erstellung einer Netzwerkrichtlinie

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-same-namespace
spec:
  podSelector: {}
  ingress:
  - from:
    - podSelector: {}
```

In diesem Beispiel wird eine Netzwerkrichtlinie erstellt, die eingehenden Verkehr von allen Pods im selben Namespace erlaubt.

#### Beispiel 4: Einschränkung des Netzwerkzugriffs

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-external-traffic
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - {}
```

Hier wird eine Netzwerkrichtlinie definiert, die eingehenden Verkehr von außerhalb des Clusters blockiert.