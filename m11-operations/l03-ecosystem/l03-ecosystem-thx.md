# Lab 11.3: Das Kubernetes-Ökosystem

**Leitfragen:**

<details>
<summary>Was fehlt der Hello-App noch bis zum Produktivbetrieb?</summary>

Unter anderem: Images aus einer Registry statt vom Laptop, HTTPS, Messwerte mit Alarmen, gesammelte Logs, Backups der Daten, ein nachvollziehbarer Weg vom geänderten Manifest in den Cluster und Regeln, die unsichere Manifeste abweisen.

</details>

<details>
<summary>Welche Aufgaben aus diesen drei Tagen stehen im eigenen Team zuerst an?</summary>

Darauf gibt es keine allgemeine Antwort. Häufige erste Schritte: Anwendung in Images und Manifeste bringen (Module 1 bis 5), Konfiguration auslagern (Modul 6), Probes und Ressourcen setzen (Modul 8), ein Chart bauen (Modul 9).

</details>

- Kubernetes selbst startet, verbindet und heilt Container. Messen, Ausliefern, Absichern und Betreiben im Großen übernehmen Projekte rund um Kubernetes.
- Lab 11.3 ist ein Ausblick im Plenum ohne eigene Übung: eine Landkarte, welcher Baustein welche Lücke der Hello-App schließt.

## Begriffe

| Begriff | Bedeutung |
| --- | --- |
| Metrik | Messwert über die Zeit, z. B. Anfragen pro Sekunde oder Speicherverbrauch |
| Trace | Weg einer einzelnen Anfrage durch mehrere Dienste, mit Dauer je Station |
| Observability | Fähigkeit, aus Metriken, Logs und Traces zu erkennen, was in einem System passiert |
| Git | Versionsverwaltung für Dateien: speichert jede Änderung mit Autor und Zeitpunkt |
| GitOps | Git ist die einzige Quelle für den Soll-Zustand; ein Programm im Cluster gleicht den Cluster laufend damit ab |
| Service Mesh | Netz aus Proxys zwischen allen Diensten, das Verschlüsselung, Wiederholungen und Messwerte übernimmt |
| Proxy | Vermittler, der Anfragen annimmt und weiterreicht, z. B. Envoy (aus dem Gateway in Lab 5.3) |
| Admission Policy | Regel, die der API-Server prüft, bevor er ein Objekt speichert; Pod Security (Lab 10.3) ist ein Beispiel |
| CEL | Common Expression Language: kurze Ausdrücke wie `'app' in object.metadata.labels` für Regeln im API-Server |
| Verwalteter Cluster | Cloud-Anbieter betreibt die Control Plane (Lab 2.3), das Team nur Nodes und Anwendungen |
| DRA | Dynamic Resource Allocation: Pods fordern Geräte wie GPUs an, ähnlich wie Speicher über eine PVC (Lab 7.2) |
| MCP | Model Context Protocol: Standard, über den KI-Assistenten Werkzeuge aufrufen, z. B. `kubectl`-Abfragen |

## Landkarte der nächsten Schritte

| Bereich | Frage | Werkzeuge (Auswahl) | Lücke der Hello-App |
| --- | --- | --- | --- |
| Monitoring und Logging | Wie geht es der App, was ist passiert? | Prometheus, Grafana, OpenTelemetry, Loki + Alloy | nur `kubectl top` und `kubectl logs` |
| GitOps | Wie kommt eine Änderung nachvollziehbar in den Cluster? | Argo CD, Flux | `helm upgrade` vom Laptop |
| Service Mesh | Wie sprechen Dienste sicher und messbar miteinander? | Istio, Linkerd | Klartext zwischen Frontend und Backend |
| Policies | Wer verhindert unsichere oder unvollständige Manifeste? | Pod Security, ValidatingAdmissionPolicy, Kyverno | nur Pod Security in `hello-prod` |
| Verwaltete Cluster | Wer betreibt Control Plane und Upgrades? | AKS, EKS, GKE | Ein-Node-Cluster auf dem Laptop |
| KI | Wie laufen KI-Dienste, wie hilft KI im Betrieb? | DRA, AI Conformance, `kubectl-ai`, MCP-Server | – |

