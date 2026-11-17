# Lab 5.1 – Übung: Services und DNS

**Dauer:** ca. 20 Minuten
**Ändert die Hello-App-Projektbasis?** Ja — neuer Service `backend`; das Frontend erreicht das Backend über `http://backend`. Lab 5.2 ergänzt einen Service für das Frontend.

## Vorbereitung

- Terminal (macOS/Linux: Terminal, Windows: Git Bash) im Ordner `project/` öffnen.
- Starter: [`project/starters/m05-l01-backend-service.yaml`](../../project/starters/m05-l01-backend-service.yaml)
- Arbeitsdatei: `project/playground/k8s/backend-service.yaml`
- Prüfen: `kubectl get deployments` zeigt `backend` und `frontend` mit `READY 3/3`.
- Stand aus Lab 4.3 wiederherstellen (falls nötig): `kubectl apply -f examples/m04-deployments/l03-rollouts/`

## Aufgaben

1. Starte in einem zweiten Terminal `kubectl port-forward deployment/frontend 8080:80` und öffne `http://localhost:8080`. Die Seite meldet noch `Backend nicht erreichbar (http://backend)`.
2. Kopiere den Starter nach `playground/k8s/backend-service.yaml`, ergänze die TODOs und wende die Datei an. Zeige danach mit `kubectl get service backend` die ClusterIP und mit `kubectl get endpointslices -l kubernetes.io/service-name=backend` die Endpoints an; vergleiche die IPs mit `kubectl get pods -l tier=backend -o wide`.
3. Lade die Hello-Seite mehrmals neu und beobachte die Zeile **Backend**.
4. Prüfe den DNS-Namen aus einem Test-Pod: `kubectl run tmp --rm -it --image=busybox:1.37 --restart=Never -- nslookup backend`. Rufe danach mit `wget -qO- http://backend.hello.svc.cluster.local` (ebenfalls über `kubectl run tmp …`) das Backend über den vollständigen Namen auf.
5. Ändere im Selector von `backend-service.yaml` den Wert `tier: backend` in `tier: backnd`, wende die Datei an und prüfe EndpointSlice und Hello-Seite. Behebe den Fehler danach und wende die Datei erneut an.

## Checkpoint

- `kubectl get service backend` zeigt `TYPE ClusterIP` und `PORT(S) 80/TCP`.
- Die EndpointSlice listet drei IPs, dieselben wie die drei Backend-Pods.
- Die Hello-Seite zeigt `Backend: backend-… (10.1.0.…) um …`; der Pod-Name wechselt beim Neuladen, der Frontend-Pod bleibt gleich.
- `nslookup backend` antwortet mit `backend.hello.svc.cluster.local` und der ClusterIP.
- Mit falschem Selector zeigt die EndpointSlice `<unset>` und die Seite `Backend nicht erreichbar`; nach der Korrektur sind die drei IPs zurück.

## Abschlusskriterien

- `playground/k8s/backend-service.yaml` existiert mit Selector `app: hello` + `tier: backend` und Port 80 → 80.
- Die Hello-Seite zeigt Antworten von mindestens zwei verschiedenen Backend-Pods.

## Erweiterung

Beobachte in einem weiteren Terminal `kubectl get endpointslices -l kubernetes.io/service-name=backend -w` und skaliere das Backend mit `kubectl scale deployment backend --replicas=5` und zurück auf 3. Die Liste der Endpoints wächst und schrumpft mit.

## Fallback

- Port 8080 belegt: `kubectl port-forward deployment/frontend 8081:80` und `http://localhost:8081` öffnen.
- `busybox:1.37` lässt sich nicht laden (Docker-Hub-Limit, Proxy): DNS und Aufruf aus einem Frontend-Pod testen, dessen Image `nslookup` und `wget` enthält: `kubectl exec deploy/frontend -- nslookup backend` und `kubectl exec deploy/frontend -- wget -qO- http://backend`.
- Fertiger Stand zum Vergleich: [`project/examples/m05-services/l01-clusterip/`](../../project/examples/m05-services/l01-clusterip/)
