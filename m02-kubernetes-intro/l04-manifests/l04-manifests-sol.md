# Lab 2.4 – Lösung: Manifeste und deklaratives Arbeiten

## Aufgabe 1: Manifest per Dry-Run erzeugen

```bash
kubectl create namespace hello --dry-run=client -o yaml
```

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: hello
spec: {}
status: {}
```

Je nach `kubectl`-Version steht unter `metadata` zusätzlich `creationTimestamp: null`; die Zeile ist harmlos und darf gelöscht werden.

```bash
kubectl create namespace hello --dry-run=client -o yaml > playground/k8s/00-namespace.yaml
```

`playground/k8s/00-namespace.yaml` nach dem Aufräumen:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: hello
```

Der Inhalt entspricht [`examples/m02-kubernetes-intro/l04-manifests/00-namespace.yaml`](../../project/examples/m02-kubernetes-intro/l04-manifests/00-namespace.yaml) (dort zusätzlich mit Kommentaren). `--dry-run=client` hat nichts im Cluster angelegt; `kubectl get namespace hello` meldet an dieser Stelle noch `NotFound`.

## Aufgabe 2: Anwenden, zweimal

```bash
kubectl apply -f playground/k8s/00-namespace.yaml
kubectl get namespaces
kubectl apply -f playground/k8s/00-namespace.yaml
```

```text
namespace/hello created
NAME              STATUS   AGE
default           Active   2h
hello             Active   3s
kube-node-lease   Active   2h
kube-public       Active   2h
kube-system       Active   2h
namespace/hello unchanged
```

Das zweite `apply` ändert nichts und meldet keinen Fehler: Der gewünschte Zustand ist bereits erreicht. `kubectl create namespace hello` würde an dieser Stelle mit `AlreadyExists` abbrechen.

## Aufgabe 3: Standard-Namespace setzen

```bash
kubectl config set-context --current --namespace=hello
kubectl config get-contexts
kubectl get pods
```

```text
Context "docker-desktop" modified.
CURRENT   NAME             CLUSTER          AUTHINFO         NAMESPACE
*         docker-desktop   docker-desktop   docker-desktop   hello
No resources found in hello namespace.
```

Gleichwertige Prüfung: `kubectl config view --minify | grep namespace:` gibt `namespace: hello` aus. Die Einstellung steht in `~/.kube/config` und bleibt nach einem Neustart erhalten.

## Aufgabe 4: kubectl explain

```bash
kubectl explain pod.spec.containers
```

```text
KIND:       Pod
VERSION:    v1

FIELD: containers <[]Container>

DESCRIPTION:
    List of containers belonging to the pod. Containers cannot currently be
    added or removed. There must be at least one container in a Pod. Cannot be
    updated.
    …
FIELDS:
  args  <[]string>
  …
  env   <[]EnvVar>
  …
  image <string>
  imagePullPolicy       <string>
  …
  name  <string> -required-
  ports <[]ContainerPort>
  …
```

`<[]Container>` heißt: eine Liste von Containern; `-required-` markiert Pflichtfelder. `name`, `image` und `env` nutzt Lab 3.1.

```bash
kubectl explain pod.spec.containers.imagePullPolicy
```

```text
FIELD: imagePullPolicy <string>
ENUM:
    Always
    IfNotPresent
    Never

DESCRIPTION:
    Image pull policy. One of Always, Never, IfNotPresent. Defaults to Always if
    :latest tag is specified, or IfNotPresent otherwise.
    …
```

`ENUM` listet die erlaubten Werte. Die Beschreibung erklärt, warum `latest` in Lab 1.3 vermieden wurde: Mit `:latest` versucht Kubernetes immer, das Image neu zu laden.

## Aufgabe 5: Gespeichertes Objekt als YAML und KYAML

```bash
kubectl get namespace hello -o yaml
```

```yaml
apiVersion: v1
kind: Namespace
metadata:
  creationTimestamp: "2026-11-17T09:12:03Z"
  labels:
    kubernetes.io/metadata.name: hello
  name: hello
  resourceVersion: "4711"
  uid: 6f1c2a7e-…
spec:
  finalizers:
  - kubernetes
status:
  phase: Active
```

```bash
kubectl get namespace hello -o kyaml
```

```text
---
{
  apiVersion: "v1",
  kind: "Namespace",
  metadata: {
    creationTimestamp: "2026-11-17T09:12:03Z",
    labels: {
      "kubernetes.io/metadata.name": "hello",
    },
    name: "hello",
    resourceVersion: "4711",
    uid: "6f1c2a7e-…",
  },
  spec: {
    finalizers: ["kubernetes"],
  },
  status: {
    phase: "Active",
  },
}
```

Beide Ausgaben beschreiben dasselbe Objekt. Gegenüber der eigenen Datei sind `creationTimestamp`, `labels`, `uid`, `spec.finalizers` und `status` dazugekommen: Kubernetes ergänzt sie beim Speichern. In KYAML stehen alle Texte in Anführungszeichen und die Struktur in Klammern; Zeitstempel, IDs und Versionsnummern weichen ab.

## Erweiterung: kuberc und Namespace wiederherstellen

`~/.kube/kuberc`:

```yaml
apiVersion: kubectl.config.k8s.io/v1beta1
kind: Preference
aliases:
- name: getw
  command: get
  options:
  - name: output
    default: wide
```

```bash
kubectl getw nodes
```

```text
NAME             STATUS   ROLES           AGE   VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE         …
docker-desktop   Ready    control-plane   2h    v1.37.x   192.168.65.3   <none>        Docker Desktop   …
```

```bash
kubectl delete namespace hello
kubectl apply -f playground/k8s/00-namespace.yaml
```

```text
namespace "hello" deleted
namespace/hello created
```

Das Löschen eines Namespace entfernt alles darin; deshalb ist es hier nur jetzt, solange `hello` leer ist, ungefährlich. Die Datei stellt den Zustand jederzeit wieder her. Die Standard-Namespace-Einstellung im Kontext bleibt beim Löschen erhalten.
