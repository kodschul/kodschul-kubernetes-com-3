# MySQL Replication in Kubernetes

## Vorbereitungen

Um MySQL in einem Kubernetes-Cluster zu replizieren, benötigen wir mindestens zwei Pods:

1. Einen **Master-Pod**.
2. Einen oder mehrere **Replica-Pods**.

Außerdem benötigen wir ein Persistent Volume (PV) für die Daten.

## Schritte

### 1. Erstelle eine ConfigMap für die MySQL-Konfiguration

Erstelle eine `mysql-configmap.yaml`, um die MySQL-Server-Konfiguration bereitzustellen, die für die Replikation erforderlich ist.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-config
data:
  my.cnf: |
    [mysqld]
    server-id = 1
    log-bin = /var/lib/mysql/mysql-bin
    binlog-do-db = exampledb
```

### 2. Erstelle ein Deployment für den Master

Erstelle ein Deployment für den Master-Pod, das die MySQL-Instanz im Replikationsmodus startet.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql-master
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql-master
  template:
    metadata:
      labels:
        app: mysql-master
    spec:
      containers:
        - name: mysql
          image: mysql:5.7
          env:
            - name: MYSQL_ROOT_PASSWORD
              value: "rootpassword"
          volumeMounts:
            - name: mysql-config
              mountPath: /etc/mysql/conf.d
      volumes:
        - name: mysql-config
          configMap:
            name: mysql-config
```

### 3. Erstelle ein Deployment für den Replica

Erstelle ein weiteres Deployment für den Replica-Pod. Dieser Pod wird sich mit dem Master verbinden und dessen Daten replizieren.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql-replica
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql-replica
  template:
    metadata:
      labels:
        app: mysql-replica
    spec:
      containers:
        - name: mysql
          image: mysql:5.7
          env:
            - name: MYSQL_ROOT_PASSWORD
              value: "rootpassword"
            - name: MYSQL_MASTER_HOST
              value: "mysql-master"
            - name: MYSQL_MASTER_PORT
              value: "3306"
          volumeMounts:
            - name: mysql-config
              mountPath: /etc/mysql/conf.d
      volumes:
        - name: mysql-config
          configMap:
            name: mysql-config
```

### 4. Erstelle einen Service für den Master

Erstelle einen Service für den Master, damit der Replica-Pod darauf zugreifen kann.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql-master
spec:
  selector:
    app: mysql-master
  ports:
    - port: 3306
      targetPort: 3306
```

### 5. Starten der Replikation

Nachdem du beide Deployments erstellt hast, kannst du die Replikation in MySQL starten, indem du in den Replica-Pod gehst und den Master als Replikationsquelle einrichtest:

```bash
kubectl exec -it <mysql-replica-pod> -- mysql -uroot -p
```

Im MySQL-Client:

```sql
CHANGE MASTER TO MASTER_HOST='mysql-master', MASTER_USER='root', MASTER_PASSWORD='rootpassword';
START SLAVE;
```

### 6. Überprüfe den Status der Replikation

Um den Replikationsstatus zu überprüfen, kannst du folgendes Kommando ausführen:

```sql
SHOW SLAVE STATUS\G
```

Stelle sicher, dass der `Slave_IO_Running` und `Slave_SQL_Running` beide auf `Yes` gesetzt sind.

## Fazit

Nun hast du MySQL in Kubernetes mit Replikation eingerichtet! Du kannst weitere Replicas hinzufügen, indem du das Replica-Deployment skalierst.
