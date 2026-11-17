# Lab 5.2 – Lösung: NodePort, LoadBalancer und Port-Forward

Alle Befehle im Ordner `project/`. IPs, Ports und Pod-Namen weichen ab.

## Aufgabe 1: Frontend als NodePort

```bash
cp starters/m05-l02-frontend-service.yaml playground/k8s/frontend-service.yaml
```

Ergänzter Ausschnitt:

```yaml
spec:
  type: NodePort
  selector:
    app: hello
    tier: frontend
  ports:
    - port: 8080
      targetPort: 80
      protocol: TCP
```

```bash
kubectl apply -f playground/k8s/frontend-service.yaml
kubectl get service frontend
```

```text
service/frontend created

NAME       TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
frontend   NodePort   10.104.12.200   <none>        8080:31847/TCP   4s
```

Der NodePort ist hier `31847` (zufällig aus 30000–32767).

## Aufgabe 2: Zugriff über den NodePort

`http://localhost:31847` zeigt die Hello-Seite. Beim Neuladen wechseln beide Zeilen:

```text
Frontend-Pod: frontend-6c9d8b7f5-2kq8r (10.1.0.31)   Backend: backend-5d7c9f6b8b-zm5wb (10.1.0.26) …
Frontend-Pod: frontend-6c9d8b7f5-x7m4c (10.1.0.33)   Backend: backend-5d7c9f6b8b-4xk2p (10.1.0.24) …
```

Jetzt verteilt auch der Service `frontend` auf die drei Frontend-Pods. Lädt die Adresse nicht, leitet diese Docker-Desktop-Version NodePorts nicht nach `localhost` weiter (siehe Fallback).

## Aufgabe 3: Umstellung auf LoadBalancer

```yaml
spec:
  type: LoadBalancer
```

```bash
kubectl apply -f playground/k8s/frontend-service.yaml
kubectl get service frontend
```

```text
service/frontend configured

NAME       TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
frontend   LoadBalancer   10.104.12.200   localhost     8080:31847/TCP   2m
```

ClusterIP und NodePort bleiben; dazu kommt `EXTERNAL-IP localhost`. `http://localhost:8080` zeigt die grüne Seite „Hello-App v2" mit wechselnden Frontend- und Backend-Pods. Auf einem Cloud-Cluster stünde in `EXTERNAL-IP` eine öffentliche IP.

## Aufgabe 4: Port-Forward auf den Service

```bash
kubectl port-forward service/frontend 9090:8080
```

```text
Forwarding from 127.0.0.1:9090 -> 80
Forwarding from [::1]:9090 -> 80
Handling connection for 9090
```

`http://localhost:9090` zeigt immer denselben Frontend-Pod: Port-Forward löst den Service beim Start in genau einen Pod auf (`-> 80` ist der `targetPort`). Die Backend-Zeile wechselt weiter, weil das Frontend über den Service `backend` fragt.

Vergleich der drei Wege:

| Weg | Adresse | verteilt auf Frontend-Pods? |
| --- | --- | --- |
| NodePort | `localhost:31847` | ja |
| LoadBalancer | `localhost:8080` | ja |
| Port-Forward | `localhost:9090` | nein, ein Pod |
