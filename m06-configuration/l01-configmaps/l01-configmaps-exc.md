# Lab 6.1 – Übung: ConfigMaps

**Dauer:** ca. 20 Minuten
**Ändert die Hello-App-Projektbasis?** Ja — neue ConfigMap `hello-config`; das Frontend liest `BACKEND_URL` und `APP_COLOR` daraus. Lab 6.2 ergänzt ein Secret.

## Vorbereitung

- Terminal im Ordner `project/`; `http://hello.localhost` zeigt die grüne Seite „Hello-App v2".
- Starter: [`project/starters/m06-l01-configmap.yaml`](../../project/starters/m06-l01-configmap.yaml), [`project/starters/m06-l01-frontend-deployment.yaml`](../../project/starters/m06-l01-frontend-deployment.yaml)
- Arbeitsdateien: `project/playground/k8s/configmap.yaml`, `project/playground/k8s/frontend-deployment.yaml` (wird ersetzt)
- Stand aus Lab 5.3 wiederherstellen (falls nötig, Envoy Gateway muss installiert sein): `kubectl apply -f examples/m05-services/l03-gateway-api/`

## Aufgaben

1. Kopiere den ConfigMap-Starter nach `playground/k8s/configmap.yaml`, trage `BACKEND_URL` und `APP_COLOR` ein und wende die Datei an. Prüfe das Ergebnis mit `kubectl describe configmap hello-config`.
2. Kopiere den Deployment-Starter nach `playground/k8s/frontend-deployment.yaml`, ergänze `envFrom` mit der ConfigMap `hello-config` und wende die Datei an. Warte mit `kubectl rollout status deployment/frontend` und lade `http://hello.localhost` neu.
3. Zeige die Umgebungsvariablen eines Frontend-Pods: `kubectl exec deploy/frontend -- env | grep -E '^(APP_|BACKEND_URL)'`.
4. Ändere in `configmap.yaml` den Wert von `APP_COLOR` auf `lightpink`, wende die Datei an und lade die Seite neu. Prüfe die Variable erneut wie in Aufgabe 3.
5. Übernimm die neue Farbe mit `kubectl rollout restart deployment/frontend`, warte mit `kubectl rollout status deployment/frontend` und lade die Seite neu.

## Checkpoint

- Nach Aufgabe 2 ist die Seite hellgelb und zeigt weiter „Hello-App v2" mit Backend-Antwort.
- Aufgabe 3 zeigt `APP_COLOR=lightyellow`, `APP_VERSION=v2` und `BACKEND_URL=http://backend`.
- Nach Aufgabe 4 bleibt die Seite gelb, `env` zeigt weiter `lightyellow`.
- Nach Aufgabe 5 ist die Seite rosa; die Pod-Namen sind neu.

## Abschlusskriterien

- `playground/k8s/frontend-deployment.yaml` enthält kein `env` mit `BACKEND_URL` mehr, sondern `envFrom` mit `hello-config`.
- Die Farbe der Hello-Seite stammt aus der ConfigMap; das Image ist unverändert `hello-frontend:v2`.

## Erweiterung

Lege die ConfigMap `hello-files` mit dem Schlüssel `config.json` aus der Theorie an und binde sie zusätzlich als Volume unter `/etc/hello-config` ins Frontend ein. Prüfe mit `kubectl exec deploy/frontend -- cat /etc/hello-config/config.json`, ändere danach den Inhalt in der ConfigMap und wiederhole den Befehl nach etwa einer Minute, ohne Neustart.

## Fallback

- Pods hängen in `CreateContainerConfigError`: `kubectl describe pod -l tier=frontend` lesen; meist ist der Name der ConfigMap falsch geschrieben.
- `hello.localhost` nicht erreichbar: `kubectl port-forward deployment/frontend 8080:80` und `http://localhost:8080` öffnen.
- Fertiger Stand zum Vergleich: [`project/examples/m06-configuration/l01-configmaps/`](../../project/examples/m06-configuration/l01-configmaps/) (Farbe dort `lightyellow`).
