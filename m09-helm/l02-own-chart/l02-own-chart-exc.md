# Lab 9.2 – Übung: Eigenes Chart für die Hello-App

**Dauer:** ca. 25 Minuten
**Ändert die Hello-App-Projektbasis?** Ja — die Hello-App im Namespace `hello` läuft ab jetzt als Helm-Release `hello` aus dem Chart `playground/hello/`; die Objekte aus `playground/k8s/` werden gelöscht (Secret und Gateway bleiben).

## Vorbereitung

- Terminal im Ordner `project/`.
- Starter: [`project/starters/m09-l02-hello/`](../../project/starters/m09-l02-hello/) (ganzes Chart, feste Werte mit `# TODO:` markiert) · Arbeitsordner: `project/playground/hello/`
- Ausgangsstand: Ende Lab 8.3 (Hello-App aus `playground/k8s/` im Namespace `hello`, Gateway `hello-gateway` im Namespace `gateway`, Secret `hello-secret`). Wiederherstellen: `kubectl apply -f examples/m08-health-resources/l03-autoscaling/`.

## Aufgaben

1. Kopiere den Starter mit `cp -R starters/m09-l02-hello playground/hello`, sieh den Aufbau mit `ls -R playground/hello` an und rendere das Chart einmal unverändert: `helm lint playground/hello` und `helm template hello playground/hello -n hello | head -40`.
2. Ergänze in `playground/hello/values.yaml` die Werte `color: lightyellow` und `host: hello.localhost`. Ersetze danach in `backend-deployment.yaml`, `frontend-deployment.yaml`, `configmap.yaml` und `httproute.yaml` jede mit `# TODO:` markierte feste Angabe durch den passenden `.Values`-Ausdruck (für den Frontend-Tag mit `default .Chart.AppVersion`, für Text mit `| quote`) und entferne die TODO-Kommentare.
3. Prüfe das Chart: `helm lint playground/hello`, dann rendere es mit `helm template hello playground/hello -n hello --set color=pink --set frontend.image.tag=v1` und filtere mit `grep -E "image:|replicas:|APP_COLOR|localhost"`. Die gesetzten Werte müssen an der richtigen Stelle erscheinen.
4. Lösche die App aus `playground/k8s/`, aber nicht Namespace, Secret und Gateway:

   ```bash
   kubectl delete -n hello deployment/backend deployment/frontend service/backend service/frontend \
     configmap/hello-config pvc/hello-data cronjob/hello-backup hpa/frontend httproute/hello \
     --ignore-not-found
   kubectl delete pod load -n hello --ignore-not-found
   ```

   Prüfe mit `kubectl get all,configmap,pvc,httproute -n hello` und `kubectl get secret hello-secret -n hello`.
5. Teste die Installation mit `helm install hello playground/hello -n hello --dry-run=server | tail -15`, installiere danach ohne `--dry-run`, und prüfe `helm list -n hello`, `kubectl get pods,svc,httproute -n hello` sowie `http://hello.localhost` und `http://hello.localhost/api` im Browser.

## Checkpoint

- `helm lint` meldet `1 chart(s) linted, 0 chart(s) failed`.
- Aufgabe 3 zeigt `APP_COLOR: "pink"`, `image: "hello-frontend:v1"` und `- "hello.localhost"`.
- Nach Aufgabe 4: nur noch `kube-root-ca.crt` als ConfigMap und das Secret `hello-secret`.
- Nach Aufgabe 5: `helm list -n hello` zeigt `hello`, `REVISION 1`, `deployed`, `hello-0.1.0`, `APP VERSION v2`; vier Pods `Running`.

## Abschlusskriterien

- `playground/hello/` enthält keine `# TODO:` mehr (`grep -rn TODO playground/hello` liefert nichts).
- `http://hello.localhost` zeigt „Hello-App v2" auf hellgelbem Hintergrund, Backend-Antwort und „Passwort gesetzt".
- Alle Hello-Objekte tragen das Label `app.kubernetes.io/managed-by=Helm` (`kubectl get deploy,svc -n hello --show-labels`).

## Erweiterung

Ergänze das Chart um den HPA aus Lab 8.3: Datei `templates/hpa.yaml` mit dem Inhalt aus `playground/k8s/`, Name `{{ .Release.Name }}-frontend`, Ziel `scaleTargetRef.name: {{ .Release.Name }}-frontend`, ein- und ausschaltbar mit `{{- if .Values.autoscaling.enabled }}` und dem neuen Wert `autoscaling.enabled: false` in `values.yaml`. Prüfe mit `helm template … --set autoscaling.enabled=true`.

## Fallback

- Chart lässt sich nicht reparieren: Beispielstand verwenden, `rm -rf playground/hello && cp -R examples/m09-helm/l02-own-chart/hello playground/hello`.
- `hello.localhost` löst nicht auf (z. B. Safari): `curl -H "Host: hello.localhost" http://localhost/` oder `kubectl port-forward -n hello svc/hello-frontend 8080:80`.
