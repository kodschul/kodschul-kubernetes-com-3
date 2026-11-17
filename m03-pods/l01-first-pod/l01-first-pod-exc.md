# Lab 3.1 – Übung: Der erste Pod

**Dauer:** ca. 20 Minuten
**Ändert die Hello-App-Projektbasis?** Ja — Backend und Frontend laufen als Pods `backend` und `frontend` im Namespace `hello`; Lab 3.2 erweitert den Frontend-Pod.

## Vorbereitung

- Terminal (macOS/Linux: Terminal, Windows: Git Bash) im Ordner `project/` öffnen.
- Starter: [`project/starters/m03-l01-backend-pod.yaml`](../../project/starters/m03-l01-backend-pod.yaml) und [`project/starters/m03-l01-frontend-pod.yaml`](../../project/starters/m03-l01-frontend-pod.yaml)
- Arbeitsdateien: `project/playground/k8s/backend-pod.yaml`, `project/playground/k8s/frontend-pod.yaml`
- Prüfen: `kubectl config view --minify | grep namespace:` zeigt `namespace: hello`, und `docker images --filter "reference=hello-*"` listet `hello-backend:v1` und `hello-frontend:v1`.
- Stand aus Lab 2.4 wiederherstellen (falls nötig): `kubectl apply -f examples/m02-kubernetes-intro/l04-manifests/` und `kubectl config set-context --current --namespace=hello`.

## Aufgaben

1. Kopiere den Backend-Starter nach `playground/k8s/backend-pod.yaml`, ergänze die beiden TODOs und wende die Datei mit `kubectl apply -f` an. Prüfe mit `kubectl get pods -o wide`, dass `backend` `Running` ist, und merke die IP.
2. Kopiere den Frontend-Starter nach `playground/k8s/frontend-pod.yaml`, ergänze `env` mit `BACKEND_URL=http://<Backend-IP>` und wende die Datei an. Rufe danach das Backend aus dem Frontend-Container auf: `kubectl exec frontend -- wget -qO- http://<Backend-IP>`.
3. Starte in einem zweiten Terminal `kubectl port-forward pod/frontend 8080:80` und öffne `http://localhost:8080`. Zeige danach mit `kubectl logs backend` die Anfrage des Frontends im Backend-Log an.
4. Lies mit `kubectl describe pod frontend` Node, IP, die Umgebungsvariable und die Events des Pods ab.
5. Lösche den Backend-Pod, lege ihn mit derselben Datei neu an und lade die Seite neu. Trage danach die neue IP in `frontend-pod.yaml` ein, lege den Frontend-Pod neu an (löschen, dann anwenden), starte das Port-Forward neu und lade die Seite erneut.

## Checkpoint

- `kubectl get pods -o wide` zeigt `backend` und `frontend` mit `READY 1/1`, `STATUS Running` und je einer IP.
- Aufgabe 2 gibt JSON mit `"pod":"backend"` aus.
- Die Seite unter `http://localhost:8080` ist hellblau, zeigt „Hello-App v1", den Frontend-Pod mit IP und die Antwort des Backends.
- Nach dem Neuanlegen des Backends meldet die Seite `Backend nicht erreichbar (http://<alte IP>)`, nach Aufgabe 5 wieder die Backend-Antwort mit der neuen IP.

## Abschlusskriterien

- `playground/k8s/backend-pod.yaml` und `frontend-pod.yaml` existieren; `frontend-pod.yaml` enthält die aktuelle Backend-IP.
- Beide Pods laufen im Namespace `hello`.

## Erweiterung

Öffne in Headlamp **Workloads → Pods → frontend**, öffne dort die Logs und danach über das Terminal-Symbol eine Shell im Container. Führe darin `env | grep BACKEND` aus.

## Fallback

- `ErrImageNeverPull`: Images fehlen lokal. Im Ordner `project/` `bash build-images.sh` ausführen, dann den Pod löschen und neu anwenden.
- Port 8080 belegt: `kubectl port-forward pod/frontend 8081:80` und `http://localhost:8081` öffnen.
- Fertiger Stand zum Vergleich: [`project/examples/m03-pods/l01-first-pod/`](../../project/examples/m03-pods/l01-first-pod/) (die Backend-IP darin ist ein Platzhalter).
