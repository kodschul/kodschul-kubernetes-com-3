## Kubernetes: Health Checks und Scheduling von Anwendungen

Kubernetes bietet umfassende Mechanismen für das Monitoring und Scheduling von Anwendungen, um deren Zuverlässigkeit und Leistung sicherzustellen. Zu den wichtigsten Features gehören Health Checks und Scheduling-Strategien. Im Folgenden sind einige grundlegende Konzepte und Codebeispiele zur Einführung in Health Checks und Scheduling von Anwendungen in Kubernetes:

### Health Checks

Health Checks in Kubernetes bestehen aus zwei Haupttypen: Liveness Probes und Readiness Probes.

#### Beispiel 1: Liveness Probe

Liveness Probes helfen dabei festzustellen, ob ein Container "lebt" (also nicht hängt oder abgestürzt ist). Wenn die Liveness Probe fehlschlägt, wird der Container neu gestartet.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: liveness-example
spec:
  containers:
  - name: liveness-container
    image: busybox
    args:
    - /bin/sh
    - -c
    - touch /tmp/healthy; sleep 30; rm -rf /tmp/healthy; sleep 600
    livenessProbe:
      exec:
        command:
        - cat
        - /tmp/healthy
      initialDelaySeconds: 5
      periodSeconds: 5
```

In diesem Beispiel überprüft die Liveness Probe, ob die Datei /tmp/healthy existiert. Falls die Datei nicht vorhanden ist, schlägt die Probe fehl und der Container wird neu gestartet.

#### Beispiel 2: Readiness Probe
Readiness Probes bestimmen, ob ein Container bereit ist, Traffic zu empfangen. Wenn die Readiness Probe fehlschlägt, wird der Container aus dem Service-Load Balancer entfernt.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: readiness-example
spec:
  containers:
  - name: readiness-container
    image: busybox
    args:
    - /bin/sh
    - -c
    - touch /tmp/ready; sleep 30; rm -rf /tmp/ready; sleep 600
    readinessProbe:
      exec:
        command:
        - cat
        - /tmp/ready
      initialDelaySeconds: 5
      periodSeconds: 5
```

In diesem Beispiel überprüft die Readiness Probe, ob die Datei /tmp/ready existiert. Falls die Datei nicht vorhanden ist, schlägt die Probe fehl und der Container wird aus dem Load Balancer entfernt.

### Scheduling von Anwendungen
Kubernetes verwendet einen Scheduler, um Pods auf Nodes im Cluster zu platzieren. Der Scheduler berücksichtigt dabei verschiedene Faktoren wie Ressourcenanforderungen, Constraints und Affinitäten.

#### Beispiel 3: Node Selector
Node Selectors sind die einfachste Form der Einschränkung, welche Nodes für die Ausführung eines Pods in Frage kommen.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: node-selector-example
spec:
  containers:
  - name: myapp-container
    image: myapp:1.0
  nodeSelector:
    disktype: ssd
```

In diesem Beispiel wird der Pod nur auf Nodes mit dem Label disktype=ssd geplant.

#### Beispiel 4: Node Affinity
Node Affinity ist flexibler als Node Selectors und ermöglicht es, Präferenzen und Anforderungen für Nodes zu definieren.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: node-affinity-example
spec:
  containers:
  - name: myapp-container
    image: myapp:1.0
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: disktype
            operator: In
            values:
            - ssd
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        preference:
          matchExpressions:
          - key: another-label-key
            operator: In
            values:
            - another-label-value
```

In diesem Beispiel muss der Pod auf einer Node mit dem Label disktype=ssd geplant werden, und es wird bevorzugt, Nodes mit dem Label another-label-key=another-label-value zu verwenden.