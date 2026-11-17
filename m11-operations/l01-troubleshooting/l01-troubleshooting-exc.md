# Lab 11.1 – Übung: Fehlersuche mit System

**Dauer:** ca. 20 Minuten
**Ändert die Hello-App-Projektbasis?** Nein — die Fehlerbilder laufen im eigenen Namespace `hello-debug`; die Helm-Releases in `hello`, `hello-dev` und `hello-prod` bleiben unverändert.

## Vorbereitung

- Varianten: [`project/variants/m11-l01-troubleshooting/fehler-1/`](../../project/variants/m11-l01-troubleshooting/fehler-1/) und [`fehler-2/`](../../project/variants/m11-l01-troubleshooting/fehler-2/), jeweils eine vollständige kleine Hello-App (Namespace, ConfigMap, Backend, Frontend) mit genau einem Fehler.
- Arbeitsordner: `project/playground/k8s/m11-fehler-1/` und `project/playground/k8s/m11-fehler-2/` (Kopien der Varianten; nur dort ändern).
- Zwei Terminals im Ordner `project/` (Windows: Git Bash): eins für Port-Forwards, die bis Strg+C laufen, eins für die Suche. Alle Befehle brauchen `-n hello-debug`, weil `hello` der Standard-Namespace ist.
- Die Images `hello-backend:v1` und `hello-frontend:v1` müssen lokal vorhanden sein: `docker images "hello-*"`. Fehlen sie: `bash build-images.sh`.
- Die Manifeste vor der Suche nicht öffnen: die Ursache soll aus dem Cluster kommen, nicht aus der Datei.
- Zu zweit möglich: eine Person führt die Befehle aus, die andere liest die Ausgaben mit. Jede Aufgabe ist allein lösbar.

## Aufgaben

1. Kopiere die erste Variante in den Arbeitsordner, wende sie an und prüfe die Seite:

   ```bash
   cp -r variants/m11-l01-troubleshooting/fehler-1 playground/k8s/m11-fehler-1
   kubectl apply -f playground/k8s/m11-fehler-1/
   kubectl get pods -n hello-debug -w            # warten, bis beide Pods laufen, dann Strg+C
   kubectl port-forward -n hello-debug svc/frontend 8083:80
   ```

   Öffne `http://localhost:8083` im Browser (oder in einem zweiten Terminal `curl -s http://localhost:8083/`) und lies die Ausgabe des Port-Forwards.
2. Suche die Ursache von außen nach innen mit der Kette aus der Theorie: Service, EndpointSlice, Pod, Container. Prüfe den Pod direkt mit `kubectl port-forward -n hello-debug pod/<frontend-pod> 8084:80` und untersuche den Container mit `kubectl debug -it <frontend-pod> -n hello-debug --image=busybox:1.37 --target=frontend` (Befehle `ps`, `netstat -tln`, `wget -qO- http://localhost:<port>/healthz`).
3. Behebe den Fehler in der passenden Datei in `playground/k8s/m11-fehler-1/`, wende den Ordner erneut an und rufe `http://localhost:8083` über einen neuen Port-Forward auf `svc/frontend` auf.
4. Beende den Port-Forward (Strg+C), lösche die erste Variante und wende die zweite an:

   ```bash
   kubectl delete namespace hello-debug        # frischer Start, keine alten Pods
   cp -r variants/m11-l01-troubleshooting/fehler-2 playground/k8s/m11-fehler-2
   kubectl apply -f playground/k8s/m11-fehler-2/
   kubectl get pods -n hello-debug
   kubectl port-forward -n hello-debug svc/frontend 8083:80
   ```

   Prüfe die Seite wie in Aufgabe 1, suche die Ursache mit Pod-Status und Events, behebe sie in `playground/k8s/m11-fehler-2/`, wende den Ordner erneut an und beobachte mit `kubectl get pods -n hello-debug -w`, wie der Frontend-Pod startet.
5. Rufe die Seite ein letztes Mal über `http://localhost:8083` auf, beende den Port-Forward und räume auf: `kubectl delete namespace hello-debug`.

## Checkpoint

- Nach Aufgabe 1 antwortet `http://localhost:8083` nicht; der Port-Forward meldet einen Fehler.
- Nach Aufgabe 2 antwortet der Pod direkt über Port 8084.
- Nach Aufgabe 3 zeigt `http://localhost:8083` die rosa Seite „Hello-App v1" mit Antwort des Backends.
- Nach Aufgabe 4 steht der Frontend-Pod zunächst nicht auf `Running`; nach der Behebung zeigt `kubectl get pods -n hello-debug` beide Pods mit `1/1`.

## Abschlusskriterien

- Beide Fehlerbilder sind behoben, die Seite war jeweils über `svc/frontend` erreichbar.
- Für jeden Fehler ist die Station der Kette (Route, Service, EndpointSlice, Pod oder Container) und der Befehl bekannt, dessen Ausgabe die Ursache gezeigt hat.
- `kubectl get namespace hello-debug` meldet `NotFound`.

## Erweiterung

Dritte Variante ohne Port-Forward-Abkürzung: Wende [`fehler-3/`](../../project/variants/m11-l01-troubleshooting/fehler-3/) aus einer Kopie in `playground/k8s/m11-fehler-3/` an und teste den Service aus dem Cluster heraus:

```bash
kubectl run test -n hello-debug --rm -it --restart=Never --image=busybox:1.37 -- wget -qO- -T 3 http://frontend
```

Finde und behebe die Ursache, suche danach dieselben Warnungen in Headlamp (Namespace `hello-debug` → Pods → Frontend-Pod → Events) und räume mit `kubectl delete namespace hello-debug` auf.

## Fallback

- Port-Forward oder Browser streiken: `curl -s http://localhost:8083/` im zweiten Terminal, oder der Test-Pod aus der Erweiterung.
- `busybox:1.37` lässt sich nicht laden (Docker-Hub-Limit): Ohne `kubectl debug` zeigen `kubectl describe pod` (Abschnitt `Port`) und die Logs des Frontends (`Hello-Frontend v1 auf Port …`) dieselbe Information.
- Hello-App-Stand aus Lab 10.3 kaputt: Die Übung braucht ihn nicht; `hello-debug` ist unabhängig davon.
