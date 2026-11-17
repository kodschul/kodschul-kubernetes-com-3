# Kubernetes Einführung – Kursüberblick

## Die Entwicklung von Kubernetes

- Container (Docker, 2013) machen Anwendungen portabel: ein Paket läuft überall gleich.
- Mit vielen Containern auf vielen Servern braucht es eine Steuerung: Kubernetes (2014, v1.0 2015).
- 82 % der Organisationen mit Containern betreiben Kubernetes in Produktion (CNCF-Umfrage 2025).
- 2025/2026: Gateway API löst ingress-nginx ab, Helm 4 erscheint, Headlamp ersetzt das Dashboard.

## Was ist Kubernetes?

- Open-Source-Plattform, die Container auf einem Cluster von Servern betreibt.
- Arbeitet nach dem gewünschten Zustand: verteilt, ersetzt, skaliert und aktualisiert Container selbst.
- Vergleich: Container sind die Normkisten, Kubernetes ist die Hafenleitstelle.

| Begriff | Bedeutung |
| --- | --- |
| Container | isolierter Prozess aus einem Image, teilt den Kernel des Rechners |
| Image | unveränderliches Paket aus App, Laufzeit und Bibliotheken |
| Cluster | Control Plane plus Worker Nodes, die Container ausführen |
| Pod | kleinste Einheit in Kubernetes: ein oder mehrere Container mit gemeinsamer IP |
| Manifest | YAML-Datei, die den gewünschten Zustand eines Objekts beschreibt |

Details: [Lab 1.1](../m01-containers/l01-why-containers/l01-why-containers-thx.md) · [Lab 2.1](../m02-kubernetes-intro/l01-why-kubernetes/l01-why-kubernetes-thx.md)

## Warum Kubernetes?

| Aufgabe | Container von Hand (`docker run`) | Kubernetes |
| --- | --- | --- |
| Ausfall eines Containers | jemand startet ihn neu | Controller ersetzt ihn automatisch |
| mehr Last | Container von Hand dazustarten | `kubectl scale` oder Autoscaler |
| neue Version | stoppen, starten, hoffen | Rolling Update mit Rollback |
| Adresse der App | IP ändert sich bei jedem Neustart | Service mit festem DNS-Namen |
| Konfiguration | im Image oder per Hand | ConfigMap und Secret |
| viele Server | Absprache per Hand | Scheduler verteilt die Pods |

Kubernetes lohnt sich ab mehreren Diensten oder Servern; für eine einzelne kleine App reicht oft weniger.

## Ziel und Ergebnis

- Container und Images bauen, Kubernetes-Objekte lesen, schreiben und anwenden.
- Eine Anwendung mit Konfiguration, Speicher, Health Checks und Autoscaling betreiben.
- Die Anwendung als Helm-Chart in mehreren Umgebungen installieren und absichern.
- Fehler von außen nach innen finden; neue Versionen kontrolliert ausrollen.

## Projekt: Hello-App

- Zwei Python/Flask-Dienste: `hello-frontend` (HTML-Seite) und `hello-backend` (JSON).
- Die Seite zeigt Version, Farbe, Pod-Name und IP: Lastverteilung und Rollouts werden im Browser sichtbar.
- Jeder Aufruf landet in `access.log`: verlorene und dauerhafte Daten werden sichtbar.

| Tag | Stand der Hello-App am Ende |
| --- | --- |
| 1 | eigene Images `v1`/`v2`, Backend und Frontend als Pods im Namespace `hello` |
| 2 | Deployments, Services, `http://hello.localhost`, ConfigMap, Secret, PVC, Backup-CronJob |
| 3 | Probes, Ressourcen, Autoscaling, Helm-Chart für Dev und Prod, Rechte, Pod Security, Canary |

Projektdateien: [project/README.md](../project/README.md)

## Tagesablauf

| Zeit | Tag 1 | Tag 2 | Tag 3 |
| --- | --- | --- | --- |
| 09:00–10:30 | Auftakt, Modul 1 Container | Recap, Modul 4 Deployments | Recap, Modul 8 Health Checks und Ressourcen |
| 10:30–10:45 | Pause | Pause | Pause |
| 10:45–12:15 | Modul 1 Images, Modul 2 Kubernetes-Grundlagen | Modul 5 Services und Gateway API | Modul 9 Helm |
| 12:15–13:15 | Mittag | Mittag | Mittag |
| 13:15–14:45 | Modul 2 Architektur und Manifeste, Modul 3 erster Pod | Modul 6 Konfiguration und Umgebungen | Modul 10 Zugriff und Sicherheit |
| 14:45–15:00 | Pause | Pause | Pause |
| 15:00–16:30 | Modul 3 Sidecars, Labels, Pod-Fehler | Modul 7 Speicher und Workload-Typen | Modul 11 Fehlersuche, Canary, Ausblick |

Alle Labs mit Minuten: [topics.md](topics.md)

## Arbeitsweise

- Jedes Lab: Leitfragen, Theorie mit Beispiel, Übung am eigenen Cluster, Lösung zum Vergleich.
- Gearbeitet wird im Ordner `project/playground/`; Manifeste liegen in `playground/k8s/`.
- Jeder Lab-Stand liegt fertig in `project/examples/` und lässt sich mit `kubectl apply -f` wiederherstellen.
- Cheatsheets im Modulordner fassen die Befehle zusammen.

## Voraussetzungen

- Terminal-Grundlagen (Ordner wechseln, Befehle ausführen); Docker-Kenntnisse helfen, sind aber nicht nötig.
- Docker Desktop mit Kubernetes, kubectl, Helm 4, Headlamp, VS Code: [Setup](../00-setup-and-installation.md).
- Rechner mit mindestens 16 GB RAM, Admin-Rechten für die Installation und Internetzugang zu Docker Hub und GitHub.
