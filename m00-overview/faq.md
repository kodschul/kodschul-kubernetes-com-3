# FAQ

## Brauche ich Docker, um Kubernetes zu nutzen?

- Nein: Kubernetes startet Container über containerd, nicht über Docker.
- Docker (oder Podman) dient zum Bauen von Images; im Kurs auch für das lokale Cluster.

## Welches lokale Cluster ist das richtige?

- Im Kurs: Docker Desktop mit Kubernetes (Typ Kubeadm), weil selbst gebaute Images ohne Registry nutzbar sind.
- Alternativen: minikube oder kind; Images dort mit `minikube image load` bzw. `kind load docker-image` laden.
- Details: [Setup](../00-setup-and-installation.md), [Lab 2.2](../m02-kubernetes-intro/l02-local-cluster/l02-local-cluster-thx.md)

## Was ist der Unterschied zwischen Pod und Container?

- Ein Pod umhüllt einen oder mehrere Container mit gemeinsamer IP und gemeinsamen Volumes.
- Kubernetes plant und startet immer Pods, nie einzelne Container.

## Warum Deployments und keine einzelnen Pods?

- Ein gelöschter Pod kommt nicht zurück; ein Deployment ersetzt ihn sofort.
- Deployments rollen neue Versionen schrittweise aus und können zurückrollen.

## Ist ein Secret verschlüsselt?

- Nein, nur Base64-codiert; wer es lesen darf, sieht den Klartext.
- Schutz kommt über RBAC, Verschlüsselung in etcd und Werkzeuge wie External Secrets Operator.

## Was passiert mit Ingress?

- Die Ingress-API bleibt in Kubernetes, wird aber nicht weiterentwickelt.
- ingress-nginx ist seit 24.03.2026 eingestellt; neue Setups nutzen die Gateway API.

## Wo ist das Kubernetes Dashboard?

- Seit 21.01.2026 archiviert; der Nachfolger ist Headlamp (Desktop-App oder im Cluster).

## Helm 3 oder Helm 4?

- Helm 4 seit 12.11.2025; Helm 3 bekommt nur noch Sicherheitsfixes bis 10.02.2027.
- Charts mit `apiVersion: v2` laufen mit beiden; einige Flags heißen neu (`--atomic` → `--rollback-on-failure`).

## Die Hello-Seite zeigt „Backend nicht erreichbar"

- `BACKEND_URL` prüfen: `kubectl exec deploy/frontend -- env | grep BACKEND`.
- Service und EndpointSlice prüfen: `kubectl get endpointslices -l kubernetes.io/service-name=backend`.

## Ein Pod hängt in `ErrImageNeverPull`

- Das Image fehlt lokal oder das Cluster sieht die Docker-Images nicht.
- `docker images | grep hello` prüfen, bei Bedarf `bash build-images.sh`; Cluster-Typ Kubeadm verwenden.

## Wie komme ich zurück auf einen sauberen Stand?

- Namespace löschen und den Lab-Stand neu anwenden: `kubectl delete namespace hello`, dann `kubectl apply -f examples/<modul>/<lab>/`.
- Ab Modul 9 liegt die App als Helm-Release vor: `helm uninstall hello -n hello`, dann neu installieren.

## Was kommt nach dem Kurs?

- Monitoring, GitOps, Policies und verwaltete Cluster: [Lab 11.3](../m11-operations/l03-ecosystem/l03-ecosystem-thx.md)
- Zertifizierungen: CKAD (Entwicklung) und CKA (Betrieb).
