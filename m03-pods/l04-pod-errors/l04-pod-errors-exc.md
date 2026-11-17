# Lab 3.4 – Übung: Pod-Fehler lesen

**Dauer:** ca. 15 Minuten
**Ändert die Hello-App-Projektbasis?** Nein — die drei Fehler-Pods laufen neben der Hello-App und werden am Ende gelöscht.

## Vorbereitung

- Terminal im Ordner `project/`; Namespace `hello` ist Standard im Kontext.
- Fehlerbilder: [`project/variants/m03-l04-pod-errors/`](../../project/variants/m03-l04-pod-errors/) (`1-image-tag.yaml`, `2-crash.yaml`, `3-pending.yaml`)
- Arbeitsordner: `project/playground/pod-errors/` (Kopie der Fehlerbilder; die Originale bleiben unverändert)

## Aufgaben

1. Kopiere die Fehlerbilder mit `cp -r variants/m03-l04-pod-errors playground/pod-errors`, wende den Ordner mit `kubectl apply -f playground/pod-errors/` an und zeige nach etwa 30 Sekunden alle drei Pods mit `kubectl get pods -l lab=pod-errors`.
2. Finde für `fehler-image` den Grund in den Events von `kubectl describe`, korrigiere `1-image-tag.yaml` und wende die Datei erneut an.
3. Finde für `fehler-crash` die Fehlermeldung mit `kubectl logs --previous` und den Exit-Code in `describe`. Korrigiere `2-crash.yaml`, lösche den Pod und lege ihn neu an.
4. Zeige für `fehler-pending` die Events mit `kubectl events --for pod/fehler-pending`. Setze in `3-pending.yaml` den CPU-Request auf `100m` (0,1 CPU-Kern), lösche den Pod und lege ihn neu an.
5. Prüfe, dass alle drei Pods `Running` sind, und lösche sie danach mit `kubectl delete -f playground/pod-errors/`.

## Checkpoint

- Nach Aufgabe 1: `fehler-image` zeigt `ErrImageNeverPull`, `fehler-crash` `CrashLoopBackOff` (oder kurz `Error`) mit steigendem `RESTARTS`, `fehler-pending` `Pending`.
- Je Pod ist die Ursache in einem Satz benannt: fehlendes Image, falscher Dateiname im Startbefehl, zu hoher CPU-Request.
- Nach Aufgabe 4: `kubectl get pods -l lab=pod-errors` zeigt dreimal `Running`.

## Abschlusskriterien

- Alle drei Fehler sind in den Dateien unter `playground/pod-errors/` behoben.
- Nach Aufgabe 5 laufen im Namespace `hello` nur noch `backend` und `frontend`.

## Erweiterung

Starte einen Pod mit einem Tippfehler in einem öffentlichen Image: `kubectl run fehler-pull --image=ngnix:1.30-alpine`. Beobachte mit `kubectl get pod fehler-pull -w` den Wechsel zwischen `ErrImagePull` und `ImagePullBackOff`, lies die Events und lösche den Pod wieder.

## Fallback

- Pod nach der Korrektur weiter im Back-off: Pod löschen und neu anwenden.
- Lösungswege und erwartete Ausgaben: [`l04-pod-errors-sol.md`](l04-pod-errors-sol.md).
