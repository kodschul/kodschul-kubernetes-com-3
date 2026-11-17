# Lab 4.3 – Übung: Rollout und Rollback

**Dauer:** ca. 20 Minuten
**Ändert die Hello-App-Projektbasis?** Ja — das Frontend-Deployment läuft auf `v2` mit Strategie `RollingUpdate` (`maxSurge 1`, `maxUnavailable 0`) und `change-cause`; Modul 5 baut darauf auf.

## Vorbereitung

- Terminal im Ordner `project/`; Deployments `backend` und `frontend` aus Lab 4.2 mit je drei Pods laufen. Images `hello-frontend:v1` und `hello-frontend:v2` sind lokal vorhanden; `hello-frontend:v3` gibt es absichtlich nicht.
- Starter: [`project/starters/m04-l03-frontend-deployment.yaml`](../../project/starters/m04-l03-frontend-deployment.yaml)
- Arbeitsdatei: `project/playground/k8s/frontend-deployment.yaml` (wird ersetzt)
- Stand aus Lab 4.2 wiederherstellen (falls nötig): `kubectl apply -f examples/m04-deployments/l02-deployments/`

## Aufgaben

1. Kopiere den Starter nach `playground/k8s/frontend-deployment.yaml`, ergänze die Annotation `kubernetes.io/change-cause: "Start mit v1"` und die Strategie und wende die Datei an. Zeige die Historie mit `kubectl rollout history deployment/frontend`.
2. Starte im zweiten Terminal `kubectl get pods -l tier=frontend -w`. Ändere in der Datei Image und Label `version` auf `v2` und `change-cause` auf `"Update auf v2"`, wende sie an und verfolge den Rollout mit `kubectl rollout status deployment/frontend`. Zeige danach `kubectl get rs`.
3. Öffne die Seite mit `kubectl port-forward deployment/frontend 8080:80` unter `http://localhost:8080`.
4. Rolle absichtlich `v3` aus (Image, Label `version` und `change-cause` `"Update auf v3"`). Prüfe mit `kubectl rollout status deployment/frontend --timeout=30s`, `kubectl get pods` und `kubectl describe` des neuen Pods, was passiert, und lade die Seite neu.
5. Rolle mit `kubectl rollout undo deployment/frontend` zurück, zeige die Historie und setze die Datei wieder auf `v2` mit `change-cause` `"Update auf v2"`. Wende die Datei an und prüfe, dass kein neuer Rollout startet.

## Checkpoint

- Nach Aufgabe 2 zeigt das Watch-Terminal, dass immer erst ein neuer Pod `Running` ist, bevor ein alter `Terminating` wird; `kubectl get rs` zeigt das alte ReplicaSet mit `DESIRED 0`.
- Die Seite ist hellgrün und zeigt „Hello-App v2".
- In Aufgabe 4 hat ein neuer Pod `ErrImageNeverPull`, drei `v2`-Pods laufen weiter, die Seite bleibt erreichbar.
- Nach Aufgabe 5 zeigt `rollout history` die Revisionen `1`, `3`, `4` mit `Start mit v1`, `Update auf v3`, `Update auf v2`.

## Abschlusskriterien

- `playground/k8s/frontend-deployment.yaml` enthält `image: hello-frontend:v2`, `version: v2`, `change-cause` `"Update auf v2"` und die Strategie `RollingUpdate` mit `maxSurge: 1`, `maxUnavailable: 0`.
- `kubectl get deploy frontend` zeigt `READY 3/3`, alle Frontend-Pods laufen mit `hello-frontend:v2`.

## Erweiterung

Stelle in einer Kopie der Datei die Strategie auf `type: Recreate` (ohne `rollingUpdate`-Block), rolle `v1` aus und beobachte im Watch-Terminal, dass zuerst alle Pods enden. Danach mit der eigentlichen Datei wieder `v2` anwenden.

## Fallback

- Port-Forward bricht beim Rollout ab: neu starten, sobald `rollout status` fertig meldet.
- Fertiger Stand: [`project/examples/m04-deployments/l03-rollouts/`](../../project/examples/m04-deployments/l03-rollouts/) (die Historie entsteht dabei neu und hat nur eine Revision).
