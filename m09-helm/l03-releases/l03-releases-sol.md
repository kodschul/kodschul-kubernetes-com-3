# Lab 9.3 – Lösung: Releases verwalten

Fertiger Stand: [`project/examples/m09-helm/l03-releases/`](../../project/examples/m09-helm/l03-releases/)

## Aufgabe 1: Werte-Dateien

`playground/values-dev.yaml`:

```yaml
host: dev.hello.localhost
color: lightgreen
frontend:
  replicas: 1
  image:
    tag: v1
backend:
  replicas: 1
```

`playground/values-prod.yaml`:

```yaml
host: prod.hello.localhost
color: lightblue
frontend:
  replicas: 3
  image:
    tag: v1
backend:
  replicas: 3
```

```bash
helm template hello playground/hello -f playground/values-prod.yaml | grep -E "replicas:|image:|APP_COLOR|localhost"
```

```text
  APP_COLOR: "lightblue"
  replicas: 3
          image: "hello-backend:v1"
  replicas: 3
          image: "hello-frontend:v1"
    - "prod.hello.localhost"
```

Die Dateien enthalten nur die Abweichungen; Probes, Ressourcen und Gateway kommen aus `values.yaml` des Charts.

## Aufgabe 2: Lab-6.3-Objekte entfernen

```text
deployment.apps "backend" deleted
deployment.apps "frontend" deleted
service "backend" deleted
service "frontend" deleted
configmap "hello-config" deleted
...
secret/hello-secret unchanged
secret/hello-secret unchanged
```

`unchanged` heißt: Das Secret aus Lab 6.3 war schon da. Fehlte es, steht dort `created`.

## Aufgabe 3: Zwei Releases

```bash
helm upgrade --install hello playground/hello -n hello-dev -f playground/values-dev.yaml
helm upgrade --install hello playground/hello -n hello-prod -f playground/values-prod.yaml
helm list -A
```

```text
Release "hello" does not exist. Installing it now.
NAME: hello
LAST DEPLOYED: Tue Nov 17 11:52:40 2026
NAMESPACE: hello-dev
STATUS: deployed
REVISION: 1
...
NAME   NAMESPACE   REVISION  UPDATED                            STATUS    CHART        APP VERSION
hello  hello       1         2026-11-17 11:31:05.88 +0100 CET   deployed  hello-0.1.0  v2
hello  hello-dev   1         2026-11-17 11:52:40.17 +0100 CET   deployed  hello-0.1.0  v2
hello  hello-prod  1         2026-11-17 11:52:58.63 +0100 CET   deployed  hello-0.1.0  v2
```

`APP VERSION v2` stammt aus `Chart.yaml`; tatsächlich laufen in dev und prod `v1`-Images, weil die Werte-Dateien den Tag setzen. `http://dev.hello.localhost`: grün, „Hello-App v1", ein Frontend-Pod. `http://prod.hello.localhost`: blau, „Hello-App v1", beim Neuladen wechseln drei Pod-Namen.

## Aufgabe 4: Upgrade auf v2 und fehlerhaftes Upgrade

```bash
helm upgrade hello playground/hello -n hello-prod -f playground/values-prod.yaml \
  --set frontend.image.tag=v2 --rollback-on-failure --timeout 90s
```

```text
Release "hello" has been upgraded. Happy Helming!
NAME: hello
NAMESPACE: hello-prod
STATUS: deployed
REVISION: 2
```

Die Seite zeigt „Hello-App v2", weiter auf blauem Grund: Farbe kommt aus der ConfigMap, Version aus dem Image.

```bash
helm upgrade hello playground/hello -n hello-prod -f playground/values-prod.yaml \
  --set frontend.image.tag=v3 --rollback-on-failure --timeout 60s
```

```text
Error: UPGRADE FAILED: release hello failed, and has been rolled back due to rollback-on-failure being set: …
```

