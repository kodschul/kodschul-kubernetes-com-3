# Speicher und Workload-Typen – Cheatsheet (Modul 7)

Alle Befehle wirken im aktuellen Namespace (`hello`); `-n <namespace>` wählt einen anderen.

## Volumes beobachten (Lab 7.1)

| Befehl | Wirkung |
| --- | --- |
| `kubectl exec deploy/frontend -- cat /data/access.log` | Datei in einem Pod des Deployments lesen |
| `kubectl exec deploy/frontend -- ls /data` | Inhalt eines eingehängten Ordners anzeigen |
| `kubectl exec deploy/frontend -- kill -INT 1` | Hauptprozess (PID 1) beenden: Container startet im selben Pod neu |
| `kubectl get pods -l tier=frontend` | Spalte `RESTARTS` zählt Container-Neustarts |
| `kubectl delete pod -l tier=frontend` | Pod ersetzen lassen: neuer Name, neue IP, neues `emptyDir` |
| `kubectl describe pod -l tier=frontend` | Abschnitte `Mounts` (je Container) und `Volumes` (je Pod) |

## Volume im Manifest (Lab 7.1, 7.2)

| Eintrag | Wirkung |
| --- | --- |
| `volumes: - name: data` + `emptyDir: {}` | leerer Ordner, lebt so lange wie der Pod |
| `volumes: - name: data` + `persistentVolumeClaim: claimName: hello-data` | Speicher aus einem PVC, lebt unabhängig vom Pod |
| `volumeMounts: - name: data` + `mountPath: /data` | Volume im Container als Ordner `/data` einhängen |
| `readOnly: true` (im `volumeMounts`-Eintrag) | Container darf nur lesen |
| `storageClassName: nfs-csi` (im PVC) | bestimmte StorageClass statt der Default-Klasse wählen |
| `storageClassName: ""` + `volumeName: s3-pv` (im PVC) | statisch: genau ein vorhandenes PV binden, keine StorageClass |

## PersistentVolumes und StorageClasses (Lab 7.2)

| Befehl | Wirkung |
| --- | --- |
| `kubectl get storageclass` | Speicherangebote; `(default)` markiert die Standardklasse |
| `kubectl apply -f playground/k8s/pvc.yaml` | Claim anlegen; die StorageClass erzeugt das PV |
| `kubectl get pvc` | Claims mit `STATUS` (`Bound`, `Pending`), Größe, Access Mode |
| `kubectl get pv` | Volumes mit `RECLAIM POLICY` und zugehörigem `CLAIM` |
| `kubectl describe pvc hello-data` | Details, `Used By` (welche Pods), Events bei `Pending` |
| `kubectl describe pv` | `Source`: wo die Daten wirklich liegen |
| `kubectl delete pvc hello-data` | Claim löschen; bei `Delete` sind PV und Daten weg |

| Access Mode | Kurz | erlaubt |
| --- | --- | --- |
| `ReadWriteOnce` | RWO | lesen/schreiben von einem Node (alle Pods dort) |
| `ReadOnlyMany` | ROX | nur lesen, viele Nodes |
| `ReadWriteMany` | RWX | lesen/schreiben, viele Nodes (NFS, SMB, CephFS) |
| `ReadWriteOncePod` | RWOP | lesen/schreiben von genau einem Pod |

## Jobs und CronJobs (Lab 7.3)

| Befehl | Wirkung |
| --- | --- |
| `kubectl get cronjobs` | Zeitplan, `SUSPEND`, `ACTIVE`, `LAST SCHEDULE` |
| `kubectl create job --from=cronjob/hello-backup backup-now` | Lauf sofort auslösen |
| `kubectl get jobs` | Jobs mit `STATUS` und `COMPLETIONS` |
| `kubectl get jobs -w` | neue Läufe live verfolgen (Ende mit **Strg+C**) |
| `kubectl logs job/backup-now` | Ausgabe des Job-Pods |
| `kubectl delete job backup-now` | Job samt Pod löschen |
| `suspend: true` im CronJob + `kubectl apply` | CronJob pausieren, ohne ihn zu löschen |

| Cron-Ausdruck | Bedeutung |
| --- | --- |
| `"*/2 * * * *"` | alle 2 Minuten (Anführungszeichen nötig) |
| `"0 2 * * *"` | täglich 02:00 (Zeitzone des Controllers, meist UTC) |
| `"30 6 * * 1-5"` | Mo–Fr 06:30 |

## Weitere Workload-Typen (Lab 7.3)

| Befehl | Wirkung |
| --- | --- |
| `kubectl get daemonsets -n kube-system` | Pods, die auf jedem Node laufen (z. B. `kube-proxy`) |
| `kubectl get statefulsets` | StatefulSets mit `READY` |
| `kubectl get pvc` (nach StatefulSet) | je Pod ein Claim: `<template>-<statefulset>-0`, `-1` … |
