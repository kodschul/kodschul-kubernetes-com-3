# Lab 5.1 – Lösung: Services und DNS

Alle Befehle im Ordner `project/`. IPs, Pod-Namen und Uhrzeiten weichen ab.

## Aufgabe 1: Hello-Seite ohne Backend-Service

```bash
kubectl port-forward deployment/frontend 8080:80
```

```text
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
```

Die Seite `http://localhost:8080` zeigt:

```text
Hello-App v2
Frontend-Pod: frontend-6c9d8b7f5-2kq8r (10.1.0.31)
Backend: Backend nicht erreichbar (http://backend): ConnectionError
Admin: kein Passwort gesetzt
```

Grund: Den Namen `backend` gibt es im Cluster-DNS noch nicht.

## Aufgabe 2: Service anlegen und EndpointSlice prüfen

```bash
cp starters/m05-l01-backend-service.yaml playground/k8s/backend-service.yaml
```

Ergänzte Datei `playground/k8s/backend-service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: backend
  labels:
    app: hello
    tier: backend
spec:
  type: ClusterIP
  selector:
    app: hello                # gleiche Labels wie im Selector des Deployments
    tier: backend
  ports:
    - port: 80
      targetPort: 80          # containerPort des Backends
      protocol: TCP
```

```bash
kubectl apply -f playground/k8s/backend-service.yaml
kubectl get service backend
kubectl get endpointslices -l kubernetes.io/service-name=backend
kubectl get pods -l tier=backend -o wide
```

```text
service/backend created

NAME      TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
backend   ClusterIP   10.106.45.17   <none>        80/TCP    3s

NAME            ADDRESSTYPE   PORTS   ENDPOINTS                       AGE
backend-7xk2p   IPv4          80      10.1.0.24,10.1.0.25,10.1.0.26   3s

NAME                       READY   STATUS    RESTARTS   AGE   IP          NODE             NOMINATED NODE   READINESS GATES
backend-5d7c9f6b8b-4xk2p   1/1     Running   0          41m   10.1.0.24   docker-desktop   <none>           <none>
backend-5d7c9f6b8b-9tq7d   1/1     Running   0          41m   10.1.0.25   docker-desktop   <none>           <none>
backend-5d7c9f6b8b-zm5wb   1/1     Running   0          41m   10.1.0.26   docker-desktop   <none>           <none>
```

Die drei Endpoints sind genau die IPs der drei Backend-Pods.

## Aufgabe 3: Lastverteilung beobachten

Beim mehrfachen Neuladen wechselt die Zeile **Backend**, z. B.:

```text
Backend: backend-5d7c9f6b8b-9tq7d (10.1.0.25) um 10:52:11
Backend: backend-5d7c9f6b8b-4xk2p (10.1.0.24) um 10:52:13
Backend: backend-5d7c9f6b8b-9tq7d (10.1.0.25) um 10:52:14
Backend: backend-5d7c9f6b8b-zm5wb (10.1.0.26) um 10:52:16
```

Die Reihenfolge ist zufällig; kube-proxy wählt je Verbindung einen Pod. Der Frontend-Pod bleibt gleich, weil `port-forward` fest mit einem Pod verbunden ist. Ohne Neustart des Frontends funktioniert die Seite jetzt, weil das Frontend den Namen bei jeder Anfrage neu auflöst.

## Aufgabe 4: DNS-Test aus einem Test-Pod

```bash
kubectl run tmp --rm -it --image=busybox:1.37 --restart=Never -- nslookup backend
```

```text
Server:		10.96.0.10
Address:	10.96.0.10:53

** server can't find backend.cluster.local: NXDOMAIN

Name:	backend.hello.svc.cluster.local
Address: 10.106.45.17

pod "tmp" deleted
```

```bash
kubectl run tmp --rm -it --image=busybox:1.37 --restart=Never -- wget -qO- http://backend.hello.svc.cluster.local
```

```text
{"ip":"10.1.0.26","pod":"backend-5d7c9f6b8b-zm5wb","time":"10:53:40","version":"v1"}
pod "tmp" deleted
```

`10.96.0.10` ist die ClusterIP von CoreDNS (Service `kube-dns` in `kube-system`). Die NXDOMAIN-Zeile entsteht durch die Suchliste und ist harmlos.

## Aufgabe 5: Falscher Selector

Geänderter Ausschnitt:

```yaml
  selector:
    app: hello
    tier: backnd              # absichtlicher Tippfehler
```

```bash
kubectl apply -f playground/k8s/backend-service.yaml
kubectl get endpointslices -l kubernetes.io/service-name=backend
kubectl describe service backend | grep -E 'Selector|Endpoints'
```

```text
service/backend configured

NAME            ADDRESSTYPE   PORTS     ENDPOINTS   AGE
backend-7xk2p   IPv4          <unset>   <unset>     6m

Selector:                 app=hello,tier=backnd
Endpoints:
```

Die Hello-Seite meldet `Backend nicht erreichbar (http://backend): ConnectionError`. Der Name löst weiter auf, aber hinter der ClusterIP steht kein Pod; kube-proxy lehnt die Verbindung ab.

Korrektur: `tier: backend` zurücksetzen und erneut anwenden.

```bash
kubectl apply -f playground/k8s/backend-service.yaml
kubectl get endpointslices -l kubernetes.io/service-name=backend
```

```text
service/backend configured

NAME            ADDRESSTYPE   PORTS   ENDPOINTS                       AGE
backend-7xk2p   IPv4          80      10.1.0.24,10.1.0.25,10.1.0.26   7m
```

Prüfweg bei leerer EndpointSlice: `kubectl get pods --show-labels` neben die Zeile `Selector:` aus `kubectl describe service` legen.

## Erweiterung: EndpointSlice beim Skalieren

```bash
kubectl get endpointslices -l kubernetes.io/service-name=backend -w     # Terminal 3
kubectl scale deployment backend --replicas=5
kubectl scale deployment backend --replicas=3
```

```text
NAME            ADDRESSTYPE   PORTS   ENDPOINTS                       AGE
backend-7xk2p   IPv4          80      10.1.0.24,10.1.0.25,10.1.0.26   9m
backend-7xk2p   IPv4          80      10.1.0.24,10.1.0.25,10.1.0.26 + 2 more...   9m
backend-7xk2p   IPv4          80      10.1.0.24,10.1.0.25,10.1.0.26   10m
```

Neue Pods erscheinen in der Liste, sobald sie bereit sind; gelöschte Pods verschwinden sofort.
