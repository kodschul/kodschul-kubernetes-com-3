# Pods – Cheatsheet (Modul 3)

Alle Befehle wirken im Standard-Namespace des Kontexts (`hello`); `-n <namespace>` wählt einen anderen.

## Pods anlegen und löschen

| Befehl | Wirkung |
| --- | --- |
| `kubectl apply -f playground/k8s/backend-pod.yaml` | Pod aus Manifest anlegen oder Labels/Image aktualisieren |
| `kubectl apply -f playground/k8s/` | alle Manifeste eines Ordners anwenden |
| `kubectl run frontend-v2 --image=hello-frontend:v2 --image-pull-policy=Never --labels=app=hello,tier=frontend,version=v2` | Testpod imperativ starten |
| `kubectl delete pod backend` | Pod löschen |
| `kubectl delete -f playground/pod-errors/` | alle Pods aus den Dateien eines Ordners löschen |
| `kubectl delete pod frontend && kubectl apply -f playground/k8s/frontend-pod.yaml` | Pod mit geändertem `env`, `command` oder Containern neu anlegen |

## Pods ansehen

| Befehl | Wirkung |
| --- | --- |
| `kubectl get pods` | Status, Bereitschaft, Neustarts |
| `kubectl get pods -o wide` | zusätzlich Pod-IP und Node |
| `kubectl get pod frontend -w` | Änderungen live verfolgen (**Strg+C**) |
| `kubectl describe pod frontend` | alle Details, Container-Zustand, Events |

## Logs, Shell, Port-Forward

| Befehl | Wirkung |
| --- | --- |
| `kubectl logs backend` | Ausgabe des Containers |
| `kubectl logs -f frontend` | Ausgabe live mitlesen |
| `kubectl logs frontend -c log-reader` | Ausgabe eines bestimmten Containers im Pod |
| `kubectl logs fehler-crash --previous` | Ausgabe des letzten abgestürzten Versuchs |
| `kubectl exec backend -- env` | Befehl im Container ausführen |
| `kubectl exec frontend -c frontend -- cat /data/access.log` | Befehl in einem bestimmten Container |
| `kubectl exec -it frontend -- sh` | Shell im Container öffnen (`exit` beendet) |
| `kubectl port-forward pod/frontend 8080:80` | `http://localhost:8080` zum Pod-Port 80 weiterleiten |

## Labels, Selektoren, Annotations

| Befehl | Wirkung |
| --- | --- |
| `kubectl get pods --show-labels` | alle Labels anzeigen |
| `kubectl get pods -L tier,version` | Labels als eigene Spalten |
| `kubectl get pods -l tier=frontend,version=v1` | filtern, alle Bedingungen müssen passen |
| `kubectl get pods -l tier!=frontend` | filtern auf ungleich |
| `kubectl get pods -l 'version in (v1,v2)'` | Mengen-Selektor |
| `kubectl get pods -l '!stage'` | Pods ohne Label `stage` |
| `kubectl label pod frontend-v2 stage=test` | Label setzen |
| `kubectl label pod frontend-v2 stage=review --overwrite` | Label-Wert ändern |
| `kubectl label pod frontend-v2 stage-` | Label entfernen |
| `kubectl annotate pod frontend-v2 description="Testpod"` | Annotation setzen |
| `kubectl delete pods -l stage=review` | alle passenden Pods löschen |

## Fehlersuche

| Befehl | Wirkung |
| --- | --- |
| `kubectl get pods` → `kubectl describe pod <name>` → `kubectl logs <name> --previous` | feste Lesereihenfolge |
| `kubectl events` | alle Events im Namespace |
| `kubectl events --types=Warning` | nur Warnungen |
| `kubectl events --for pod/fehler-pending` | Events eines Pods |

## Pod-Manifest-Felder

| Feld | Wirkung |
| --- | --- |
| `spec.containers[].image` / `imagePullPolicy: Never` | Image; nur lokal vorhandene Images nutzen |
| `spec.containers[].env[].name` / `.value` | Umgebungsvariable setzen |
| `spec.containers[].command` | Startbefehl des Images (`CMD`) ersetzen |
| `spec.restartPolicy` | `Always` (Standard), `OnFailure` oder `Never`: wann der kubelet beendete Container neu startet |
| `spec.initContainers[]` | Container, die vor den Hauptcontainern laufen |
| `spec.initContainers[].restartPolicy: Always` | nativer Sidecar, läuft mit dem Pod mit |
| `spec.volumes[].emptyDir: {}` + `volumeMounts[].mountPath` | gemeinsamer Ordner für Container eines Pods |
| `metadata.labels` / `metadata.annotations` | Labels zum Auswählen / Notizen |
