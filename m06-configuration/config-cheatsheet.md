# Konfiguration und Umgebungen – Cheatsheet (Modul 6)

Alle Befehle im Ordner `project/`, Namespace `hello` als Standard im Kontext.

## ConfigMaps

| Befehl | Wirkung |
| --- | --- |
| `kubectl apply -f playground/k8s/configmap.yaml` | ConfigMap anlegen oder ändern |
| `kubectl create configmap hello-config --from-literal=APP_COLOR=lightyellow` | ConfigMap per Befehl anlegen |
| `kubectl create configmap hello-config --from-literal=… --dry-run=client -o yaml` | YAML-Vorlage erzeugen, nichts anlegen |
| `kubectl create configmap hello-files --from-file=config.json` | Datei als Schlüssel übernehmen (Schlüssel = Dateiname) |
| `kubectl get configmaps` | ConfigMaps im Namespace |
| `kubectl describe configmap hello-config` | Schlüssel und Werte anzeigen |
| `kubectl get configmap hello-config -o yaml` | vollständiges Objekt als YAML |

## ConfigMap im Deployment

| YAML | Wirkung |
| --- | --- |
| `envFrom: [{configMapRef: {name: hello-config}}]` | alle Schlüssel als Umgebungsvariablen |
| `env: [{name: X, valueFrom: {configMapKeyRef: {name: hello-config, key: X}}}]` | ein Schlüssel als Umgebungsvariable |
| `volumes: [{name: config, configMap: {name: hello-files}}]` + `volumeMounts` | Schlüssel als Dateien im Container |

| Befehl | Wirkung |
| --- | --- |
| `kubectl rollout restart deployment/frontend` | Pods schrittweise ersetzen, damit neue Umgebungsvariablen gelten |
| `kubectl rollout status deployment/frontend` | warten, bis der Neustart fertig ist |
| `kubectl exec deploy/frontend -- env \| grep -E '^(APP_\|BACKEND_URL)'` | Umgebungsvariablen eines Pods prüfen |

## Secrets

| Befehl | Wirkung |
| --- | --- |
| `kubectl create secret generic hello-secret --from-literal=admin-password=<Wert>` | Secret anlegen, ohne dass der Wert in einer Datei steht |
| `kubectl create secret generic hello-secret --from-literal=… --dry-run=client -o yaml \| kubectl apply -f -` | Wert eines bestehenden Secrets ersetzen |
| `kubectl get secrets` | Secrets mit Typ und Anzahl der Schlüssel |
| `kubectl describe secret hello-secret` | Schlüssel mit Länge in Bytes, ohne Werte |
| `kubectl get secret hello-secret -o yaml` | Werte Base64-codiert |
| `kubectl get secret hello-secret -o jsonpath='{.data.admin-password}' \| base64 -d` | einen Wert in Klartext zurückwandeln |
| `kubectl exec deploy/frontend -- ls -l /etc/hello-secret/` | eingebundene Secret-Dateien im Pod ansehen |
| `kubectl delete secret hello-secret` | Secret löschen |

| YAML | Wirkung |
| --- | --- |
| `stringData: {admin-password: …}` | Klartext beim Anlegen, gespeichert als Base64 unter `data` |
| `volumes: [{name: admin-secret, secret: {secretName: hello-secret}}]` + `volumeMounts` mit `readOnly: true` | Secret als Datei einbinden (bevorzugt) |
| `env: [{name: X, valueFrom: {secretKeyRef: {name: hello-secret, key: admin-password}}}]` | Secret als Umgebungsvariable (nur wenn nötig) |

## Namespaces und Umgebungen

| Befehl | Wirkung |
| --- | --- |
| `kubectl apply -f playground/k8s/namespaces.yaml` | Namespaces `hello-dev` und `hello-prod` anlegen |
| `kubectl get namespaces -l app=hello` | Namespaces mit Label filtern |
| `kubectl apply -n hello-dev -f playground/k8s/dev/ -f playground/k8s/backend-deployment.yaml …` | geteilte Manifeste plus Umgebungs-ConfigMap in einem Namespace anwenden |
| `kubectl get pods -n hello-dev` | Objekte eines bestimmten Namespace |
| `kubectl get deployments -A -l app=hello` | Objekte aus allen Namespaces |
| `kubectl config set-context --current --namespace=hello` | Standard-Namespace des Kontexts setzen |
| `kubectl port-forward -n hello-dev svc/frontend 8081:80` | Frontend einer Umgebung lokal öffnen |
| `kubectl api-resources --namespaced=false` | clusterweite Objektarten auflisten |
| `kubectl describe resourcequota -n hello-dev` | Verbrauch und Grenzen eines Namespace |

| DNS-Name | erreicht |
| --- | --- |
| `backend` | Backend im eigenen Namespace |
| `backend.hello-prod` | Backend in `hello-prod`, von überall |
| `backend.hello-prod.svc.cluster.local` | dasselbe, vollständiger Name |

## Objekte der Hello-App nach Modul 6

| Objekt | Name | Namespace | Kern |
| --- | --- | --- | --- |
| ConfigMap | `hello-config` | `hello` | `BACKEND_URL: http://backend`, `APP_COLOR: lightyellow` |
| Secret | `hello-secret` | `hello`, `hello-dev`, `hello-prod` | `admin-password` (Übungswert), im Frontend unter `/etc/hello-secret` |
| ConfigMap | `hello-config` | `hello-dev` / `hello-prod` | `APP_COLOR: lightgreen` / `lightblue` |
| Deployments, Services | `backend`, `frontend` | `hello`, `hello-dev`, `hello-prod` | gleiche Manifeste, ohne `namespace`-Feld |
