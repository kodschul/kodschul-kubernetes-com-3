# Lab 2.2 – Lösung: Lokales Cluster starten

## Aufgabe 1: Cluster erstellen

Docker Desktop > **Kubernetes** > **Create cluster** > **Kubeadm** > **Create**. Nach 1–3 Minuten zeigt die Statusleiste `Kubernetes running`; Docker Desktop hat dabei `kubectl` installiert und den Kontext `docker-desktop` in `~/.kube/config` eingetragen. Bedienung Stand: 11/2026 ([Docker Docs](https://docs.docker.com/desktop/use-desktop/kubernetes/)).

## Aufgabe 2: Versionen

```bash
kubectl version
```

```text
Client Version: v1.37.x
Kustomize Version: v5.x.x
Server Version: v1.37.x
```

Die genaue Version legt Docker Desktop fest (1.36 oder 1.37). Erscheint nur `Client Version` und danach ein Verbindungsfehler, läuft das Cluster noch nicht.

## Aufgabe 3: Node anzeigen

```bash
kubectl get nodes
```

```text
NAME             STATUS   ROLES           AGE   VERSION
docker-desktop   Ready    control-plane   4m    v1.37.x
```

```bash
kubectl get nodes -o wide
```

```text
NAME             STATUS   ROLES           AGE   VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE         KERNEL-VERSION       CONTAINER-RUNTIME
docker-desktop   Ready    control-plane   4m    v1.37.x   192.168.65.3   <none>        Docker Desktop   6.x.x-linuxkit       docker://29.x.x
```

- `ROLES control-plane`: Der eine Node trägt die Steuerzentrale und führt zugleich die Container aus.
- `-o wide` (wide = breit) zeigt zusätzliche Spalten. IP, Kernel und Runtime-Version weichen ab.
- `CONTAINER-RUNTIME` zeigt, welche Runtime die Container startet; im Kubeadm-Cluster von Docker Desktop ist es die Docker Engine, deshalb sind selbst gebaute Images dort sofort sichtbar. In Cloud-Clustern steht hier meist `containerd://2.x`.

## Aufgabe 4: Kontexte

```bash
kubectl config get-contexts
kubectl config current-context
```

```text
CURRENT   NAME             CLUSTER          AUTHINFO         NAMESPACE
*         docker-desktop   docker-desktop   docker-desktop
docker-desktop
```

Gibt es weitere Kontexte (z. B. aus der Firma), stehen sie darunter ohne `*`. `AUTHINFO` ist der Benutzer-Eintrag aus `users:`. Die Spalte `NAMESPACE` ist noch leer; Lab 2.4 füllt sie.

## Aufgabe 5: kubeconfig ansehen

```bash
kubectl config view --minify
```

```yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://kubernetes.docker.internal:6443
  name: docker-desktop
contexts:
- context:
    cluster: docker-desktop
    user: docker-desktop
  name: docker-desktop
current-context: docker-desktop
kind: Config
users:
- name: docker-desktop
  user:
    client-certificate-data: DATA+OMITTED
    client-key-data: DATA+OMITTED
```

Der API-Server liegt unter `https://kubernetes.docker.internal:6443`; Docker Desktop lässt diesen Namen auf den eigenen Rechner zeigen. `--minify` zeigt nur den aktuellen Kontext, `DATA+OMITTED` blendet die Zertifikate aus.

## Erweiterung: cluster-info und Datei

```bash
kubectl cluster-info
```

```text
Kubernetes control plane is running at https://kubernetes.docker.internal:6443
CoreDNS is running at https://kubernetes.docker.internal:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

In `~/.kube/config` stehen statt `DATA+OMITTED` lange Base64-Zeichenketten: die echten Zertifikate und der private Schlüssel. Deshalb gehört die Datei in kein Repository und in keine E-Mail.
