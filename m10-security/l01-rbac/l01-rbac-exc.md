# Lab 10.1 – Übung: RBAC

**Dauer:** ca. 20 Minuten
**Ändert die Hello-App-Projektbasis?** Ja — neue Datei `playground/k8s/rbac.yaml` mit Rollen in `hello-dev` und `hello-prod`; die Hello-Releases bleiben unverändert.

## Vorbereitung

- Terminal im Ordner `project/`.
- Starter: [`project/starters/m10-l01-rbac.yaml`](../../project/starters/m10-l01-rbac.yaml) · Arbeitsdatei: `project/playground/k8s/rbac.yaml`
- Ausgangsstand: Ende Lab 9.3 (Releases `hello` in `hello-dev` und `hello-prod`). Wiederherstellen: Aufgaben 2 und 3 aus Lab 9.3 mit den Dateien aus [`project/examples/m09-helm/l03-releases/`](../../project/examples/m09-helm/l03-releases/).

## Aufgaben

1. Zeige mit `kubectl auth whoami` den eigenen Benutzer und prüfe mit `kubectl auth can-i '*' '*'` die eigenen Rechte. Prüfe danach `kubectl auth can-i get pods -n hello-prod --as=ben`, bevor es Rollen gibt.
2. Kopiere den Starter nach `playground/k8s/rbac.yaml`, trage in der Role `viewer` nur lesende Verben ein und ergänze das RoleBinding `ben-viewer`. Wende die Datei an und zeige die neuen Objekte mit `kubectl get role,rolebinding -n hello-dev` und `kubectl get role,rolebinding -n hello-prod`.
3. Erstelle die Rechte-Matrix, indem jede Zeile einmal mit `--as=anna` und einmal mit `--as=ben` ausgeführt wird:
   - `kubectl auth can-i get pods -n hello-dev`
   - `kubectl auth can-i create deployments -n hello-dev`
   - `kubectl auth can-i delete deployments -n hello-dev`
   - `kubectl auth can-i get pods -n hello-prod`
   - `kubectl auth can-i delete pods -n hello-prod`
   - `kubectl auth can-i get secrets -n hello-prod`
   - `kubectl auth can-i list pods -n hello`
   - `kubectl auth can-i list nodes`
4. Liste alle Rechte von anna mit `kubectl auth can-i --list -n hello-dev --as=anna`. Skaliere als anna mit `kubectl scale deployment hello-frontend -n hello-dev --replicas=2 --as=anna` und danach zurück auf 1.
5. Teste als ben echte Befehle in prod: `kubectl get pods -n hello-prod --as=ben`, `kubectl delete deployment hello-frontend -n hello-prod --as=ben` und `kubectl get secret hello-secret -n hello-prod --as=ben`.

## Checkpoint

- Aufgabe 1: `can-i '*' '*'` antwortet `yes`, die Abfrage für ben `no`.
- Aufgabe 3: anna hat `yes` nur in `hello-dev`, ben nur bei `get pods` in `hello-prod`; bei Secrets, `hello`, Nodes antworten beide `no`.
- Aufgabe 5: `get pods` zeigt sechs Pods; `delete` und `get secret` enden mit `Error from server (Forbidden)`.

## Abschlusskriterien

- `playground/k8s/rbac.yaml` enthält zwei Roles und zwei RoleBindings, keine `# TODO:` mehr.
- Die Rechte-Matrix aus Aufgabe 3 stimmt mit der Lösung überein.
- `hello-frontend` in `hello-dev` hat wieder 1 Kopie.

## Erweiterung

Prüfe `helm list -n hello-dev --kube-as-user anna`. Helm liest seine Revisionen aus Secrets (Lab 9.1); ergänze die Role `deployer` um die Ressource `secrets`, wende die Datei an und wiederhole den Befehl.

## Fallback

Fertige Datei zum Vergleich und Anwenden: `kubectl apply -f examples/m10-security/l01-rbac/rbac.yaml`.
