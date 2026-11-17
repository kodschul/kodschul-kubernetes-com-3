# Hello-App: Projektdateien

Die Hello-App besteht aus zwei kleinen Python/Flask-Diensten und wächst im Kurs vom Container bis zum Helm-Chart. Handouts: [`../README.md`](../README.md).

| Dienst | Antwort | Wichtige Umgebungsvariablen |
| --- | --- | --- |
| `hello-backend` | JSON mit Pod, IP, Uhrzeit, Version unter `/` und `/api`; `/healthz` | `APP_VERSION`, `PORT` |
| `hello-frontend` | HTML-Seite mit Version, Farbe, Pod, Backend-Antwort, Passwort-Status; schreibt `access.log` | `BACKEND_URL`, `APP_COLOR`, `APP_VERSION`, `PORT`, `DATA_DIR`, `SECRET_FILE` |

Zusätzliche Endpunkte des Frontends: `/healthz` (Probes), `/fail` und `/recover` (simulierter Ausfall, Lab 8.1), `/work` (CPU-Last, Lab 8.3). `STARTUP_DELAY=<Sekunden>` verzögert den Start.

## Ordner

```text
project/
├── build-images.sh      baut alle Hello-Images neu (bash build-images.sh)
├── playground/          Arbeitsbereich
│   ├── backend/         app.py, requirements.txt, ab Lab 1.3 Dockerfile
│   ├── frontend/        app.py, requirements.txt, ab Lab 1.3 Dockerfile
│   └── k8s/             eigene Manifeste; ab Lab 9.2 zusätzlich das Chart playground/hello/
├── starters/            Startdateien der Übungen: mNN-lNN-<name>, mit TODO-Markierungen
├── examples/            fertiger Stand je Lab: examples/<modul>/<lab>/
└── variants/            fehlerhafte Manifeste für die Fehler-Labs 3.4 und 11.1
```

## Arbeitsweise je Lab

1. Starter aus `starters/` nach `playground/k8s/` (bzw. `playground/backend/`, `playground/frontend/`) kopieren, die TODOs ergänzen.
2. Anwenden, z. B. `kubectl apply -f playground/k8s/`.
3. Mit dem fertigen Stand in `examples/<modul>/<lab>/` vergleichen.

Alle Befehle laufen im Ordner `project/` (Terminal unter macOS/Linux, Git Bash unter Windows).

## Stand wiederherstellen

```bash
# Images fehlen (neuer Rechner, Cluster zurückgesetzt)
bash build-images.sh

# Stand eines Labs im Namespace hello herstellen, z. B. nach Lab 7.2
kubectl apply -f examples/m07-storage/l02-persistent-volumes/
```

- Jeder Ordner in `examples/` bis Modul 8 ist ein vollständiger Stand; `00-namespace.yaml` legt zuerst den Namespace an.
- Ab Lab 5.3 braucht der Stand Envoy Gateway im Cluster (Installation in [Lab 5.3](../m05-services/l03-gateway-api/l03-gateway-api-exc.md)).
- Lab 6.3 (`hello-dev`, `hello-prod`) und die Helm-Stände ab Modul 9 nennen ihre eigenen Befehle in der jeweiligen Übung.
- Abweichende Reste im Namespace entfernen: `kubectl delete namespace hello`, danach den gewünschten Stand anwenden.

## Labs, Beispiele und Starter

