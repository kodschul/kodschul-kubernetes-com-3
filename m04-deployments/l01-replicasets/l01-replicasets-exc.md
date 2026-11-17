# Lab 4.1 – Übung: ReplicaSets und Self-Healing

**Dauer:** ca. 12 Minuten
**Ändert die Hello-App-Projektbasis?** Ja — das Frontend läuft als ReplicaSet `frontend` mit drei Pods; Lab 4.2 ersetzt es durch ein Deployment.

## Vorbereitung

- Terminal im Ordner `project/`; Pods `backend` und `frontend` aus Modul 3 laufen.
- Starter: [`project/starters/m04-l01-frontend-replicaset.yaml`](../../project/starters/m04-l01-frontend-replicaset.yaml)
- Arbeitsdatei: `project/playground/k8s/frontend-replicaset.yaml`
- Stand aus Lab 3.3 wiederherstellen (falls nötig): `kubectl apply -f examples/m03-pods/l03-labels/`

## Aufgaben

1. Lösche den Einzel-Pod `frontend` aus Modul 3 und lies die aktuelle Backend-IP mit `kubectl get pod backend -o wide` ab. Lösche auch die Datei `playground/k8s/frontend-pod.yaml`, damit `kubectl apply -f playground/k8s/` den Pod nicht zurückholt.
2. Kopiere den Starter nach `playground/k8s/frontend-replicaset.yaml`, ergänze `replicas`, den Selektor und die Backend-IP und wende die Datei an. Prüfe mit `kubectl get rs` und `kubectl get pods -o wide`.
3. Starte in einem zweiten Terminal `kubectl get pods -l tier=frontend -w`. Lösche im ersten Terminal einen der drei Frontend-Pods per Name und beobachte den Ersatz.
4. Starte von Hand einen vierten Pod mit denselben Labels: `kubectl run extra --image=hello-frontend:v1 --image-pull-policy=Never --labels=app=hello,tier=frontend` und beobachte, was das ReplicaSet tut.
5. Skaliere mit `kubectl scale rs frontend --replicas=5` und wende danach die Datei erneut an. Vergleiche jeweils `kubectl get rs`.

## Checkpoint

- `kubectl get rs` zeigt `frontend` mit `DESIRED 3`, `CURRENT 3`, `READY 3`.
- Nach Aufgabe 3 gibt es wieder drei Frontend-Pods, einer davon mit neuem Namen und neuer IP.
- Nach Aufgabe 4 wird ein Pod sofort wieder gelöscht (`Terminating`); es bleiben drei.
- Nach `scale` laufen fünf Pods, nach dem erneuten `apply` wieder drei.

## Abschlusskriterien

- `playground/k8s/` enthält `backend-pod.yaml` und `frontend-replicaset.yaml`, aber keine `frontend-pod.yaml` mehr.
- Im Namespace `hello` laufen der Pod `backend` und drei Pods `frontend-xxxxx`.

## Fallback

- Fertiger Stand zum Vergleich: [`project/examples/m04-deployments/l01-replicasets/`](../../project/examples/m04-deployments/l01-replicasets/) (Backend-IP ist ein Platzhalter; die Pods laufen trotzdem, nur die Backend-Anzeige fehlt).
