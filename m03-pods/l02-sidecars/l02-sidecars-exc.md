# Lab 3.2 – Übung: Mehrere Container in einem Pod

**Dauer:** ca. 15 Minuten
**Ändert die Hello-App-Projektbasis?** Ja — der Frontend-Pod bekommt den Sidecar `log-reader` und das Volume `data`; Lab 3.3 ergänzt Labels.

## Vorbereitung

- Terminal im Ordner `project/`; Pods `backend` und `frontend` aus Lab 3.1 laufen (`kubectl get pods`).
- Starter: [`project/starters/m03-l02-frontend-pod.yaml`](../../project/starters/m03-l02-frontend-pod.yaml)
- Arbeitsdatei: `project/playground/k8s/frontend-pod.yaml` (wird ersetzt)
- Stand aus Lab 3.1 wiederherstellen (falls nötig): `kubectl apply -f examples/m03-pods/l01-first-pod/`, danach die Backend-IP in `frontend-pod.yaml` wie in Lab 3.1, Aufgabe 5 nachtragen.

## Aufgaben

1. Lies die aktuelle Backend-IP mit `kubectl get pod backend -o wide` ab. Kopiere den Starter nach `playground/k8s/frontend-pod.yaml`, trage die IP ein und ergänze die übrigen TODOs: `restartPolicy`, beide `volumeMounts` und das `emptyDir`-Volume `data`.
2. Lösche den alten Frontend-Pod, wende die neue Datei an und beobachte den Start mit `kubectl get pod frontend -w`, bis `READY 2/2` und `Running` erscheinen (Ende mit **Strg+C**).
3. Starte im zweiten Terminal `kubectl port-forward pod/frontend 8080:80` und lade `http://localhost:8080` mehrmals.
4. Zeige mit `kubectl logs frontend -c log-reader` die Zeilen des `access.log` an. Starte danach `kubectl logs -f frontend -c log-reader`, lade die Seite erneut und beobachte die neue Zeile.
5. Prüfe, dass beide Container dieselbe Datei sehen: `kubectl exec frontend -c frontend -- cat /data/access.log`. Zeige mit `kubectl describe pod frontend` den Abschnitt `Init Containers`.

## Checkpoint

- `kubectl get pod frontend` zeigt `READY 2/2`, `STATUS Running`.
- Jeder Seitenaufruf erzeugt im Sidecar-Log eine Zeile `<Zeit> frontend <IP> v1`.
- `describe` zeigt `log-reader` unter `Init Containers` mit `Restart Policy: Always` und `State: Running`.

## Abschlusskriterien

- `playground/k8s/frontend-pod.yaml` enthält `initContainers` mit `log-reader`, `restartPolicy: Always`, zwei `volumeMounts` auf `/data` und das Volume `data` vom Typ `emptyDir`.
- Die Hello-Seite zeigt weiter die Antwort des Backends.

## Erweiterung

Lösche den Frontend-Pod, lege ihn neu an und lies das Sidecar-Log erneut: Die alten Zeilen sind weg, weil ein `emptyDir` mit dem Pod gelöscht wird.

## Fallback

- `Init:ErrImagePull` oder `Init:ImagePullBackOff`: `busybox:1.37` ließ sich nicht laden (Netz oder Docker-Hub-Limit). `docker login` ausführen, `docker pull busybox:1.37`, Pod löschen und neu anwenden.
- Fertiger Stand zum Vergleich: [`project/examples/m03-pods/l02-sidecars/`](../../project/examples/m03-pods/l02-sidecars/) (Backend-IP ist ein Platzhalter).