Der Wortlaut nach dem Doppelpunkt hängt von der Helm-Version ab (Zeitüberschreitung bzw. Deployment nicht bereit). Im zweiten Terminal:

```text
NAME                              READY   STATUS              RESTARTS   AGE
hello-frontend-7b6d9c8f5d-8x2kq   1/1     Running             0          3m
hello-frontend-7b6d9c8f5d-ljw4p   1/1     Running             0          3m
hello-frontend-7b6d9c8f5d-t5n9c   1/1     Running             0          3m
hello-frontend-5f8c7b9d6c-q2xzm   0/1     ErrImageNeverPull   0          5s
...
hello-frontend-5f8c7b9d6c-q2xzm   0/1     Terminating         0          62s
```

Der neue Pod mit `v3` startet nie; die drei `v2`-Pods bleiben bereit (Rolling Update aus Lab 4.3). Nach 60 Sekunden rollt Helm selbst zurück.

```bash
helm history hello -n hello-prod
```

```text
REVISION  UPDATED                   STATUS      CHART        APP VERSION  DESCRIPTION
1         Tue Nov 17 11:52:58 2026  superseded  hello-0.1.0  v2           Install complete
2         Tue Nov 17 11:55:12 2026  superseded  hello-0.1.0  v2           Upgrade complete
3         Tue Nov 17 11:56:40 2026  failed      hello-0.1.0  v2           Upgrade "hello" failed: …
4         Tue Nov 17 11:57:41 2026  deployed    hello-0.1.0  v2           Rollback to 2
```

## Aufgabe 5: Rollback auf Revision 1

```bash
helm rollback hello 1 -n hello-prod
helm history hello -n hello-prod
```

```text
Rollback was a success! Happy Helming!

REVISION  UPDATED                   STATUS      CHART        APP VERSION  DESCRIPTION
1         Tue Nov 17 11:52:58 2026  superseded  hello-0.1.0  v2           Install complete
2         Tue Nov 17 11:55:12 2026  superseded  hello-0.1.0  v2           Upgrade complete
3         Tue Nov 17 11:56:40 2026  failed      hello-0.1.0  v2           Upgrade "hello" failed: …
4         Tue Nov 17 11:57:41 2026  superseded  hello-0.1.0  v2           Rollback to 2
5         Tue Nov 17 11:59:03 2026  deployed    hello-0.1.0  v2           Rollback to 1
```

```bash
helm get values hello -n hello-prod --revision 2
helm get values hello -n hello-prod --revision 5
```

```text
USER-SUPPLIED VALUES:
backend:
  replicas: 3
color: lightblue
frontend:
  image:
    tag: v2
  replicas: 3
host: prod.hello.localhost

USER-SUPPLIED VALUES:
backend:
  replicas: 3
color: lightblue
frontend:
  image:
    tag: v1
  replicas: 3
host: prod.hello.localhost
```

Revision 5 trägt die Werte von Revision 1. Die Seite zeigt wieder „Hello-App v1". Das `access.log` auf der PVC enthält weiter die Zeilen der v2-Pods: ein Rollback setzt keine Daten zurück.

## Erweiterung: Chart verpacken

```bash
helm package playground/hello -d playground/
tar -tzf playground/hello-0.1.0.tgz
```

```text
Successfully packaged chart and saved it to: playground/hello-0.1.0.tgz
hello/Chart.yaml
hello/values.yaml
hello/templates/NOTES.txt
hello/templates/_helpers.tpl
hello/templates/backend-deployment.yaml
hello/templates/backend-service.yaml
hello/templates/configmap.yaml
hello/templates/frontend-deployment.yaml
hello/templates/frontend-service.yaml
hello/templates/httproute.yaml
hello/templates/pvc.yaml
```

Der Dateiname enthält die Chart-Version aus `Chart.yaml`; genau dieses Archiv lädt `helm push` in eine OCI-Registry.
