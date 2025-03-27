# MySQL Backup in Kubernetes

## Ziel

Wir möchten regelmäßig Backups von MySQL-Daten in einem Kubernetes-Cluster erstellen. Dies kann durch die Nutzung eines CronJobs oder manuell erfolgen.

## Vorbereitungen

Stelle sicher, dass du ein Persistent Volume (PV) hast, das für MySQL verwendet wird.

### 1. Manuelles Backup

Du kannst ein manuelles Backup von MySQL mit `mysqldump` durchführen. Erstelle einen Backup-Pod, der die MySQL-Daten exportiert.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mysql-backup
spec:
  containers:
    - name: mysql
      image: mysql:5.7
      command:
        - /bin/bash
        - -c
        - |
          mysqldump -h mysql-master -uroot -p$MYSQL_ROOT_PASSWORD exampledb > /backup/exampledb.sql
      env:
        - name: MYSQL_ROOT_PASSWORD
          value: "rootpassword"
      volumeMounts:
        - name: backup-volume
          mountPath: /backup
  volumes:
    - name: backup-volume
      persistentVolumeClaim:
        claimName: backup-pvc
```

### 2. Erstelle ein Persistent Volume für Backups

Stelle sicher, dass du ein Persistent Volume (PV) und Persistent Volume Claim (PVC) hast, um die Backups zu speichern.

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: backup-pv
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /mnt/data/backups
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: backup-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
```

### 3. Automatisches Backup mit CronJob

Erstelle einen CronJob, um tägliche Backups automatisch durchzuführen.

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: mysql-backup-cron
spec:
  schedule: "0 3 * * *" # Backup um 03:00 Uhr jeden Tag
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: mysql
              image: mysql:5.7
              command:
                - /bin/bash
                - -c
                - |
                  mysqldump -h mysql-master -uroot -p$MYSQL_ROOT_PASSWORD exampledb > /backup/exampledb.sql
              env:
                - name: MYSQL_ROOT_PASSWORD
                  value: "rootpassword"
              volumeMounts:
                - name: backup-volume
                  mountPath: /backup
          volumes:
            - name: backup-volume
              persistentVolumeClaim:
                claimName: backup-pvc
          restartPolicy: OnFailure
```

### 4. Wiederherstellung des Backups

Um das Backup wiederherzustellen, kannst du `mysql` verwenden:

```bash
kubectl exec -i <mysql-master-pod> -- mysql -uroot -p$MYSQL_ROOT_PASSWORD exampledb < /backup/exampledb.sql
```
