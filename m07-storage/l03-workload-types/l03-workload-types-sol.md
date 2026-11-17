# Lab 7.3 – Lösung: StatefulSets, DaemonSets, Jobs und CronJobs

Alle Befehle laufen im Ordner `project/`. Namen und Zeiten weichen ab; die Uhrzeiten in den Dateinamen sind UTC.

## Aufgabe 1: DaemonSet im Cluster

```bash
kubectl get daemonsets -n kube-system
```

```text
NAME         DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
kube-proxy   1         1         1       1            1           kubernetes.io/os=linux   12d
```

Ein Node, also ein `kube-proxy`-Pod. Mit drei Nodes stünde hier `DESIRED 3`, ohne dass jemand eine Replikazahl gesetzt hätte.

## Aufgabe 2: CronJob anlegen

```bash
cp starters/m07-l03-cronjob.yaml playground/k8s/cronjob.yaml
# TODOs ergänzen (siehe unten)
kubectl apply -f playground/k8s/cronjob.yaml
kubectl get cronjob hello-backup
```

```yaml
spec:
  schedule: "*/2 * * * *"
  concurrencyPolicy: Forbid
  ...
          volumes:
            - name: data
              persistentVolumeClaim:
                claimName: hello-data
```

```text
cronjob.batch/hello-backup created
NAME           SCHEDULE      TIMEZONE   SUSPEND   ACTIVE   LAST SCHEDULE   AGE
hello-backup   */2 * * * *   <none>     False     0        <none>          4s
```

Vollständige Datei: [`examples/m07-storage/l03-workload-types/cronjob.yaml`](../../project/examples/m07-storage/l03-workload-types/cronjob.yaml)

## Aufgabe 3: Job sofort auslösen

```bash
kubectl create job --from=cronjob/hello-backup backup-now
kubectl get jobs
kubectl logs job/backup-now
```

```text
job.batch/backup-now created

NAME         STATUS     COMPLETIONS   DURATION   AGE
backup-now   Complete   1/1           4s         9s

access-133012.log
```

Der Job nutzt den Bauplan (`jobTemplate`) des CronJobs, startet aber sofort und unabhängig vom Zeitplan. Ein manuell erzeugter Job bleibt stehen, bis er gelöscht wird (`kubectl delete job backup-now`); die History-Limits gelten nur für geplante Jobs.

## Aufgabe 4: Sicherung prüfen

```bash
kubectl exec deploy/frontend -- ls /data/backup
kubectl exec deploy/frontend -- cat /data/backup/access-133012.log
```

```text
access-133012.log

2026-11-17T14:20:03 frontend-5d8c7b9f4-hk2vw 10.1.0.95 v2
...
2026-11-17T14:23:31 frontend-5d8c7b9f4-c4zn8 10.1.0.98 v2
```

Job-Pod und Frontend-Pods hängen denselben PVC ein: Was der Job schreibt, sieht das Frontend unter `/data/backup`.

## Aufgabe 5: Geplante Läufe beobachten

```bash
kubectl get jobs -w
kubectl get cronjob hello-backup
kubectl exec deploy/frontend -- ls /data/backup
```

```text
NAME                    STATUS     COMPLETIONS   DURATION   AGE
backup-now              Complete   1/1           4s         2m10s
hello-backup-29384522   Running    0/1                      0s
hello-backup-29384522   Complete   1/1           3s         3s
hello-backup-29384524   Running    0/1                      0s
hello-backup-29384524   Complete   1/1           3s         3s
^C

NAME           SCHEDULE      TIMEZONE   SUSPEND   ACTIVE   LAST SCHEDULE   AGE
hello-backup   */2 * * * *   <none>     False     0        38s             4m40s

access-133012.log
access-133200.log
access-133400.log
```

Die Zahl im Jobnamen ist die geplante Startzeit in Minuten seit 01.01.1970. Nach mehr als drei geplanten Läufen löscht der CronJob die ältesten Jobs (`successfulJobsHistoryLimit: 3`); die Sicherungsdateien auf dem PVC bleiben.

## Erweiterung

```yaml
spec:
  suspend: true
  schedule: "*/2 * * * *"
```

```text
$ kubectl get cronjob hello-backup
NAME           SCHEDULE      TIMEZONE   SUSPEND   ACTIVE   LAST SCHEDULE   AGE
hello-backup   */2 * * * *   <none>     True      0        3m              12m
```

Nach dem Entfernen der Zeile und erneutem `kubectl apply` zeigt `SUSPEND` wieder `False`.

Fertiger Stand: [`examples/m07-storage/l03-workload-types/`](../../project/examples/m07-storage/l03-workload-types/)
