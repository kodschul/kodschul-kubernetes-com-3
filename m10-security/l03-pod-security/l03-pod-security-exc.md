# Lab 10.3 – Übung: Pod Security

**Dauer:** ca. 20 Minuten
**Ändert die Hello-App-Projektbasis?** Ja — `hello-prod` erzwingt Pod Security `restricted`; prod läuft mit den Images `*-v1-nonroot` auf Port 8080 und Chart `hello` 0.3.0 mit `securityContext`. dev und `hello` bleiben unverändert.

## Vorbereitung

- Terminal im Ordner `project/`; Docker Desktop läuft.
- Ausgangsstand: Release `hello` in `hello-prod` aus Lab 9.3 (v1, 3 Kopien), Chart 0.2.0 aus Lab 10.2 in `playground/hello/`. Wiederherstellen: `rm -rf playground/hello && cp -R examples/m10-security/l02-service-accounts/hello playground/hello`, danach Lab 9.3, Aufgabe 3 für prod.
- Starter: [`project/starters/m10-l03-hello/`](../../project/starters/m10-l03-hello/) (`Chart.yaml`, `values.yaml`, zwei Deployment-Templates) und [`project/starters/m10-l03-values-prod.yaml`](../../project/starters/m10-l03-values-prod.yaml) · Arbeitsdateien: `project/playground/hello/`, `project/playground/values-prod.yaml`, `project/playground/backend/Dockerfile.nonroot`, `project/playground/frontend/Dockerfile.nonroot`
- Vorlagen für die Dockerfiles (nicht ändern): [`project/examples/m10-security/l03-pod-security/backend/`](../../project/examples/m10-security/l03-pod-security/backend/), [`…/frontend/`](../../project/examples/m10-security/l03-pod-security/frontend/)

## Aufgaben

1. Setze `hello-prod` auf `restricted` mit `kubectl label namespace hello-prod pod-security.kubernetes.io/enforce=restricted` und lies die Warnungen. Erzwinge danach neue Pods mit `kubectl rollout restart deployment/hello-frontend -n hello-prod`, zeige `kubectl get rs,pods -n hello-prod` und lies die Ablehnung mit `kubectl get events -n hello-prod --field-selector reason=FailedCreate`.
2. Kopiere die Dockerfiles ohne root nach `playground/backend/Dockerfile.nonroot`, `playground/frontend/Dockerfile.nonroot` und `playground/frontend/Dockerfile.v2-nonroot`, vergleiche mit `diff playground/frontend/Dockerfile playground/frontend/Dockerfile.nonroot` und baue `hello-backend:v1-nonroot`, `hello-frontend:v1-nonroot` und `hello-frontend:v2-nonroot` (z. B. `docker build -t hello-backend:v1-nonroot -f playground/backend/Dockerfile.nonroot playground/backend`). Prüfe mit `docker run --rm hello-backend:v1-nonroot id`.
3. Kopiere den Chart-Starter über das eigene Chart (`cp -R starters/m10-l03-hello/. playground/hello/`) und `starters/m10-l03-values-prod.yaml` nach `playground/values-prod.yaml`. Ersetze alle `# TODO:` (Chart-Version, `securityContext` auf Pod- und Container-Ebene, Port, Tags, fehlende Sicherheitswerte) und prüfe mit `helm lint playground/hello -f playground/values-prod.yaml` und `helm template hello playground/hello -f playground/values-prod.yaml | grep -B2 -A14 "securityContext:"`.
4. Installiere prod neu, damit auch das Volume neu entsteht (das alte `access.log` gehört root): `helm uninstall hello -n hello-prod --wait`, warte, bis `kubectl get pvc -n hello-prod` `No resources found` meldet, dann `helm install hello playground/hello -n hello-prod -f playground/values-prod.yaml --wait --timeout 2m`. Prüfe `kubectl get pods -n hello-prod` und `http://prod.hello.localhost`.
5. Prüfe die Härtung im laufenden Frontend: `kubectl exec deploy/hello-frontend -n hello-prod -- id`, `kubectl exec deploy/hello-frontend -n hello-prod -- tail -n 3 /data/access.log` (nach zwei Aufrufen der Seite) und `kubectl exec deploy/hello-frontend -n hello-prod -- touch /app/test`.

## Checkpoint

- Aufgabe 1: neues ReplicaSet mit `DESIRED 1`, `CURRENT 0`; Event `violates PodSecurity "restricted:latest"`; die alten drei Frontend-Pods laufen weiter.
- Aufgabe 2: `uid=10001(hello) gid=10001(hello) groups=10001(hello)`.
- Aufgabe 3: `helm lint` ohne Fehler; im YAML stehen `runAsNonRoot: true`, `drop: - ALL`, `type: RuntimeDefault`, `containerPort: 8080`.
- Aufgabe 4: sechs Pods `Running`, keine Warnung bei `helm install`; die Seite zeigt „Hello-App v1" auf blauem Grund.
- Aufgabe 5: `uid=10001`, neue Zeilen im `access.log`, `touch: /app/test: Read-only file system`.

## Abschlusskriterien

- `kubectl get namespace hello-prod --show-labels` zeigt `pod-security.kubernetes.io/enforce=restricted`.
- `helm list -n hello-prod` zeigt `hello-0.3.0`, Status `deployed`.
- Die Hello-App in prod läuft als UID 10001 auf Port 8080 und schreibt nur nach `/data`.

## Erweiterung

Setze für `hello-dev` nur eine Warnung: `kubectl label namespace hello-dev pod-security.kubernetes.io/warn=restricted`, und starte `helm upgrade hello playground/hello -n hello-dev -f playground/values-dev.yaml`. Helm gibt die Warnungen aus, die Pods starten trotzdem.

## Fallback

- Images bauen schlägt fehl oder dauert zu lange: `bash build-images.sh` baut alle sechs Hello-Images aus den Beispielständen.
- Pods melden `PermissionError` für `access.log` (Speicher erlaubt UID 10001 nicht zu schreiben): `helm upgrade hello playground/hello -n hello-prod -f playground/values-prod.yaml --set persistence.enabled=false`; `/data` ist dann ein `emptyDir` und das Log geht beim Neustart verloren.
- Fertiger Stand: [`project/examples/m10-security/l03-pod-security/`](../../project/examples/m10-security/l03-pod-security/) (Dockerfiles, Chart `hello/` 0.3.0, `values-prod.yaml`).
