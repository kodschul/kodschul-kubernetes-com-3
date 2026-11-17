# Lab 7.2 – Übung: PersistentVolumes und StorageClasses

**Dauer:** ca. 20 Minuten
**Ändert die Hello-App-Projektbasis?** Ja — neuer PVC `hello-data`; das Frontend schreibt `access.log` darauf und läuft wieder mit drei Repliken. Lab 7.3 sichert dieses Log per CronJob.

## Vorbereitung

- Terminal im Ordner `project/` öffnen.
- Starter: [`project/starters/m07-l02-pvc.yaml`](../../project/starters/m07-l02-pvc.yaml), [`project/starters/m07-l02-frontend-deployment.yaml`](../../project/starters/m07-l02-frontend-deployment.yaml)
- Arbeitsdateien: `project/playground/k8s/pvc.yaml` (neu), `project/playground/k8s/frontend-deployment.yaml`
- Prüfen: `kubectl get deployment frontend` zeigt `1/1`.
- Stand aus Lab 7.1 wiederherstellen (falls nötig): `kubectl apply -f examples/m07-storage/l01-volumes/`

## Aufgaben

1. Zeige mit `kubectl get storageclass` die Default-StorageClass an. Kopiere den PVC-Starter nach `playground/k8s/pvc.yaml`, ergänze die beiden TODOs, wende die Datei an und zeige mit `kubectl get pvc,pv` Claim und Volume an.
2. Kopiere den Frontend-Starter nach `playground/k8s/frontend-deployment.yaml`, ersetze das `emptyDir` durch den Claim `hello-data` und wende die Datei an. Warte mit `kubectl rollout status deployment/frontend`, rufe die Seite dreimal mit `curl -s -o /dev/null http://hello.localhost/` auf und lies das Log mit `kubectl exec deploy/frontend -- cat /data/access.log`.
3. Lösche den Frontend-Pod mit `kubectl delete pod -l tier=frontend`, warte auf den Ersatz und lies das Log. Rufe die Seite danach einmal auf und lies es erneut.
4. Setze in `playground/k8s/frontend-deployment.yaml` `replicas: 3`, wende die Datei an und warte auf den Rollout. Rufe die Seite sechsmal auf, lies das Log und zeige mit `kubectl get pods -l tier=frontend -o wide`, auf welchem Node die Pods laufen.
5. Zeige mit `kubectl describe pvc hello-data` die Zeile `Used By` an.

## Checkpoint

- Aufgabe 1: `hostpath (default)`; `hello-data` mit `STATUS Bound`, `CAPACITY 1Gi`, `ACCESS MODES RWO`; das PV heißt `pvc-…` und hat `RECLAIM POLICY Delete`.
- Aufgabe 3: die drei Zeilen aus Aufgabe 2 sind noch da; die neue Zeile trägt den Namen des Ersatz-Pods.
- Aufgabe 4: das Log enthält Zeilen von mehreren Pod-Namen; alle Pods laufen auf `docker-desktop`.
- Aufgabe 5: `Used By` nennt drei Pods.

## Abschlusskriterien

- `kubectl get deployment frontend` zeigt `3/3`.
- `playground/k8s/pvc.yaml` existiert; das Frontend hängt `hello-data` unter `/data` ein.

## Erweiterung

Zeige mit `kubectl describe pv` an, wo das Volume wirklich liegt: Der Abschnitt `Source` nennt die Volume-Art und den Ordner auf dem Node `docker-desktop`.

## Fallback

- PVC bleibt `Pending`: `kubectl describe pvc hello-data` lesen; bei minikube oder kind heißt die Default-StorageClass `standard`, der PVC funktioniert dort ohne Änderung.
- Fertiger Stand: `kubectl apply -f examples/m07-storage/l02-persistent-volumes/`
