# Lab 2.4 – Übung: Manifeste und deklaratives Arbeiten

**Dauer:** ca. 20 Minuten
**Ändert die Hello-App-Projektbasis?** Ja — es entsteht `playground/k8s/00-namespace.yaml`; der Namespace `hello` ist ab jetzt Standard im Kontext, und alle Objekte ab Lab 3.1 liegen darin.

## Vorbereitung

- Terminal im Ordner `project/` öffnen; Cluster aus Lab 2.2 läuft (`kubectl get nodes` zeigt `Ready`).
- Starter: keiner; das Manifest entsteht in Aufgabe 1 per `--dry-run`.
- Arbeitsdatei: `project/playground/k8s/00-namespace.yaml`
- Vergleich: [`project/examples/m02-kubernetes-intro/l04-manifests/00-namespace.yaml`](../../project/examples/m02-kubernetes-intro/l04-manifests/00-namespace.yaml)

## Aufgaben

1. Erzeuge das Manifest des Namespace `hello` mit `kubectl create namespace hello --dry-run=client -o yaml`, speichere die Ausgabe mit `>` als `playground/k8s/00-namespace.yaml` und öffne die Datei in VS Code. Entferne die leeren Zeilen `spec: {}` und `status: {}`.
2. Wende die Datei mit `kubectl apply -f playground/k8s/00-namespace.yaml` an und zeige mit `kubectl get namespaces` alle Namespaces an. Wende die Datei danach ein zweites Mal an.
3. Setze `hello` mit `kubectl config set-context --current --namespace=hello` als Standard-Namespace und prüfe das Ergebnis mit `kubectl config get-contexts` und `kubectl get pods`.
4. Lies mit `kubectl explain pod.spec.containers` die Felder eines Containers und mit `kubectl explain pod.spec.containers.imagePullPolicy` die erlaubten Werte dieses Felds.
5. Zeige das gespeicherte Objekt mit `kubectl get namespace hello -o yaml` und mit `kubectl get namespace hello -o kyaml` an und finde in beiden Ausgaben `status.phase`.

## Checkpoint

- `playground/k8s/00-namespace.yaml` enthält `apiVersion: v1`, `kind: Namespace` und `metadata.name: hello`.
- Erstes `apply`: `namespace/hello created`; zweites `apply`: `namespace/hello unchanged`.
- `kubectl config get-contexts` zeigt in der Spalte `NAMESPACE` den Wert `hello`; `kubectl get pods` meldet `No resources found in hello namespace.`
- `kubectl explain` nennt für `imagePullPolicy` die Werte `Always`, `IfNotPresent` und `Never`.
- Beide Ausgaben in Aufgabe 5 zeigen `phase: Active` bzw. `phase: "Active"`.

## Abschlusskriterien

- Der Namespace `hello` existiert, ist im Kontext `docker-desktop` als Standard gesetzt und als Datei in `playground/k8s/` beschrieben.

## Erweiterung

Lege die Datei `~/.kube/kuberc` mit dem Alias `getw` aus dem Theorieteil an (z. B. mit `code ~/.kube/kuberc`) und teste ihn mit `kubectl getw nodes` und `kubectl getw pods -n kube-system`. Lösche danach den Namespace probeweise imperativ mit `kubectl delete namespace hello` und stelle ihn deklarativ mit `kubectl apply -f playground/k8s/00-namespace.yaml` wieder her.

## Fallback

- Stand dieses Labs wiederherstellen (z. B. vor Lab 3.1 oder nach einem Cluster-Reset):

  ```bash
  kubectl apply -f examples/m02-kubernetes-intro/l04-manifests/
  kubectl config set-context --current --namespace=hello
  ```

- `-o kyaml` meldet einen Fehler: `kubectl` ist älter als 1.35; Aufgabe 5 nur mit `-o yaml` lösen und `which kubectl` prüfen.
