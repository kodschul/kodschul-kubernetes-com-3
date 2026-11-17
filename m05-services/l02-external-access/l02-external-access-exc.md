# Lab 5.2 – Übung: NodePort, LoadBalancer und Port-Forward

**Dauer:** ca. 12 Minuten
**Ändert die Hello-App-Projektbasis?** Ja — neuer Service `frontend` vom Typ `LoadBalancer` auf `localhost:8080`. Lab 5.3 stellt ihn auf `ClusterIP` zurück, weil dann das Gateway den Zugang übernimmt.

## Vorbereitung

- Terminal im Ordner `project/`; das Port-Forward aus Lab 5.1 mit Strg+C beenden (es belegt Port 8080).
- Starter: [`project/starters/m05-l02-frontend-service.yaml`](../../project/starters/m05-l02-frontend-service.yaml)
- Arbeitsdatei: `project/playground/k8s/frontend-service.yaml`
- Stand aus Lab 5.1 wiederherstellen (falls nötig): `kubectl apply -f examples/m05-services/l01-clusterip/`

## Aufgaben

1. Kopiere den Starter nach `playground/k8s/frontend-service.yaml`, ergänze den Selector und wende die Datei an (noch `type: NodePort`). Lies mit `kubectl get service frontend` den vergebenen NodePort aus der Spalte `PORT(S)` ab.
2. Öffne `http://localhost:<NodePort>` und lade die Seite mehrmals neu. Beobachte die Zeilen **Frontend-Pod** und **Backend**.
3. Stelle `type` auf `LoadBalancer` um, wende die Datei erneut an und prüfe mit `kubectl get service frontend` die Spalten `EXTERNAL-IP` und `PORT(S)`. Öffne `http://localhost:8080`.
4. Starte in einem zweiten Terminal `kubectl port-forward service/frontend 9090:8080`, öffne `http://localhost:9090` und lade mehrmals neu. Beende das Port-Forward danach mit Strg+C.

## Checkpoint

- Nach Aufgabe 1 zeigt `kubectl get service frontend` `TYPE NodePort`, `EXTERNAL-IP <none>` und `PORT(S) 8080:3xxxx/TCP`.
- Über NodePort und LoadBalancer wechselt beim Neuladen der Frontend-Pod, über Port-Forward bleibt er gleich.
- Nach Aufgabe 3: `TYPE LoadBalancer`, `EXTERNAL-IP localhost`; der NodePort ist derselbe wie vorher.
- `http://localhost:8080` zeigt die grüne Seite „Hello-App v2" mit Backend-Antwort.

## Abschlusskriterien

- `playground/k8s/frontend-service.yaml` hat `type: LoadBalancer`, Port 8080 → 80 und den Selector `app: hello` + `tier: frontend`.
- Die Hello-Seite ist unter `http://localhost:8080` erreichbar.

## Fallback

- `localhost:<NodePort>` lädt nicht (je nach Docker-Desktop-Version): Aufgabe 2 überspringen, Aufgabe 3 und 4 zeigen dasselbe Prinzip.
- `EXTERNAL-IP` bleibt `<pending>`: prüfen, ob noch ein Port-Forward auf 8080 läuft; bei minikube in einem zweiten Terminal `minikube tunnel` starten.
- Fertiger Stand zum Vergleich: [`project/examples/m05-services/l02-external-access/`](../../project/examples/m05-services/l02-external-access/)