## Monitoring mit Prometheus und Grafana

Prometheus holt Metriken in festen Abständen von Zielen ab („pull"), findet die Ziele über die Kubernetes-API selbst und speichert sie als Zeitreihen. Grafana zeigt sie als Dashboards, Alertmanager verschickt Alarme.

<img src="https://prometheus.io/assets/docs/architecture.svg" alt="Prometheus-Architektur: Prometheus-Server mit Retrieval, Zeitreihen-Datenbank und HTTP-Server holt Metriken von Jobs und Exportern, findet Ziele über Kubernetes-Service-Discovery und gibt Alarme an den Alertmanager und Daten an Grafana weiter" width="640">

_Quelle: Prometheus, „Overview" (https://prometheus.io/docs/introduction/overview/), Apache-2.0, abgerufen am 17.11.2026._

Der API-Server des eigenen Clusters liefert schon Metriken in diesem Format:

```bash
kubectl get --raw /metrics | grep '^apiserver_request_total' | head -2
```

```text
apiserver_request_total{code="200",component="apiserver",dry_run="",group="",resource="pods",scope="namespace",subresource="",verb="LIST",version="v1"} 1342
apiserver_request_total{code="201",component="apiserver",dry_run="",group="apps",resource="deployments",scope="resource",subresource="",verb="POST",version="v1"} 37
```

Name, Labels in `{}`, aktueller Wert: genau das sammelt Prometheus von jedem Ziel ein.

| Baustein | Aufgabe | Beispiel |
| --- | --- | --- |
| Ziel (Target) | Adresse, von der Prometheus Metriken abholt | API-Server, Kubelets, Pods mit `/metrics` |
| Exporter | übersetzt Messwerte eines Systems ins Prometheus-Format | `node-exporter` (CPU, Speicher, Platten je Node), `kube-state-metrics` (gewünschte und bereite Kopien je Deployment) |
| Pushgateway | Zwischenablage für kurze Jobs, die vorbei sind, bevor Prometheus abholt | Backup-Job `hello-backup` (Lab 7.3) |
| PromQL | Abfragesprache für Metriken | Beispiele in der Vertiefung |
| Alertmanager | Alarme aus Regeln bündeln und verschicken | E-Mail, Chat, Bereitschaftsdienst |
| Grafana | Dashboards für Metriken und Logs; Ansicht „Explore" für freie Abfragen ohne Dashboard | fertige Kubernetes-Dashboards |
| Prometheus Operator | Operator (Lab 7.3), der Prometheus betreibt; Ziele stehen als Objekte `ServiceMonitor` im Cluster | Teil von `kube-prometheus-stack` |
| Loki | speichert Logs; indiziert nur Labels (Namespace, Pod, Container), nicht den Text, und ist dadurch günstiger als eine Volltextsuche | Abfragesprache LogQL |
| Grafana Alloy | Agent als DaemonSet (Lab 7.3) auf jedem Node; liest Container-Logs und schickt sie an Loki („push", anders als Prometheus) | Nachfolger von Promtail |

- **Einstieg:** Helm-Chart `kube-prometheus-stack` (Prometheus, Grafana, Alertmanager, Exporter, fertige Dashboards), Chart-Version 93.3.1 vom 16.11.2026 ([Artifact Hub](https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack), Stand: 11/2026):
  `helm install monitoring oci://ghcr.io/prometheus-community/charts/kube-prometheus-stack --version 93.3.1 -n monitoring --create-namespace`
- **OpenTelemetry:** herstellerneutraler Standard, um Metriken, Logs und Traces aus der Anwendung zu senden.
- **Neu 2025/2026:** Promtail ist seit 02.03.2026 End-of-Life, Nachfolger ist Alloy ([Grafana](https://grafana.com/docs/loki/latest/send-data/promtail/)).

## GitOps mit Argo CD und Flux

Manifeste und Charts liegen in einem Git-Repository. Argo CD oder Flux läuft im Cluster, vergleicht laufend Repository und Cluster und gleicht Abweichungen an. Eine Änderung heißt dann: Datei im Repository ändern, nicht `kubectl apply` vom Laptop.

<img src="https://argo-cd.readthedocs.io/en/stable/assets/argocd_architecture.png" alt="Argo CD-Architektur: Änderungen kommen über Git, Argo CD mit API-Server, Repository-Server und Application Controller im Cluster verteilt Anwendungen auf mehrere Cluster wie dev, staging und Produktionsregionen" width="480">

_Quelle: Argo CD Dokumentation (https://argo-cd.readthedocs.io/en/stable/), Apache-2.0, abgerufen am 17.11.2026._

| | Argo CD | Flux |
| --- | --- | --- |
| Bedienung | Weboberfläche mit Soll/Ist-Vergleich | Kommandozeile und Kubernetes-Objekte |
| Stärke | Übersicht über viele Anwendungen und Cluster | schlank, baut auf Helm und Kustomize auf |
| Status | CNCF-Projekt (graduated) | CNCF-Projekt (graduated) |

## Service Mesh mit Istio und Linkerd

Ein Service Mesh setzt Proxys zwischen alle Dienste: Verbindungen werden automatisch verschlüsselt (mTLS), Fehlversuche wiederholt, jede Anfrage gemessen. Canary-Gewichte wie in Lab 11.2 gehen dann auch zwischen internen Diensten.

<img src="https://istio.io/latest/docs/ops/deployment/architecture/arch.svg" alt="Istio-Architektur im Sidecar-Modus: Service A und Service B mit je einem Proxy in der Datenebene, Anfragen laufen von Proxy zu Proxy; darunter die Steuerebene mit istiod, die den Proxys Dienst-Adressen, Konfiguration und Zertifikate liefert" width="560">

_Quelle: Istio-Dokumentation, „Architecture" (https://istio.io/latest/docs/ops/deployment/architecture/), Apache-2.0, The Istio Authors, abgerufen am 17.11.2026._

| Teil | Aufgabe | bei Istio |
| --- | --- | --- |
| Datenebene | Proxys, durch die jede Anfrage zwischen Diensten läuft | Sidecar-Modus: Envoy in jedem Pod; Ambient-Modus: `ztunnel` je Node (mTLS), bei Bedarf ein Waypoint-Proxy (Envoy) je Namespace für Regeln nach Pfad oder Header |
| Steuerebene | verteilt Dienst-Adressen, Routing-Regeln und Zertifikate an die Proxys | `istiod`, ein einziges Programm |

| Funktion | Was das Mesh übernimmt |
| --- | --- |
| Verkehrssteuerung | Gewichte, Regeln nach Header, Timeouts, Wiederholungen, Circuit Breaking (Anfragen an einen überlasteten Dienst vorübergehend stoppen) |
| Sicherheit | mTLS: beide Seiten weisen sich per Zertifikat aus, die Verbindung ist verschlüsselt; Regeln, welcher Dienst welchen aufrufen darf |
| Observability | Metriken, Logs und Traces je Anfrage, ohne Änderung am Code |

- **Istio:** verbreitetstes Mesh auf Basis von Envoy, aktuell 1.32 (09.11.2026, [Releases](https://github.com/istio/istio/releases), Stand: 11/2026). Seit Istio 1.24 (07.11.2024) ist der **Ambient-Modus** allgemein verfügbar ([Istio](https://istio.io/latest/news/releases/1.24.x/announcing-1.24/)). Ältere Unterlagen mit Pilot, Mixer, Citadel und Galley sind überholt: Pilot, Citadel und Galley stecken seit Istio 1.5 (2020) in `istiod`, Mixer ist entfallen.
- **Envoy:** 2016 von Lyft veröffentlichter Proxy, seit 2018 CNCF-Projekt mit höchstem Reifegrad ([CNCF](https://www.cncf.io/projects/envoy/)); derselbe Proxy steckt in Envoy Gateway aus Lab 5.3.
- **Linkerd:** kleineres Mesh mit eigenem, schlankem Proxy; Fokus auf einfachen Betrieb ([linkerd.io](https://linkerd.io/)).
- Beide unterstützen die Gateway API; ein Mesh lohnt sich erst bei vielen Diensten.

## Policies im API-Server

Pod Security (Lab 10.3) prüft feste Sicherheitsstufen. Eigene Regeln, z. B. „jedes Deployment braucht das Label `app`", schreibt man als Policy:

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicy
metadata:
  name: require-app-label
spec:
  failurePolicy: Fail
  matchConstraints:
    resourceRules:
      - apiGroups: ["apps"]
        apiVersions: ["v1"]
        operations: ["CREATE", "UPDATE"]
        resources: ["deployments"]
  validations:
    - expression: "has(object.metadata.labels) && 'app' in object.metadata.labels"   # CEL
      message: "Jedes Deployment braucht das Label app."
---
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicyBinding
metadata:
  name: require-app-label
spec:
  policyName: require-app-label
  validationActions: ["Deny"]          # abweisen; "Warn" nur warnen
  matchResources:
    namespaceSelector:
      matchLabels:
        kubernetes.io/metadata.name: hello-prod
```

- **ValidatingAdmissionPolicy:** prüft und weist ab, stabil seit Kubernetes 1.30, ohne Zusatzsoftware ([kubernetes.io](https://kubernetes.io/docs/reference/access-authn-authz/validating-admission-policy/)).
- **MutatingAdmissionPolicy:** ergänzt Felder automatisch (z. B. Standard-Labels). Neu 2025/2026: GA in Kubernetes 1.36 (22.04.2026, [kubernetes.io](https://kubernetes.io/blog/2026/04/22/kubernetes-v1-36-release/)).
- **Kyverno:** Policy-Engine mit eigenen Regeln in YAML, Berichten und fertigen Regelsammlungen ([kyverno.io](https://kyverno.io/)).

## Verwaltete Cluster in der Cloud

| Angebot | Anbieter | Link |
| --- | --- | --- |
| AKS (Azure Kubernetes Service) | Microsoft | [learn.microsoft.com/azure/aks](https://learn.microsoft.com/azure/aks/) |
| EKS (Elastic Kubernetes Service) | Amazon Web Services | [aws.amazon.com/eks](https://aws.amazon.com/eks/) |
| GKE (Google Kubernetes Engine) | Google Cloud | [cloud.google.com/kubernetes-engine](https://cloud.google.com/kubernetes-engine) |

Der Anbieter betreibt Control Plane, etcd und Upgrades; Manifeste, Charts und `kubectl` aus diesem Kurs bleiben gleich. Unterschiede liegen bei Load Balancern, StorageClasses, Anmeldung und Kosten.

## KI auf Kubernetes und KI für den Cluster

- **KI-Dienste im Cluster:** Neu 2025/2026: Seit 11.11.2025 zertifiziert die CNCF Plattformen im Programm **Certified Kubernetes AI Conformance** ([CNCF](https://www.cncf.io/announcements/2025/11/11/cncf-launches-certified-kubernetes-ai-conformance-program-to-standardize-ai-workloads-on-kubernetes/)). Grundlage für GPUs ist **DRA**, GA seit Kubernetes 1.34 (27.08.2025, [kubernetes.io](https://kubernetes.io/blog/2025/08/27/kubernetes-v1-34-release)).
- **KI-Werkzeuge im Betrieb:** [`kubectl-ai`](https://github.com/GoogleCloudPlatform/kubectl-ai) übersetzt Fragen in `kubectl`-Befehle (v0.0.31, 27.03.2026); der [Kubernetes-MCP-Server](https://github.com/containers/kubernetes-mcp-server) gibt KI-Assistenten Zugriff auf den Cluster (v0.1.3, 13.11.2026). Stand: 11/2026.
- **Nur mit Lesekonto:** Ein KI-Werkzeug handelt mit den Rechten der kubeconfig. Dafür ein eigenes Konto mit Leserechten anlegen (Role `viewer` aus Lab 10.1, ServiceAccount aus Lab 10.2), nie das Admin-Konto.

## Zertifizierungen CKAD und CKA

| Prüfung | Für | Schwerpunkte |
| --- | --- | --- |
| CKAD (Certified Kubernetes Application Developer) | Entwicklung | Pods, Deployments, Probes, ConfigMaps, Secrets, Services, Helm |
| CKA (Certified Kubernetes Administrator) | Betrieb | Cluster, Nodes, RBAC, Storage, Netzwerk, seit 18.02.2025 auch Gateway API und Helm |
| CKS (Certified Kubernetes Security Specialist) | Sicherheit | setzt CKA voraus |

Alle drei sind praktische Prüfungen im Terminal und zielen auf Kubernetes v1.37 (Stand: 11/2026, [Lehrpläne](https://github.com/cncf/curriculum), [CKA-Änderungen](https://training.linuxfoundation.org/certified-kubernetes-administrator-cka-program-changes/)). Die Labs dieses Kurses decken einen großen Teil des CKAD-Stoffs ab.

## Fazit

- Kubernetes ist der Kern; Monitoring, GitOps, Service Mesh und Policies sind eigene Projekte, die sich nach Bedarf dazunehmen lassen.
- Für die Hello-App sind die nächsten Bausteine meist Prometheus/Grafana und GitOps; ein Service Mesh lohnt sich erst bei vielen Diensten.
- KI-Werkzeuge bekommen nur Leserechte; neue Funktionen wie MutatingAdmissionPolicy und DRA sind seit 2025/2026 stabil.

Im Plenum entsteht aus dieser Landkarte die Liste der ersten Bausteine für die eigenen Projekte.

## Vertiefung

### Abfragen in PromQL und LogQL

| Sprache | Abfrage | Ergebnis |
| --- | --- | --- |
| PromQL | `sum by (pod) (rate(container_cpu_usage_seconds_total{namespace="hello"}[5m]))` | CPU-Verbrauch je Pod im Namespace `hello`, Mittel der letzten 5 Minuten |
| PromQL | `sum by (namespace) (rate(container_cpu_usage_seconds_total[5m]))` | CPU-Verbrauch je Namespace |
| LogQL | `{namespace="hello"}` | alle Log-Zeilen aus dem Namespace `hello` |
| LogQL | `{namespace="hello", container="frontend"} \|= "Backend nicht erreichbar"` | nur Zeilen des Frontends, die diesen Text enthalten |

Welche Labels Loki kennt, legt die Alloy-Konfiguration fest; `namespace`, `pod` und `container` sind üblich.

### Envoy-Begriffe in der Gateway API

| Envoy-Konfiguration | Bedeutung | Gegenstück aus Lab 5.3 |
| --- | --- | --- |
| Listener | Port und Protokoll, auf dem Envoy Verbindungen annimmt | Listener `http`, Port 80 im Gateway |
| Route | Regel nach Pfad oder Header, welches Ziel eine Anfrage bekommt | Regel in der HTTPRoute, z. B. `/api` |
| Cluster | Gruppe gleichartiger Ziele mit Lastverteilung | Service in `backendRefs` mit seinen Pods |

Envoy Gateway übersetzt Gateway und HTTPRoute in diese Envoy-Konfiguration. Timeouts und Wiederholungen gehören inzwischen zum Standard der Gateway API ([Timeouts](https://gateway-api.sigs.k8s.io/guides/http-timeouts/), [Retries](https://gateway-api.sigs.k8s.io/geps/gep-1731/), Stand: 11/2026), etwa für die Regel `/api` der Hello-App:

```yaml
  rules:
    - matches:
        - path: { type: PathPrefix, value: /api }
      backendRefs:
        - name: hello-backend
          port: 80
      timeouts:
        request: 20s              # Anfrage nach 20 Sekunden mit Fehler beenden
      retry:
        codes: [500, 502, 503]    # bei diesen Antworten des Backends
        attempts: 3               # höchstens dreimal wiederholen
```