| Lab | Beispiel (`examples/`) | Starter (`starters/`) |
| --- | --- | --- |
| 1.1 Warum Container? | – | – |
| 1.2 Container bedienen | – | – |
| 1.3 Images bauen | [`m01-containers/l03-images/`](examples/m01-containers/l03-images/) | [`m01-l03-backend.Dockerfile`](starters/m01-l03-backend.Dockerfile), [`m01-l03-frontend.Dockerfile`](starters/m01-l03-frontend.Dockerfile) |
| 2.1 Warum Kubernetes? | – | – |
| 2.2 Lokales Cluster starten | – | – |
| 2.3 Architektur eines Clusters | – | – |
| 2.4 Manifeste und deklaratives Arbeiten | [`m02-kubernetes-intro/l04-manifests/`](examples/m02-kubernetes-intro/l04-manifests/) | – |
| 3.1 Der erste Pod | [`m03-pods/l01-first-pod/`](examples/m03-pods/l01-first-pod/) | [`m03-l01-backend-pod.yaml`](starters/m03-l01-backend-pod.yaml), [`m03-l01-frontend-pod.yaml`](starters/m03-l01-frontend-pod.yaml) |
| 3.2 Mehrere Container in einem Pod | [`m03-pods/l02-sidecars/`](examples/m03-pods/l02-sidecars/) | [`m03-l02-frontend-pod.yaml`](starters/m03-l02-frontend-pod.yaml) |
| 3.3 Labels und Selektoren | [`m03-pods/l03-labels/`](examples/m03-pods/l03-labels/) | – |
| 3.4 Pod-Fehler lesen | – | – |
| 4.1 ReplicaSets und Self-Healing | [`m04-deployments/l01-replicasets/`](examples/m04-deployments/l01-replicasets/) | [`m04-l01-frontend-replicaset.yaml`](starters/m04-l01-frontend-replicaset.yaml) |
| 4.2 Deployments | [`m04-deployments/l02-deployments/`](examples/m04-deployments/l02-deployments/) | [`m04-l02-frontend-deployment.yaml`](starters/m04-l02-frontend-deployment.yaml) |
| 4.3 Rollout und Rollback | [`m04-deployments/l03-rollouts/`](examples/m04-deployments/l03-rollouts/) | [`m04-l03-frontend-deployment.yaml`](starters/m04-l03-frontend-deployment.yaml) |
| 5.1 Services und DNS | [`m05-services/l01-clusterip/`](examples/m05-services/l01-clusterip/) | [`m05-l01-backend-service.yaml`](starters/m05-l01-backend-service.yaml) |
| 5.2 NodePort, LoadBalancer und Port-Forward | [`m05-services/l02-external-access/`](examples/m05-services/l02-external-access/) | [`m05-l02-frontend-service.yaml`](starters/m05-l02-frontend-service.yaml) |
| 5.3 HTTP-Routing mit der Gateway API | [`m05-services/l03-gateway-api/`](examples/m05-services/l03-gateway-api/) | [`m05-l03-gateway.yaml`](starters/m05-l03-gateway.yaml), [`m05-l03-httproute.yaml`](starters/m05-l03-httproute.yaml) |
| 6.1 ConfigMaps | [`m06-configuration/l01-configmaps/`](examples/m06-configuration/l01-configmaps/) | [`m06-l01-configmap.yaml`](starters/m06-l01-configmap.yaml), [`m06-l01-frontend-deployment.yaml`](starters/m06-l01-frontend-deployment.yaml) |
| 6.2 Secrets | [`m06-configuration/l02-secrets/`](examples/m06-configuration/l02-secrets/) | [`m06-l02-frontend-deployment.yaml`](starters/m06-l02-frontend-deployment.yaml) |
| 6.3 Namespaces für Umgebungen | [`m06-configuration/l03-environments/`](examples/m06-configuration/l03-environments/) | [`m06-l03-configmap.yaml`](starters/m06-l03-configmap.yaml), [`m06-l03-namespaces.yaml`](starters/m06-l03-namespaces.yaml) |
| 7.1 Volumes | [`m07-storage/l01-volumes/`](examples/m07-storage/l01-volumes/) | [`m07-l01-frontend-deployment.yaml`](starters/m07-l01-frontend-deployment.yaml) |
| 7.2 PersistentVolumes und StorageClasses | [`m07-storage/l02-persistent-volumes/`](examples/m07-storage/l02-persistent-volumes/) | [`m07-l02-frontend-deployment.yaml`](starters/m07-l02-frontend-deployment.yaml), [`m07-l02-pvc.yaml`](starters/m07-l02-pvc.yaml) |
| 7.3 StatefulSets, DaemonSets, Jobs und CronJobs | [`m07-storage/l03-workload-types/`](examples/m07-storage/l03-workload-types/) | [`m07-l03-cronjob.yaml`](starters/m07-l03-cronjob.yaml) |
| 8.1 Liveness, Readiness und Startup Probes | [`m08-health-resources/l01-probes/`](examples/m08-health-resources/l01-probes/) | [`m08-l01-backend-deployment.yaml`](starters/m08-l01-backend-deployment.yaml), [`m08-l01-frontend-deployment.yaml`](starters/m08-l01-frontend-deployment.yaml) |
| 8.2 Requests, Limits und QoS | [`m08-health-resources/l02-resources/`](examples/m08-health-resources/l02-resources/) | [`m08-l02-backend-deployment.yaml`](starters/m08-l02-backend-deployment.yaml), [`m08-l02-frontend-deployment.yaml`](starters/m08-l02-frontend-deployment.yaml) |
| 8.3 Horizontal Pod Autoscaler | [`m08-health-resources/l03-autoscaling/`](examples/m08-health-resources/l03-autoscaling/) | [`m08-l03-hpa.yaml`](starters/m08-l03-hpa.yaml) |
| 9.1 Helm-Grundlagen | – | – |
| 9.2 Eigenes Chart für die Hello-App | [`m09-helm/l02-own-chart/`](examples/m09-helm/l02-own-chart/) | [`m09-l02-hello`](starters/m09-l02-hello) |
| 9.3 Releases verwalten | [`m09-helm/l03-releases/`](examples/m09-helm/l03-releases/) | [`m09-l03-values-dev.yaml`](starters/m09-l03-values-dev.yaml), [`m09-l03-values-prod.yaml`](starters/m09-l03-values-prod.yaml) |
| 10.1 RBAC | [`m10-security/l01-rbac/`](examples/m10-security/l01-rbac/) | [`m10-l01-rbac.yaml`](starters/m10-l01-rbac.yaml) |
| 10.2 ServiceAccounts | [`m10-security/l02-service-accounts/`](examples/m10-security/l02-service-accounts/) | [`m10-l02-api-test-pod.yaml`](starters/m10-l02-api-test-pod.yaml), [`m10-l02-service-account.yaml`](starters/m10-l02-service-account.yaml) |
| 10.3 Pod Security | [`m10-security/l03-pod-security/`](examples/m10-security/l03-pod-security/) | [`m10-l03-hello`](starters/m10-l03-hello), [`m10-l03-values-prod.yaml`](starters/m10-l03-values-prod.yaml) |
| 11.1 Fehlersuche mit System | – | – |
| 11.2 Canary und Blue/Green | [`m11-operations/l02-release-strategies/`](examples/m11-operations/l02-release-strategies/) | [`m11-l02-canary-route.yaml`](starters/m11-l02-canary-route.yaml), [`m11-l02-frontend-v2-deployment.yaml`](starters/m11-l02-frontend-v2-deployment.yaml), [`m11-l02-frontend-v2-service.yaml`](starters/m11-l02-frontend-v2-service.yaml) |
| 11.3 Das Kubernetes-Ökosystem | – | – |

