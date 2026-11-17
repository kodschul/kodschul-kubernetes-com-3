# Lab 6.2 – Lösung: Secrets

Alle Befehle im Ordner `project/`. `uebung-2026` ist ein Übungswert.

## Aufgabe 1: Secret per Befehl anlegen

```bash
kubectl create secret generic hello-secret --from-literal=admin-password=uebung-2026
kubectl get secret hello-secret
kubectl describe secret hello-secret
```

```text
secret/hello-secret created

NAME           TYPE     DATA   AGE
hello-secret   Opaque   1      3s

Name:         hello-secret
Namespace:    hello
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
admin-password:  11 bytes
```

`describe` verrät nur die Länge. Das Secret aus dem Beispielordner hat zusätzlich das Label `app: hello`; für die Funktion spielt das keine Rolle.

## Aufgabe 2: Base64 zurückwandeln

```bash
kubectl get secret hello-secret -o yaml
```

```yaml
apiVersion: v1
data:
  admin-password: dWVidW5nLTIwMjY=
kind: Secret
metadata:
  creationTimestamp: "2026-11-17T13:41:07Z"
  name: hello-secret
  namespace: hello
  resourceVersion: "48213"
  uid: 6f0c1d2e-8a4b-4c3d-9e7f-1a2b3c4d5e6f
type: Opaque
```

```bash
kubectl get secret hello-secret -o jsonpath='{.data.admin-password}' | base64 -d
```

```text
uebung-2026
```

Ein Befehl genügt, um aus dem gespeicherten Wert wieder Klartext zu machen. Deshalb müssen Leserechte auf Secrets begrenzt werden (Modul 10).

## Aufgabe 3: Secret als Datei ins Frontend

```bash
cp starters/m06-l02-frontend-deployment.yaml playground/k8s/frontend-deployment.yaml
```

Ergänzter Ausschnitt:

```yaml
          volumeMounts:
            - name: admin-secret
              mountPath: /etc/hello-secret
              readOnly: true
      volumes:
        - name: admin-secret
          secret:
            secretName: hello-secret
```

```bash
kubectl apply -f playground/k8s/frontend-deployment.yaml
kubectl rollout status deployment/frontend
```

```text
deployment.apps/frontend configured
Waiting for deployment "frontend" rollout to finish: 1 out of 3 new replicas have been updated...
…
deployment "frontend" successfully rolled out
```

Die Hello-Seite zeigt:

```text
Hello-App v2
Frontend-Pod: frontend-5f7d9c8b4d-k2v8n (10.1.0.52)
Backend: backend-5d7c9f6b8b-4xk2p (10.1.0.24) um 14:45:10
Admin: Passwort gesetzt
```

## Aufgabe 4: Datei im Pod ansehen

```bash
kubectl exec deploy/frontend -- ls -l /etc/hello-secret/
kubectl exec deploy/frontend -- cat /etc/hello-secret/admin-password
```

```text
total 0
lrwxrwxrwx    1 root     root            21 Nov 17 14:44 admin-password -> ..data/admin-password

uebung-2026
```

- Jeder Schlüssel des Secrets ist eine Datei. Die Verknüpfung auf `..data` erlaubt dem kubelet, alle Dateien bei einer Änderung auf einmal auszutauschen.
- Wer `kubectl exec` in diesen Pod darf, liest das Passwort. Auch `exec`-Rechte sind deshalb zu begrenzen.

## Aufgabe 5: Kein Passwort in den Umgebungsvariablen

```bash
kubectl exec deploy/frontend -- env | grep -i password
```

Keine Ausgabe: Das Passwort liegt nur in der Datei und taucht weder in `env` noch in `kubectl describe pod` auf.

## Erweiterung: Passwort ohne Neustart ändern

```bash
kubectl create secret generic hello-secret --from-literal=admin-password=neu-2026 --dry-run=client -o yaml | kubectl apply -f -
kubectl exec deploy/frontend -- cat /etc/hello-secret/admin-password
```

```text
Warning: resource secrets/hello-secret is missing the kubectl.kubernetes.io/last-applied-configuration annotation which is required by kubectl apply. …
secret/hello-secret configured

uebung-2026
```

Die Warnung entsteht, weil das Secret per `create` und nicht per `apply` angelegt wurde; sie ist harmlos. Nach etwa einer Minute zeigt `cat` den neuen Wert:

```text
neu-2026
```

Die Pods laufen weiter (`kubectl get pods -l tier=frontend` zeigt unveränderte Namen). Bei einer Umgebungsvariablen wäre ein `rollout restart` nötig.
