# Lab 5.3 – Übung: HTTP-Routing mit der Gateway API

**Dauer:** ca. 25 Minuten
**Ändert die Hello-App-Projektbasis?** Ja — Envoy Gateway im Cluster, Gateway `hello-gateway` im Namespace `gateway`, HTTPRoute `hello`; der Service `frontend` ist wieder `ClusterIP`. Ab jetzt ist die Hello-App unter `http://hello.localhost` erreichbar.

## Vorbereitung

- Terminal im Ordner `project/`; alle Port-Forwards beenden. Port 80 auf dem Laptop muss frei sein: `docker ps` zeigt keinen Container mit `0.0.0.0:80->`.
- Browser: Chrome, Edge oder Firefox (Safari löst `hello.localhost` nicht immer auf).
- Starter: [`project/starters/m05-l03-gateway.yaml`](../../project/starters/m05-l03-gateway.yaml), [`project/starters/m05-l03-httproute.yaml`](../../project/starters/m05-l03-httproute.yaml)
- Arbeitsdateien: `project/playground/k8s/gateway.yaml`, `project/playground/k8s/httproute.yaml`, `project/playground/k8s/frontend-service.yaml`
- Stand aus Lab 5.2 wiederherstellen (falls nötig): `kubectl apply -f examples/m05-services/l02-external-access/`

## Aufgaben

1. Installiere Envoy Gateway v1.10.0 mit den beiden Befehlen aus der Theorie (`kubectl apply --server-side …` und `kubectl wait …`) und prüfe mit `kubectl get pods -n envoy-gateway-system`, dass der Pod `envoy-gateway-…` läuft.
2. Stelle in `playground/k8s/frontend-service.yaml` den Service auf `type: ClusterIP` mit `port: 80` und `targetPort: 80` um und wende die Datei an.
3. Kopiere den Gateway-Starter nach `playground/k8s/gateway.yaml`, ergänze die TODOs und wende die Datei an. Prüfe `kubectl get gatewayclass`, `kubectl get gateway -n gateway` und `kubectl get service -n envoy-gateway-system`.
4. Kopiere den HTTPRoute-Starter nach `playground/k8s/httproute.yaml`, ergänze Hostname und Frontend-Service, wende die Datei an und öffne `http://hello.localhost`.
5. Ergänze in `httproute.yaml` eine zweite Regel: Pfad `/api` (`PathPrefix`) zum Service `backend`, Port 80. Wende die Datei an, öffne `http://hello.localhost/api` und rufe dieselbe Adresse mehrmals mit `curl http://hello.localhost/api` auf.

## Checkpoint

- `kubectl get service frontend` zeigt `TYPE ClusterIP`, `PORT(S) 80/TCP`; `http://localhost:8080` antwortet nicht mehr.
- GatewayClass `eg`: `ACCEPTED True`; Gateway `hello-gateway`: `PROGRAMMED True`, `ADDRESS localhost`.
- In `envoy-gateway-system` gibt es einen Service `envoy-gateway-hello-gateway-…` vom Typ `LoadBalancer` mit `EXTERNAL-IP localhost` und Port `80`.
- `http://hello.localhost` zeigt die grüne Seite „Hello-App v2" mit Backend-Antwort.
- `curl http://hello.localhost/api` liefert JSON; `pod` wechselt zwischen den drei Backend-Pods.

## Abschlusskriterien

- `kubectl describe httproute hello` zeigt `Accepted True` und `ResolvedRefs True`.
- `http://hello.localhost` und `http://hello.localhost/api` antworten.

## Erweiterung

Rufe `curl -i http://hello.localhost/gibt-es-nicht` und `curl -i http://localhost/` auf. Der erste Aufruf landet beim Frontend (Regel `/`), der zweite liefert `404`, weil keine Route den Hostnamen `localhost` kennt.

## Fallback

- Port 80 belegt und nicht frei zu bekommen: den Envoy-Service per Port-Forward erreichen (Name aus Aufgabe 3):
  `kubectl -n envoy-gateway-system port-forward service/envoy-gateway-hello-gateway-<hash> 8888:80`
  und in einem zweiten Terminal `curl -H "Host: hello.localhost" http://localhost:8888/` sowie `…/api`.
- `install.yaml` lässt sich nicht von GitHub laden (Proxy): Datei im Browser herunterladen und mit `kubectl apply --server-side -f <Pfad>/install.yaml` anwenden.
- Fertiger Stand zum Vergleich: [`project/examples/m05-services/l03-gateway-api/`](../../project/examples/m05-services/l03-gateway-api/) (Envoy Gateway muss vorher installiert sein).
