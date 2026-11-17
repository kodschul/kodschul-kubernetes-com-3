# Lab 7.3 – Übung: StatefulSets, DaemonSets, Jobs und CronJobs

**Dauer:** ca. 15 Minuten
**Ändert die Hello-App-Projektbasis?** Ja — neuer CronJob `hello-backup`, der `access.log` alle zwei Minuten nach `/data/backup/` auf dem PVC `hello-data` kopiert.

## Vorbereitung

- Terminal im Ordner `project/` öffnen.
- Starter: [`project/starters/m07-l03-cronjob.yaml`](../../project/starters/m07-l03-cronjob.yaml)
- Arbeitsdatei: `project/playground/k8s/cronjob.yaml` (neu)
- Prüfen: `kubectl get pvc hello-data` zeigt `Bound`, und `kubectl exec deploy/frontend -- cat /data/access.log` zeigt mindestens eine Zeile (sonst die Seite einmal aufrufen: `curl -s -o /dev/null http://hello.localhost/`).
- Stand aus Lab 7.2 wiederherstellen (falls nötig): `kubectl apply -f examples/m07-storage/l02-persistent-volumes/`

## Aufgaben

1. Zeige mit `kubectl get daemonsets -n kube-system` das DaemonSet des Clusters an.
2. Kopiere den Starter nach `playground/k8s/cronjob.yaml`, ergänze die drei TODOs (Zeitplan alle zwei Minuten, keine parallelen Läufe, PVC aus Lab 7.2) und wende die Datei an. Zeige den CronJob mit `kubectl get cronjob hello-backup` an.
3. Löse einen Lauf sofort aus: `kubectl create job --from=cronjob/hello-backup backup-now`. Zeige mit `kubectl get jobs` den Status und mit `kubectl logs job/backup-now` die Ausgabe an.
4. Prüfe die Sicherung aus Sicht des Frontends: `kubectl exec deploy/frontend -- ls /data/backup` und den Inhalt einer Sicherungsdatei mit `kubectl exec deploy/frontend -- cat /data/backup/<Dateiname>`.
5. Beobachte mit `kubectl get jobs -w` mindestens zwei geplante Läufe (ca. 4 Minuten, Ende mit **Strg+C**) und zeige danach erneut `kubectl get cronjob hello-backup` und `kubectl exec deploy/frontend -- ls /data/backup` an.

## Checkpoint

- Aufgabe 1: `kube-proxy` mit `DESIRED 1`.
- Aufgabe 2: `SCHEDULE */2 * * * *`, `SUSPEND False`.
- Aufgabe 3: `backup-now` mit `STATUS Complete` und `COMPLETIONS 1/1`; das Log nennt eine Datei `access-HHMMSS.log`.
- Aufgabe 4: die Sicherungsdatei enthält dieselben Zeilen wie `access.log` zum Zeitpunkt des Laufs.
- Aufgabe 5: Jobs `hello-backup-<zahl>` erscheinen im Zwei-Minuten-Takt; `LAST SCHEDULE` zeigt wenige Sekunden bis zwei Minuten; in `/data/backup` liegen mehrere Dateien.

## Abschlusskriterien

- `kubectl get cronjob hello-backup` existiert, `playground/k8s/cronjob.yaml` nutzt `apiVersion: batch/v1`.
- In `/data/backup` liegen mindestens drei Sicherungsdateien.

## Erweiterung

Ergänze in `playground/k8s/cronjob.yaml` unter `spec` die Zeile `suspend: true`, wende die Datei an und prüfe mit `kubectl get cronjob hello-backup`, dass `SUSPEND True` gilt und keine neuen Jobs entstehen. Entferne die Zeile danach wieder und wende die Datei erneut an.

## Fallback

- Job-Pod hängt in `ErrImagePull` (Docker-Hub-Limit oder kein Netz): `docker pull busybox:1.37` ausführen, ggf. vorher `docker login`; danach `kubectl delete job backup-now` und Aufgabe 3 wiederholen.
- Fertiger Stand: `kubectl apply -f examples/m07-storage/l03-workload-types/`
