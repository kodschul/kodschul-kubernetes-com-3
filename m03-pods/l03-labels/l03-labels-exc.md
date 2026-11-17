# Lab 3.3 – Übung: Labels und Selektoren

**Dauer:** ca. 15 Minuten
**Ändert die Hello-App-Projektbasis?** Ja — `backend` und `frontend` tragen zusätzlich `version: v1` und eine Annotation `description`; Lab 4.1 baut darauf auf.

## Vorbereitung

- Terminal im Ordner `project/`; Pods `backend` und `frontend` aus Lab 3.2 laufen.
- Starter: keiner, die eigenen Dateien aus Lab 3.2 werden ergänzt (sie enthalten die eigene Backend-IP).
- Arbeitsdateien: `project/playground/k8s/backend-pod.yaml`, `project/playground/k8s/frontend-pod.yaml`
- Stand aus Lab 3.2 wiederherstellen (falls nötig): `kubectl apply -f examples/m03-pods/l02-sidecars/`, danach die Backend-IP in `frontend-pod.yaml` nachtragen und den Frontend-Pod neu anlegen.

## Aufgaben

1. Ergänze in beiden Arbeitsdateien unter `metadata.labels` das Label `version: v1` und unter `metadata.annotations` je eine `description`. Wende beide Dateien mit `kubectl apply -f playground/k8s/` an.
2. Starte zum Vergleich einen zweiten Frontend-Pod mit der Version `v2`: `kubectl run frontend-v2 --image=hello-frontend:v2 --image-pull-policy=Never --labels=app=hello,tier=frontend,version=v2`. Zeige alle Pods mit `kubectl get pods --show-labels` und danach mit `-L tier,version`.
3. Filtere mit `-l`: zuerst alle Pods mit `app=hello`, dann alle Frontend-Pods, dann nur Frontend-Pods der Version `v1`, zuletzt alle Pods mit `version in (v1,v2)`.
4. Ändere die Labels von `frontend-v2` nachträglich: setze `stage=test`, ändere den Wert auf `review` und hänge die Annotation `description="Testpod für v2"` an. Filtere danach mit `-l stage=review`.
5. Lösche alle Pods mit `stage=review` über einen Selektor und wiederhole die Abfrage nach Frontend-Pods der Version `v1`.

## Checkpoint

- `kubectl apply` meldet für beide Pods `configured`, ohne Neustart (`RESTARTS 0`, `AGE` läuft weiter).
- `kubectl get pods -l tier=frontend,version=v1` zeigt nur `frontend`.
- `kubectl get pods -l stage=review` zeigt nur `frontend-v2`; nach Aufgabe 5 gibt es diesen Pod nicht mehr.

## Abschlusskriterien

- Beide Arbeitsdateien enthalten `app`, `tier`, `version` und eine `description`-Annotation.
- Im Namespace `hello` laufen nur `backend` und `frontend`. `frontend-v2` ist gelöscht, weil ein ReplicaSet in Lab 4.1 sonst jeden Pod mit `app=hello,tier=frontend` mitzählen würde.

## Fallback

- `bash: !...: event not found` oder Klammerfehler: Selektor in einfache Anführungszeichen setzen.
- Fertiger Stand zum Vergleich: [`project/examples/m03-pods/l03-labels/`](../../project/examples/m03-pods/l03-labels/) (Backend-IP ist ein Platzhalter).