Labs ohne Eintrag verändern das Projekt nicht oder arbeiten direkt mit eigenen Dateien aus dem vorigen Lab.

## Fehlerbilder

| Ordner | Lab | Inhalt |
| --- | --- | --- |
| [`variants/m03-l04-pod-errors/`](variants/m03-l04-pod-errors/) | 3.4 | drei Pods mit typischen Startfehlern |
| [`variants/m11-l01-troubleshooting/`](variants/m11-l01-troubleshooting/) | 11.1 | drei vollständige Hello-Apps im Namespace `hello-debug` mit je einem versteckten Fehler |

## Images

| Image | Entsteht in | Hinweis |
| --- | --- | --- |
| `hello-backend:v1` | Lab 1.3 | lokal gebaut, `imagePullPolicy: Never` |
| `hello-frontend:v1`, `hello-frontend:v2` | Lab 1.3 | `v2` hat eine andere Farbe |
| `hello-backend:v1-nonroot`, `hello-frontend:v1-nonroot`, `hello-frontend:v2-nonroot` | Lab 10.3 | Benutzer ohne root-Rechte (UID 10001), Port 8080 |
| `python:3.14-alpine`, `nginx:1.30-alpine`, `busybox:1.37`, `curlimages/curl:8.23.0` | öffentlich (Docker Hub) | anonym 100 Pulls je 6 Stunden pro IP-Adresse |
