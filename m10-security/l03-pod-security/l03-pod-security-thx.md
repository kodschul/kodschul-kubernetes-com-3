# Lab 10.3: Pod Security

**Leitfragen:**

<details>
<summary>Ein Angreifer übernimmt einen Container, der als root läuft: was kann er?</summary>

Im Container alles: Dateien des Images ändern, Programme nachinstallieren, Sonderrechte des Kernels nutzen. Container teilen sich den Kernel des Rechners; eine Lücke im Kernel oder eine zu großzügige Einstellung macht aus root im Container schnell root auf dem Node.

</details>

<details>
<summary>Wie verhindert man, dass jemand aus Versehen unsichere Pods startet?</summary>

Mit einer Regel an der Tür statt einer Bitte im Wiki: Der Cluster prüft jeden neuen Pod gegen eine Liste von Sicherheitsanforderungen und lehnt ab, was nicht passt. In Kubernetes macht das Pod Security Admission je Namespace.

</details>

- Bisher laufen die Hello-Container als root und dürfen ins eigene Dateisystem schreiben.
- `securityContext` schränkt einen Pod ein; Pod Security Admission erzwingt solche Einschränkungen für einen ganzen Namespace.

## Begriffe

| Begriff | Bedeutung |
| --- | --- |
| root, UID | root ist der Administrator unter Linux mit der Benutzernummer (UID) 0; andere Benutzer haben eigene Nummern, z. B. 10001 |
| `securityContext` | Feld in Pod und Container mit Sicherheitseinstellungen: als wer läuft der Prozess, was darf er |
| `runAsNonRoot` | Kubernetes startet den Container nur, wenn er nicht als UID 0 laufen würde |
| `runAsUser` | UID, unter der der Prozess läuft; überschreibt `USER` aus dem Dockerfile |
| `readOnlyRootFilesystem` | Dateisystem des Images ist nur lesbar; schreiben nur in eingehängte Volumes |
| `allowPrivilegeEscalation` | `false` verhindert, dass ein Prozess mehr Rechte bekommt als sein Startprozess (z. B. über `sudo`) |
| Capabilities | Sonderrechte des Linux-Kernels in kleinen Stücken, z. B. `NET_BIND_SERVICE` (Ports unter 1024), `CHOWN` (Dateibesitzer ändern) |
| seccomp | Filter für Systemaufrufe an den Kernel; `RuntimeDefault` sperrt selten gebrauchte, riskante Aufrufe |
| `fsGroup` | Gruppe, der eingehängte Volumes gehören sollen, damit ein Nicht-root-Prozess schreiben darf |
| Pod Security Standards | drei vordefinierte Stufen: `privileged`, `baseline`, `restricted` |
| Pod Security Admission | im API-Server eingebaute Prüfung, die neue Pods gegen eine Stufe prüft; gesteuert über Labels am Namespace |
| Admission | dritter Schritt einer Anfrage nach Authentifizierung und Autorisierung (Lab 10.1): Ist das Objekt erlaubt? |

## Root im Container und seine Folgen

| Einstellung | ohne | mit |
| --- | --- | --- |
| Benutzer | root (UID 0) | UID 10001, `runAsNonRoot: true` |
| Dateisystem des Images | beschreibbar: Schadcode kann sich festsetzen | nur lesbar, schreiben nur in `/data` |
| Capabilities | Standard-Satz der Laufzeit, u. a. `CHOWN`, `NET_RAW`, `SETUID` | `drop: ["ALL"]` |
| Rechteausweitung | möglich über setuid-Programme | `allowPrivilegeEscalation: false` |
| Systemaufrufe | alle | `seccompProfile: RuntimeDefault` |

