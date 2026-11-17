# Lab 4.2 – Übung: Deployments

**Dauer:** ca. 15 Minuten
**Ändert die Hello-App-Projektbasis?** Ja — Backend und Frontend laufen als Deployments `backend` und `frontend` mit je drei Pods; Lab 4.3 rollt das Frontend auf `v2` aus.

## Vorbereitung

- Terminal im Ordner `project/`; Pod `backend` und ReplicaSet `frontend` aus Lab 4.1 laufen.
- Starter: [`project/starters/m04-l02-frontend-deployment.yaml`](../../project/starters/m04-l02-frontend-deployment.yaml); das Backend-Manifest entsteht mit `kubectl create deployment`.
- Arbeitsdateien: `project/playground/k8s/backend-deployment.yaml`, `project/playground/k8s/frontend-deployment.yaml`
- Stand aus Lab 4.1 wiederherstellen (falls nötig): `kubectl apply -f examples/m04-deployments/l01-replicasets/`

## Aufgaben

1. Räume die Einzelobjekte ab: `kubectl delete rs frontend` und `kubectl delete pod backend`. Lösche auch `playground/k8s/frontend-replicaset.yaml` und `playground/k8s/backend-pod.yaml`.
2. Erzeuge die Backend-Vorlage mit `kubectl create deployment backend --image=hello-backend:v1 --port=80 --dry-run=client -o yaml > playground/k8s/backend-deployment.yaml`. Passe Labels, Selektor, Containername und `imagePullPolicy` nach der Tabelle aus der Theorie an, lass `replicas: 1` stehen und wende die Datei an.
3. Kopiere den Frontend-Starter nach `playground/k8s/frontend-deployment.yaml`, ergänze die TODOs und wende die Datei an. Zeige Deployments, ReplicaSets und Pods mit `kubectl get deploy,rs,pods`.
4. Skaliere beide Deployments mit einem Befehl auf drei Replikas und trage danach `replicas: 3` in beide Dateien ein. Prüfe mit `kubectl apply -f playground/k8s/` und `kubectl get deploy`, dass es bei drei bleibt.
5. Lösche einen Frontend-Pod, beobachte den Ersatz und öffne die Seite über `kubectl port-forward deployment/frontend 8080:80` unter `http://localhost:8080`.

## Checkpoint

- `kubectl get deploy` zeigt `backend` und `frontend` mit `READY 3/3`.
- `kubectl get rs` zeigt je ein ReplicaSet `backend-<hash>` und `frontend-<hash>` mit `DESIRED 3`.
- Pod-Namen folgen dem Muster `frontend-<hash>-<5 Zeichen>`.
- Die Seite zeigt „Hello-App v1", den Namen eines Frontend-Pods und `Backend nicht erreichbar (http://backend)`. Das ist bis Lab 5.1 erwartet.

## Abschlusskriterien

- `playground/k8s/` enthält `backend-deployment.yaml` und `frontend-deployment.yaml` mit `replicas: 3`, Selektor `app: hello` + `tier`, `imagePullPolicy: Never`.
- Es laufen keine Einzel-Pods und kein ReplicaSet ohne Deployment mehr.

## Fallback

- Vorlage lässt sich nicht erzeugen oder passt nicht: [`project/examples/m04-deployments/l02-deployments/backend-deployment.yaml`](../../project/examples/m04-deployments/l02-deployments/backend-deployment.yaml) als Vergleich.
- Fertiger Stand: [`project/examples/m04-deployments/l02-deployments/`](../../project/examples/m04-deployments/l02-deployments/)
