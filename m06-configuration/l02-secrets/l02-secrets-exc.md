# Lab 6.2 – Übung: Secrets

**Dauer:** ca. 20 Minuten
**Ändert die Hello-App-Projektbasis?** Ja — neues Secret `hello-secret`, im Frontend als Datei unter `/etc/hello-secret` eingebunden. Lab 6.3 nutzt dieselben Manifeste in zwei weiteren Namespaces.

## Vorbereitung

- Terminal im Ordner `project/`; `http://hello.localhost` zeigt unter **Admin** `kein Passwort gesetzt`.
- Starter: [`project/starters/m06-l02-frontend-deployment.yaml`](../../project/starters/m06-l02-frontend-deployment.yaml)
- Arbeitsdatei: `project/playground/k8s/frontend-deployment.yaml` (wird ersetzt)
- Stand aus Lab 6.1 wiederherstellen (falls nötig): `kubectl apply -f examples/m06-configuration/l01-configmaps/`
- `uebung-2026` ist ein Übungswert. Echte Passwörter nie in eine Datei schreiben, die in ein Repository gelangt.

## Aufgaben

1. Lege das Secret per Befehl an: `kubectl create secret generic hello-secret --from-literal=admin-password=uebung-2026`. Zeige es mit `kubectl get secret hello-secret` und `kubectl describe secret hello-secret` an.
2. Lies den gespeicherten Wert mit `kubectl get secret hello-secret -o yaml` und wandle ihn mit `kubectl get secret hello-secret -o jsonpath='{.data.admin-password}' | base64 -d` in Klartext zurück.
3. Kopiere den Starter nach `playground/k8s/frontend-deployment.yaml`, ergänze `mountPath` und `secretName` und wende die Datei an. Warte mit `kubectl rollout status deployment/frontend` und lade `http://hello.localhost` neu.
4. Sieh in einem Frontend-Pod nach, was die App sieht: `kubectl exec deploy/frontend -- ls -l /etc/hello-secret/` und `kubectl exec deploy/frontend -- cat /etc/hello-secret/admin-password`.
5. Prüfe, dass der Wert nicht als Umgebungsvariable vorliegt: `kubectl exec deploy/frontend -- env | grep -i password` liefert keine Zeile.

## Checkpoint

- `kubectl get secret hello-secret` zeigt `TYPE Opaque` und `DATA 1`; `describe` zeigt `admin-password: 11 bytes`, nicht den Wert.
- `-o yaml` zeigt `admin-password: dWVidW5nLTIwMjY=`; `base64 -d` liefert `uebung-2026`.
- Die Hello-Seite zeigt unter **Admin** `Passwort gesetzt`, Farbe aus Lab 6.1.
- `ls -l` zeigt `admin-password` als Verknüpfung in einen versteckten Ordner `..data`; `cat` zeigt `uebung-2026`.

## Abschlusskriterien

- Das Frontend-Deployment bindet `hello-secret` schreibgeschützt unter `/etc/hello-secret` ein.
- Kein Passwort steht in einer Datei unter `playground/k8s/`.

## Erweiterung

Ändere das Passwort, ohne das Secret zu löschen: `kubectl create secret generic hello-secret --from-literal=admin-password=neu-2026 --dry-run=client -o yaml | kubectl apply -f -`. Wiederhole den `cat`-Befehl aus Aufgabe 4 so lange (etwa eine Minute), bis der neue Wert ohne Neustart der Pods erscheint.

## Fallback

- Pods hängen in `ContainerCreating`: `kubectl describe pod -l tier=frontend` lesen; meist fehlt das Secret oder `secretName` ist falsch geschrieben.
- Das Secret lässt sich auch aus der Datei des Beispiels anlegen: `kubectl apply -f examples/m06-configuration/l02-secrets/secret.yaml` (Übungswert).
- Fertiger Stand zum Vergleich: [`project/examples/m06-configuration/l02-secrets/`](../../project/examples/m06-configuration/l02-secrets/)