Neu 2026: User Namespaces sind seit Kubernetes 1.36 (22.04.2026) stabil. Mit `hostUsers: false` ist root im Container auf dem Node ein gewöhnlicher Benutzer ohne Rechte. Quelle: [Kubernetes v1.36 Release](https://kubernetes.io/blog/2026/04/22/kubernetes-v1-36-release/), abgerufen am 17.11.2026; nicht jeder Cluster und jede Laufzeit unterstützt das (Stand: 11/2026).

## Images ohne root: Dockerfile

Kubernetes kann einen Benutzer nur erzwingen; das Image muss damit laufen. Gegenüber Lab 1.3 ändern sich drei Stellen ([`examples/m10-security/l03-pod-security/frontend/Dockerfile`](../../project/examples/m10-security/l03-pod-security/frontend/Dockerfile)):

```dockerfile
# Eigener Benutzer ohne root-Rechte (UID 10001) und ein Datenordner, der ihm gehört
RUN adduser -D -u 10001 hello && mkdir -p /data && chown 10001 /data
USER 10001

# Port 8080 statt 80
ENV APP_VERSION=v1 \
    APP_COLOR=lightblue \
    PORT=8080

# Ports unter 1024 brauchen root-Rechte (Capability NET_BIND_SERVICE), deshalb 8080
EXPOSE 8080
```

`USER` mit Zahl statt Name: `runAsNonRoot` prüft die Nummer, einen Namen kann Kubernetes nicht prüfen.

## securityContext im Pod

```yaml
spec:
  securityContext:                      # Pod-Ebene: gilt für alle Container und Volumes
    fsGroup: 10001
  containers:
    - name: frontend
      image: hello-frontend:v1-nonroot
      securityContext:                  # Container-Ebene
        runAsNonRoot: true
        runAsUser: 10001
        allowPrivilegeEscalation: false
        capabilities:
          drop: ["ALL"]
        seccompProfile:
          type: RuntimeDefault
        readOnlyRootFilesystem: true
      ports:
        - name: http
          containerPort: 8080           # Service und Probes nutzen den Namen http
      volumeMounts:
        - name: data
          mountPath: /data              # einziger beschreibbarer Ort: access.log
```

Im Chart `hello` werden diese Blöcke zu Werten (`podSecurityContext`, `securityContext`, `containerPort`); `values-prod.yaml` setzt sie, dev bleibt beim Standard.

## Pod Security Standards

| Stufe | erlaubt | typisch für |
| --- | --- | --- |
| `privileged` | alles | System-Komponenten (Netzwerk, Speicher, Monitoring auf dem Node) |
| `baseline` | übliche Container; verbietet bekannte Ausbrüche (`privileged: true`, `hostNetwork`, `hostPath`, gefährliche Capabilities) | Standard für Anwendungen |
| `restricted` | nur gehärtete Pods: nicht root, `allowPrivilegeEscalation: false`, `drop: ["ALL"]`, seccomp gesetzt, nur harmlose Volume-Arten | sicherheitskritische Anwendungen, Produktion |

`readOnlyRootFilesystem` verlangt `restricted` nicht; es ist eine zusätzliche Härtung.

## Pod Security Admission per Namespace-Label

<img src="https://kubernetes.io/docs/reference/access-authn-authz/admission-control-phases.svg" alt="Sequenzdiagramm: Anfrage vom User an den API-Server, Authentifizierung und Autorisierung, danach Mutating Admission und Validating Admission, die das Objekt ändern oder ablehnen können, am Ende Antwort an den User" width="600">

_Quelle: Kubernetes-Dokumentation, „Admission Control in Kubernetes" (https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/), CC BY 4.0, The Kubernetes Authors, abgerufen am 17.11.2026._

Pod Security Admission ist eine der prüfenden Stationen (Validating Admission) im Bild. Gesteuert wird sie über drei Labels am Namespace:

| Label | Wirkung bei Verstoß |
| --- | --- |
| `pod-security.kubernetes.io/enforce=<stufe>` | neuer Pod wird abgelehnt |
| `pod-security.kubernetes.io/warn=<stufe>` | Warnung an `kubectl`/Helm, Pod wird angelegt |
| `pod-security.kubernetes.io/audit=<stufe>` | Eintrag im Audit-Log des API-Servers, Pod wird angelegt |

```bash
kubectl label namespace hello-prod pod-security.kubernetes.io/enforce=restricted
```

```text
Warning: existing pods in namespace "hello-prod" violate the new PodSecurity enforce level "restricted:latest"
Warning: hello-backend-6f7d8c9b5d-4hx2m (and 2 other pods): allowPrivilegeEscalation != false, unrestricted capabilities, runAsNonRoot != true, seccompProfile
Warning: hello-frontend-6c8d7b5f9d-2lmqp (and 2 other pods): allowPrivilegeEscalation != false, unrestricted capabilities, runAsNonRoot != true, seccompProfile
namespace/hello-prod labeled
```

- Laufende Pods bleiben unangetastet; geprüft wird nur beim Anlegen.
- Deployments selbst werden angenommen; abgelehnt werden die Pods, die der ReplicaSet-Controller anlegen will. Die Meldung steht deshalb als Event `FailedCreate` am ReplicaSet, nicht im Terminal:

```text
Warning  FailedCreate  replicaset/hello-frontend-5d9f8c7b6d  Error creating: pods "hello-frontend-5d9f8c7b6d-x8k2p" is forbidden: violates PodSecurity "restricted:latest": allowPrivilegeEscalation != false (container "frontend" must set securityContext.allowPrivilegeEscalation=false), unrestricted capabilities (container "frontend" must set securityContext.capabilities.drop=["ALL"]), runAsNonRoot != true (pod or container "frontend" must set securityContext.runAsNonRoot=true), seccompProfile (pod or container "frontend" must set securityContext.seccompProfile.type to "RuntimeDefault" or "Localhost")
```

Gängiger Weg in der Praxis: erst `warn=restricted` setzen und Warnungen sammeln, dann `enforce`.

## NetworkPolicies für Verbindungen zwischen Pods

Bisher darf jeder Pod jeden anderen erreichen. Eine NetworkPolicy erlaubt Verbindungen nur nach Labels, z. B. „ins Backend nur vom Frontend":

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-only-from-frontend
  namespace: hello-prod
spec:
  podSelector:
    matchLabels: { app: hello, tier: backend }    # gilt für Backend-Pods
  ingress:
    - from:
        - podSelector:
            matchLabels: { app: hello, tier: frontend }
```

Durchgesetzt wird sie vom Netzwerk-Plugin des Clusters (z. B. Calico, Cilium); ohne passendes Plugin bleibt sie wirkungslos. Ob der lokale Cluster sie umsetzt, hängt von der Installation ab (Stand: 11/2026).

## Typische Fehler

| Symptom | Ursache | Lösung |
| --- | --- | --- |
| Deployment `0/3` READY, keine Pods, Events `FailedCreate … violates PodSecurity` | Pod erfüllt `restricted` nicht | `kubectl get events -n hello-prod`; fehlende Felder aus der Meldung ergänzen |
| `CreateContainerConfigError`, `container has runAsNonRoot and image will run as root` | `runAsNonRoot: true` mit einem root-Image ohne `runAsUser` | `*-nonroot`-Image verwenden |
| Pod `CrashLoopBackOff`, Log `Permission denied` beim Port | App will Port 80 öffnen, darf es ohne root nicht | `containerPort: 8080` und `PORT=8080` |
| Readiness schlägt fehl, `connection refused` | Probe oder Service zeigen noch auf 80 | Port über den Namen `http` ansprechen |
| Seite liefert `Internal Server Error`, Log `PermissionError … access.log` | `/data` gehört root (alte Daten) oder liegt im nur lesbaren Image | frisches Volume, `fsGroup`; ohne PVC `persistence.enabled=false` (emptyDir) |
| `Read-only file system` beim Schreiben | `readOnlyRootFilesystem: true` | nur in Volumes schreiben; für temporäre Dateien ein `emptyDir` unter `/tmp` einhängen |

## Fazit

- Container laufen standardmäßig als root; `securityContext` macht daraus einen eingeschränkten Prozess ohne Sonderrechte und mit nur lesbarem Image.
- Das Image muss mitspielen: eigener Benutzer mit Nummer (`USER 10001`), Port über 1024.
- Pod Security Admission prüft neue Pods je Namespace gegen `privileged`, `baseline` oder `restricted`; Ablehnungen stehen als `FailedCreate`-Event am ReplicaSet.
- NetworkPolicies begrenzen zusätzlich den Netzwerkverkehr zwischen Pods.

In der Übung wird `hello-prod` auf `restricted` gestellt, die Ablehnung gelesen und die Hello-App mit Nicht-root-Images und erweitertem Chart wieder zum Laufen gebracht.
