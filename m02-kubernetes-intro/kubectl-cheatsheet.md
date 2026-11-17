# kubectl – Cheatsheet (Modul 2)

## Cluster und Version

| Befehl | Wirkung |
| --- | --- |
| `kubectl version` | Version von `kubectl` (Client) und Cluster (Server) |
| `kubectl cluster-info` | Adresse des API-Servers und von CoreDNS |
| `kubectl get nodes` | Nodes mit Status (`Ready`), Rolle und Version |
| `kubectl get nodes -o wide` | zusätzlich IP, Betriebssystem, Kernel, Container-Runtime |
| `kubectl describe node docker-desktop` | alle Details eines Nodes, inkl. Kapazität und Ereignisse |

## Lokales Cluster verwalten

| Befehl / Aktion | Wirkung |
| --- | --- |
| Docker Desktop > **Kubernetes** > **Reset cluster** | Cluster leeren und mit der aktuellen Version neu erstellen |
| Docker Desktop > **Kubernetes** > **Stop** | Cluster entfernen (auch `kubectl` von Docker Desktop) |
| `minikube status` / `minikube stop` / `minikube delete` | Fallback minikube: Zustand prüfen / anhalten / löschen |
| `kind delete cluster --name kurs` | Fallback kind: Cluster löschen |

## kubeconfig und Kontext

| Befehl | Wirkung |
| --- | --- |
| `kubectl config get-contexts` | alle Kontexte; `*` = aktueller, Spalte `NAMESPACE` = Standard-Namespace |
| `kubectl config current-context` | Name des aktuellen Kontexts |
| `kubectl config use-context docker-desktop` | Kontext wechseln |
| `kubectl config view --minify` | kubeconfig des aktuellen Kontexts, Zertifikate ausgeblendet |
| `kubectl config set-context --current --namespace=hello` | Standard-Namespace im aktuellen Kontext setzen |
| `kubectl config view --minify \| grep namespace:` | gesetzten Standard-Namespace prüfen |

## Architektur erkunden

| Befehl | Wirkung |
| --- | --- |
| `kubectl get pods -n kube-system` | Systemkomponenten (API-Server, etcd, Scheduler, …) |
| `kubectl get pods -n kube-system -o wide` | dazu IP und Node je Pod |
| `kubectl logs -n kube-system kube-scheduler-docker-desktop` | Ausgaben einer Komponente |
| `kubectl get --raw /livez` | Lebenszeichen des API-Servers (`ok`) |
| `kubectl get --raw '/livez?verbose'` | alle Einzelprüfungen, z. B. `[+]etcd ok` |
| `kubectl api-resources` | alle Objekttypen mit Kurzname und Namespace-Bezug |

## Manifeste

| Befehl | Wirkung |
| --- | --- |
| `kubectl explain namespace` | Doku eines Objekttyps |
| `kubectl explain pod.spec.containers` | Doku eines Felds, mit Punkten in die Tiefe |
| `kubectl create namespace hello --dry-run=client -o yaml > playground/k8s/00-namespace.yaml` | Manifest erzeugen und speichern, ohne etwas anzulegen |
| `kubectl apply -f playground/k8s/00-namespace.yaml` | Datei anwenden: anlegen oder angleichen |
| `kubectl apply -f playground/k8s/` | alle Dateien eines Ordners anwenden |
| `kubectl diff -f playground/k8s/00-namespace.yaml` | Unterschied zwischen Datei und Cluster zeigen |
| `kubectl delete -f playground/k8s/00-namespace.yaml` | beschriebene Objekte löschen |
| `kubectl get namespace hello -o yaml` | gespeichertes Objekt als YAML (mit `status`) |
| `kubectl get namespace hello -o kyaml` | dasselbe als KYAML (ab 1.35, stabil seit 1.37) |

## Namespaces

| Befehl | Wirkung |
| --- | --- |
| `kubectl get namespaces` (`kubectl get ns`) | alle Namespaces |
| `kubectl get pods -n kube-system` | Befehl in einem bestimmten Namespace |
| `kubectl get pods -A` | Befehl über alle Namespaces |
| `kubectl create namespace demo` | Namespace imperativ anlegen (zum Ausprobieren) |
| `kubectl delete namespace demo` | Namespace samt Inhalt löschen |

## Objekttypen und Kurznamen

| Typ | Kurzname | gehört zu Namespace |
| --- | --- | --- |
| `pods` | `po` | ja |
| `nodes` | `no` | nein |
| `namespaces` | `ns` | nein |

## kuberc (`~/.kube/kuberc`)

| Eintrag | Wirkung |
| --- | --- |
| `apiVersion: kubectl.config.k8s.io/v1beta1`, `kind: Preference` | Kopf der Datei |
| `aliases:` mit `name`, `command`, `options` | eigener Befehl, z. B. `kubectl getw` = `kubectl get -o wide` |
| `defaults:` mit `command`, `options` | Standardoptionen für vorhandene Befehle |
| `KUBECTL_KUBERC=false` | kuberc für einen Aufruf abschalten |

## Projektstand

| Befehl | Wirkung |
| --- | --- |
| `kubectl apply -f examples/m02-kubernetes-intro/l04-manifests/` | Stand nach Lab 2.4 herstellen (aus `project/`) |
| `kubectl config set-context --current --namespace=hello` | danach `hello` als Standard setzen |
