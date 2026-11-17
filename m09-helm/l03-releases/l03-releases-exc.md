# Lab 9.3 – Übung: Releases verwalten

**Dauer:** ca. 15 Minuten
**Ändert die Hello-App-Projektbasis?** Ja — `hello-dev` und `hello-prod` laufen ab jetzt als Helm-Releases `hello` mit `values-dev.yaml` und `values-prod.yaml`; die Objekte aus Lab 6.3 werden dort gelöscht. Lab 10.3 baut auf `hello-prod` auf.

## Vorbereitung

- Terminal im Ordner `project/`.
- Chart aus Lab 9.2 in `playground/hello/`. Wiederherstellen: `rm -rf playground/hello && cp -R examples/m09-helm/l02-own-chart/hello playground/hello`.
- Starter: [`project/starters/m09-l03-values-dev.yaml`](../../project/starters/m09-l03-values-dev.yaml) und [`project/starters/m09-l03-values-prod.yaml`](../../project/starters/m09-l03-values-prod.yaml) · Arbeitsdateien: `project/playground/values-dev.yaml`, `project/playground/values-prod.yaml`
- Namespaces `hello-dev` und `hello-prod` aus Lab 6.3. Fehlen sie: `kubectl apply -f examples/m06-configuration/l03-environments/namespaces.yaml`.

## Aufgaben

1. Kopiere beide Starter nach `playground/values-dev.yaml` und `playground/values-prod.yaml` und ersetze die `# TODO:`-Werte: dev mit Host `dev.hello.localhost`, Farbe `lightgreen`, je 1 Kopie, Frontend-Tag `v1`; prod mit Host `prod.hello.localhost`, Farbe `lightblue`, je 3 Kopien, Frontend-Tag `v1`. Prüfe beide mit `helm template hello playground/hello -f playground/values-prod.yaml | grep -E "replicas:|image:|APP_COLOR|localhost"`.
2. Räume die Objekte aus Lab 6.3 in beiden Namespaces ab und stelle sicher, dass das Secret vorhanden ist:

   ```bash
   kubectl delete -n hello-dev deployment/backend deployment/frontend service/backend service/frontend \
     configmap/hello-config --ignore-not-found
   kubectl delete -n hello-prod deployment/backend deployment/frontend service/backend service/frontend \
     configmap/hello-config --ignore-not-found
   kubectl apply -n hello-dev -f examples/m06-configuration/l03-environments/secret.yaml
   kubectl apply -n hello-prod -f examples/m06-configuration/l03-environments/secret.yaml
   ```

3. Installiere beide Umgebungen mit `helm upgrade --install hello playground/hello -n hello-dev -f playground/values-dev.yaml` und demselben Befehl für `hello-prod` mit `values-prod.yaml`. Prüfe `helm list -A` und öffne `http://dev.hello.localhost` und `http://prod.hello.localhost`.
4. Hebe prod auf v2: `helm upgrade hello playground/hello -n hello-prod -f playground/values-prod.yaml --set frontend.image.tag=v2 --rollback-on-failure --timeout 90s`. Lade `http://prod.hello.localhost` neu. Starte danach absichtlich ein fehlerhaftes Upgrade mit dem nicht vorhandenen Tag `v3` und `--timeout 60s` (sonst gleich), beobachte in einem zweiten Terminal `kubectl get pods -n hello-prod -w` und lies danach `helm history hello -n hello-prod`.
5. Rolle prod mit `helm rollback hello 1 -n hello-prod` auf die erste Revision zurück, lies erneut `helm history hello -n hello-prod`, vergleiche `helm get values hello -n hello-prod --revision 2` mit `--revision 5` und lade die Seite neu.

## Checkpoint

- Nach Aufgabe 3: `helm list -A` zeigt `hello` in `hello`, `hello-dev` und `hello-prod`; dev ist grün mit „Hello-App v1", prod blau mit „Hello-App v1".
- Nach Aufgabe 4: prod zeigt „Hello-App v2"; das `v3`-Upgrade endet nach etwa 60 Sekunden mit einem Fehler, die v2-Pods laufen ohne Unterbrechung weiter.
- Nach Aufgabe 5: `helm history` zeigt fünf Revisionen, die letzte mit `Rollback to 1`; prod zeigt wieder „Hello-App v1".

## Abschlusskriterien

- `helm history hello -n hello-prod` zeigt Installation, Upgrade, fehlgeschlagenes Upgrade und zwei Rollbacks.
- `kubectl get pods -n hello-prod` zeigt 3 Frontend- und 3 Backend-Pods `Running`, alle mit Image-Tag `v1`.
- `playground/values-dev.yaml` und `playground/values-prod.yaml` enthalten keine `# TODO:` mehr.

## Erweiterung

Verpacke das Chart mit `helm package playground/hello -d playground/` und sieh den Inhalt mit `tar -tzf playground/hello-0.1.0.tgz` an. Das Hochladen mit `helm push` braucht ein Registry-Konto und bleibt Theorie.

## Fallback

- `*.localhost` löst nicht auf: `curl -H "Host: prod.hello.localhost" http://localhost/` oder `kubectl port-forward -n hello-prod svc/hello-frontend 8082:80` und `http://localhost:8082`.
- Release hängt im Status `pending-upgrade` (Befehl abgebrochen): `helm rollback hello <letzte Revision mit deployed> -n hello-prod`.
- Fertiger Stand zum Vergleich: [`project/examples/m09-helm/l03-releases/`](../../project/examples/m09-helm/l03-releases/) (Chart `hello/`, `values-dev.yaml`, `values-prod.yaml`).
