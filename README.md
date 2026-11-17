<div align="center">

<img src="assets/kodschul-logo.png" alt="Kodschul" width="220" />

# Kubernetes Einführung

3-Tage-Workshop · Docker, Kubernetes 1.36/1.37, Helm 4 · Deutsch

**Eine eigene Web-App auf Kubernetes betreiben, aktualisieren und absichern**

</div>

---

[Worum es geht](#worum-es-geht) · [Start](#start) · [Tag 1](#tag-1) · [Tag 2](#tag-2) · [Tag 3](#tag-3) · [Hilfe](#hilfe)

## Worum es geht

- Container machen Anwendungen portabel; Kubernetes betreibt viele davon zuverlässig auf vielen Servern.
- Der Workshop baut alles an einem durchgehenden Projekt auf: der Hello-App aus Frontend und Backend.
- Jeder Schritt läuft im eigenen lokalen Cluster: vom ersten Container bis zum Helm-Chart mit Rechten und Canary-Release.
- Stand November 2026: Gateway API statt ingress-nginx, Headlamp statt Dashboard, Helm 4, native Sidecars.

| | |
| --- | --- |
| **Für** | Softwareentwicklung, DevOps und IT-Betrieb ohne Kubernetes-Erfahrung |
| **Vorkenntnisse** | Terminal-Grundlagen; Docker hilfreich, aber nicht nötig |
| **Werkzeuge** | Docker Desktop mit Kubernetes, kubectl, Helm 4, Headlamp, VS Code |
| **Projekt** | Hello-App: zwei Python/Flask-Dienste, die von Pod zu Helm-Chart wachsen |
| **Material** | Handout pro Lab, Cheatsheet pro Modul, fertiger Projektstand für jedes Lab |

## Start

1. Rechner einrichten: [Setup und Installation](00-setup-and-installation.md)
2. Ziel und Tagesablauf lesen: [Kursüberblick](m00-overview/overview.md)
3. Projektordner öffnen: [Hello-App](project/README.md), im Terminal `cd project`
4. Mit dem ersten Lab starten: [Lab 1.1: Warum Container?](m01-containers/l01-why-containers/l01-why-containers-thx.md)

## Tag 1

| Modul | Kernthemen | Ergebnis |
| --- | --- | --- |
| 1 [Container](m01-containers/l01-why-containers/l01-why-containers-thx.md) | Container vs. VM, Docker-CLI, Volumes, Dockerfile, Tags | Images `hello-backend:v1`, `hello-frontend:v1`/`v2` |
| 2 [Kubernetes-Grundlagen](m02-kubernetes-intro/l01-why-kubernetes/l01-why-kubernetes-thx.md) | Orchestrierung, lokales Cluster, Architektur, Manifeste, Namespaces | Cluster `Ready`, Namespace `hello` |
| 3 [Pods](m03-pods/l01-first-pod/l01-first-pod-thx.md) | erster Pod, Sidecars, Labels, Fehlerbilder | Hello-App als Pods im Browser |

## Tag 2

| Modul | Kernthemen | Ergebnis |
| --- | --- | --- |
| 4 [Deployments](m04-deployments/l01-replicasets/l01-replicasets-thx.md) | ReplicaSet, Self-Healing, Skalieren, Rollout, Rollback | Update `v1 → v2` ohne Ausfall |
| 5 [Services und Zugriff von außen](m05-services/l01-clusterip/l01-clusterip-thx.md) | ClusterIP, DNS, NodePort, LoadBalancer, Gateway API | `http://hello.localhost` |
| 6 [Konfiguration und Umgebungen](m06-configuration/l01-configmaps/l01-configmaps-thx.md) | ConfigMaps, Secrets, Namespaces für Dev und Prod | Farbe und Passwort ohne neues Image |
| 7 [Speicher und Workload-Typen](m07-storage/l01-volumes/l01-volumes-thx.md) | Volumes, PVC, StorageClass, StatefulSet, DaemonSet, CronJob | `access.log` überlebt, Backup per CronJob |

## Tag 3

| Modul | Kernthemen | Ergebnis |
| --- | --- | --- |
| 8 [Health Checks und Ressourcen](m08-health-resources/l01-probes/l01-probes-thx.md) | Probes, Requests und Limits, QoS, Autoscaling | Ausfall ohne Störung, HPA skaliert |
| 9 [Helm](m09-helm/l01-helm-basics/l01-helm-basics-thx.md) | Charts, eigenes Chart, Releases, Rollback | Chart `hello` für Dev und Prod |
| 10 [Zugriff und Sicherheit](m10-security/l01-rbac/l01-rbac-thx.md) | RBAC, ServiceAccounts, Pod Security | Hello-App unter `restricted` |
| 11 [Fehlersuche und Release-Strategien](m11-operations/l01-troubleshooting/l01-troubleshooting-thx.md) | Fehlersuche von außen nach innen, Canary, Blue/Green, Ökosystem | Canary `v2` über Gateway-Gewichte |

- Jedes Lab hat drei Seiten: Theorie (`…-thx.md`), Übung (`…-exc.md`) und Lösung (`…-sol.md`).
- Cheatsheets liegen im jeweiligen Modulordner.
- Alle Labs mit Zeiten: [Module und Labs](m00-overview/topics.md).

## Hilfe

- **Projektstand wiederherstellen:** jeder Lab-Stand liegt fertig unter `project/examples/<modul>/<lab>/`, z. B. für den Stand nach Lab 5.3:

  ```bash
  cd project
  kubectl apply -f examples/m05-services/l03-gateway-api/
  ```

- **Images fehlen** (neuer Rechner, Cluster zurückgesetzt): `bash build-images.sh` im Ordner `project/` baut alle Hello-Images neu.
- **Lösungen vergleichen:** jede Übung hat eine Lösung mit Befehlen und erwarteter Ausgabe; die Dateien je Lab liegen im [Projektordner](project/README.md).
- **Nachschlagen:** [Glossar](m00-overview/glossary.md) · [FAQ](m00-overview/faq.md) · [Best Practices](m00-overview/best-practices.md)
- **Frühere Fassung:** Kursmaterial mit Stand März 2025 im Branch [`v1`](https://github.com/kodschul/kodschul-kubernetes-com-3/tree/v1).

---

<div align="center">

<sub>© Nextise GmbH · <a href="https://www.kodschul.com">kodschul.com</a> · Kompetenz aufbauen – von der sicheren KI-Anwendung bis zur modernen IT-Basis</sub>

</div>
