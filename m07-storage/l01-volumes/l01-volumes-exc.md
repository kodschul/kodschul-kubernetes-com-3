# Lab 7.1 – Übung: Volumes

**Dauer:** ca. 15 Minuten
**Ändert die Hello-App-Projektbasis?** Ja — das Frontend läuft mit einer Replik und schreibt `access.log` in das `emptyDir`-Volume `data`; Lab 7.2 ersetzt es durch ein PersistentVolume.

## Vorbereitung

- Terminal (macOS/Linux: Terminal, Windows: Git Bash) im Ordner `project/` öffnen.
- Starter: [`project/starters/m07-l01-frontend-deployment.yaml`](../../project/starters/m07-l01-frontend-deployment.yaml)
- Arbeitsdatei: `project/playground/k8s/frontend-deployment.yaml`
- Prüfen: `kubectl get deployments` zeigt `backend` und `frontend` mit `3/3`, `curl -s http://hello.localhost/ | grep Hello-App` zeigt eine Zeile mit `Hello-App v2`.
- Stand aus Lab 6.2 wiederherstellen (falls nötig): `kubectl apply -f examples/m06-configuration/l02-secrets/`

## Aufgaben

1. Skaliere das Frontend auf einen Pod (`kubectl scale deployment frontend --replicas=1`) und warte, bis `kubectl get pods -l tier=frontend` nur noch einen Pod zeigt (bis zu 30 Sekunden). Rufe die Seite dreimal mit `curl -s -o /dev/null http://hello.localhost/` auf und zeige das Log mit `kubectl exec deploy/frontend -- cat /data/access.log`. Starte danach den Container mit `kubectl exec deploy/frontend -- kill -INT 1` neu und lies das Log nach einigen Sekunden erneut.
2. Kopiere den Starter nach `playground/k8s/frontend-deployment.yaml`, ergänze die drei TODOs (eine Replik, Volume `data` als `emptyDir`, eingehängt unter `/data`) und wende die Datei an. Warte mit `kubectl rollout status deployment/frontend`, bis der neue Pod läuft.
3. Rufe die Seite wieder dreimal auf, lies das Log, starte den Container wie in Aufgabe 1 neu und lies das Log noch einmal. Prüfe mit `kubectl get pods -l tier=frontend` die Spalte `RESTARTS`.
4. Lösche den Frontend-Pod mit `kubectl delete pod -l tier=frontend`, warte, bis der Ersatz `Running` ist, und lies das Log. Rufe die Seite danach einmal auf und lies es erneut.
5. Zeige mit `kubectl describe pod -l tier=frontend` den Abschnitt `Volumes` und unter `Containers` die Zeile `Mounts` des neuen Pods an.

## Checkpoint

- Aufgabe 1: drei Zeilen vor dem Neustart; danach `No such file or directory`, `RESTARTS 1`.
- Aufgabe 3: drei Zeilen vor und nach dem Neustart; `RESTARTS 1`.
- Aufgabe 4: zuerst `No such file or directory`, nach dem Aufruf eine Zeile mit dem neuen Pod-Namen.
- Aufgabe 5: `data` mit `Type: EmptyDir` und `/data from data (rw)`.

## Abschlusskriterien

- `kubectl get deployment frontend` zeigt `1/1`.
- `playground/k8s/frontend-deployment.yaml` enthält das Volume `data` vom Typ `emptyDir`, eingehängt unter `/data`.

## Fallback

- `curl` löst `hello.localhost` nicht auf: `curl -s -o /dev/null -H "Host: hello.localhost" http://localhost/` verwenden, oder die Seite im Browser (Chrome, Edge, Firefox) dreimal neu laden.
- Fertiger Stand zum Vergleichen oder Wiederherstellen: `kubectl apply -f examples/m07-storage/l01-volumes/`
