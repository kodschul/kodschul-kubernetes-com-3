# Lab 9.1 – Lösung: Helm-Grundlagen

## Aufgabe 1: Version und Chart ansehen

```bash
helm version
```

```text
version.BuildInfo{Version:"v4.3.2", GitCommit:"…", GitTreeState:"clean", GoVersion:"go1.…"}
```

```bash
helm show chart oci://ghcr.io/stefanprodan/charts/podinfo --version 6.17.0
```

```text
Pulled: ghcr.io/stefanprodan/charts/podinfo:6.17.0
Digest: sha256:…
apiVersion: v1
appVersion: 6.17.0
description: Podinfo Helm chart for Kubernetes
home: https://github.com/stefanprodan/podinfo
kubeVersion: '>=1.23.0-0'
name: podinfo
version: 6.17.0
...
```

```bash
helm show values oci://ghcr.io/stefanprodan/charts/podinfo --version 6.17.0 | head -40
```

Wichtige Stellen der Ausgabe:

```yaml
replicaCount: 1                       # Anzahl Pods
image:
  repository: ghcr.io/stefanprodan/podinfo   # Image kommt aus ghcr.io, nicht von Docker Hub
  tag: 6.17.0
ui:
  color: "#34577c"                    # Hintergrundfarbe
  message: ""                         # leer = "greetings from podinfo"
service:
  type: ClusterIP
  externalPort: 9898                  # Port des Service
```

## Aufgabe 2: Installieren

```bash
helm install podinfo oci://ghcr.io/stefanprodan/charts/podinfo --version 6.17.0 \
  -n podinfo --create-namespace --set ui.message="Hallo aus Helm"
```

```text
Pulled: ghcr.io/stefanprodan/charts/podinfo:6.17.0
Digest: sha256:…
NAME: podinfo
LAST DEPLOYED: Tue Nov 17 10:52:13 2026
NAMESPACE: podinfo
STATUS: deployed
REVISION: 1
NOTES:
1. Get the application URL by running these commands:
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl -n podinfo port-forward deploy/podinfo 8080:9898
```

```bash
helm list -n podinfo
kubectl get all -n podinfo
```

```text
NAME     NAMESPACE  REVISION  UPDATED                               STATUS    CHART           APP VERSION
podinfo  podinfo    1         2026-11-17 10:52:13.41 +0100 CET      deployed  podinfo-6.17.0  6.17.0

NAME                           READY   STATUS    RESTARTS   AGE
pod/podinfo-6b8c7d9f5c-x7k2p   1/1     Running   0          20s

NAME              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
service/podinfo   ClusterIP   10.96.142.37    <none>        9898/TCP,9999/TCP   20s

NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/podinfo   1/1     1            1           20s

NAME                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/podinfo-6b8c7d9f5c   1         1         1       20s
```

Ein Befehl hat Deployment, ReplicaSet, Pod und Service angelegt. Die NOTES schlagen Port 8080 vor; die Übung nutzt den Service mit Port 9898 wie im Handout.

## Aufgabe 3: Seite öffnen

```bash
kubectl port-forward -n podinfo svc/podinfo 9898:9898
```

```text
Forwarding from 127.0.0.1:9898 -> 9898
Forwarding from [::1]:9898 -> 9898
```

`http://localhost:9898` zeigt das Maskottchen, darunter „Hallo aus Helm" statt „greetings from podinfo" und den Namen des Pods.

## Aufgabe 4: Werte-Datei

`project/playground/podinfo-values.yaml`:

```yaml
replicaCount: 2
ui:
  message: "Hallo aus der Werte-Datei"
  color: "#2e7d32"
```

```bash
helm upgrade podinfo oci://ghcr.io/stefanprodan/charts/podinfo --version 6.17.0 \
  -n podinfo -f playground/podinfo-values.yaml
helm get values podinfo -n podinfo
helm list -n podinfo
kubectl get pods -n podinfo
```

```text
USER-SUPPLIED VALUES:
replicaCount: 2
ui:
  color: '#2e7d32'
  message: Hallo aus der Werte-Datei

NAME     NAMESPACE  REVISION  UPDATED                            STATUS    CHART           APP VERSION
podinfo  podinfo    2         2026-11-17 10:58:40.12 +0100 CET   deployed  podinfo-6.17.0  6.17.0

NAME                       READY   STATUS    RESTARTS   AGE
podinfo-7f4d8b6c9d-2mbqz   1/1     Running   0          15s
podinfo-7f4d8b6c9d-tq9wn   1/1     Running   0          15s
```

`ui.message="Hallo aus Helm"` aus Revision 1 fehlt in `helm get values`: `helm upgrade` beginnt ohne `--reuse-values` wieder bei den Standardwerten und nimmt nur die Datei. Nach dem Neustart des `port-forward` zeigt die Seite die grüne Farbe und die neue Nachricht; beim Neuladen wechselt der Pod-Name zwischen den zwei Pods.

## Aufgabe 5: Entfernen

```bash
helm uninstall podinfo -n podinfo
kubectl get all -n podinfo
kubectl delete namespace podinfo
```

```text
release "podinfo" uninstalled
No resources found in podinfo namespace.
namespace "podinfo" deleted
```

`helm uninstall` löscht alle Objekte des Releases und seine Revisions-Secrets; den Namespace legt `--create-namespace` zwar an, entfernt ihn aber nicht wieder.

## Erweiterung: Revisions-Secrets

```bash
kubectl get secrets -n podinfo
```

```text
NAME                            TYPE                 DATA   AGE
sh.helm.release.v1.podinfo.v1   helm.sh/release.v1   1      6m
sh.helm.release.v1.podinfo.v2   helm.sh/release.v1   1      40s
```

Je Revision ein Secret vom Typ `helm.sh/release.v1`; es enthält Chart, Werte und erzeugte Manifeste der Revision.
