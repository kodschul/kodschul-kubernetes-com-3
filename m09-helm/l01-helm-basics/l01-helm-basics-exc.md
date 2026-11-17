# Lab 9.1 – Übung: Helm-Grundlagen

**Dauer:** ca. 15 Minuten
**Ändert die Hello-App-Projektbasis?** Nein — podinfo läuft im eigenen Namespace `podinfo` und wird am Ende wieder entfernt; die Hello-App bleibt unverändert.

## Vorbereitung

- Terminal im Ordner `project/` öffnen (macOS/Linux: Terminal, Windows: Git Bash).
- Arbeitsdatei: `project/playground/podinfo-values.yaml` (neu, kein Starter).
- Internetzugang zu `ghcr.io` (Chart und Image von podinfo).

## Aufgaben

1. Prüfe die Helm-Version mit `helm version` und lies den Steckbrief und die Standardwerte des Charts:
   `helm show chart oci://ghcr.io/stefanprodan/charts/podinfo --version 6.17.0` und
   `helm show values oci://ghcr.io/stefanprodan/charts/podinfo --version 6.17.0 | head -40`.
2. Installiere das Chart als Release `podinfo` im neuen Namespace `podinfo` (`--create-namespace`) und mit `--set ui.message="Hallo aus Helm"`. Zeige das Release mit `helm list -n podinfo` und die erzeugten Objekte mit `kubectl get all -n podinfo`.
3. Öffne die Seite: starte in einem zweiten Terminal `kubectl port-forward -n podinfo svc/podinfo 9898:9898` und rufe `http://localhost:9898` im Browser auf.
4. Lege `playground/podinfo-values.yaml` an mit `replicaCount: 2`, einer eigenen `ui.message` und einer eigenen `ui.color`. Aktualisiere das Release mit `helm upgrade … -f playground/podinfo-values.yaml`, prüfe `helm get values podinfo -n podinfo` und `helm list -n podinfo`, starte den `port-forward` neu und lade die Seite neu.
5. Entferne das Release mit `helm uninstall podinfo -n podinfo`, prüfe mit `kubectl get all -n podinfo`, dass nichts übrig ist, und lösche danach den Namespace `podinfo`.

## Checkpoint

- `helm version` zeigt `v4.`.
- Nach Aufgabe 2: `helm list -n podinfo` zeigt `podinfo` mit `REVISION 1`, `STATUS deployed`, `CHART podinfo-6.17.0`.
- Nach Aufgabe 3: Die Seite zeigt „Hallo aus Helm".
- Nach Aufgabe 4: zwei Pods, neue Farbe und Nachricht, `REVISION 2`; `helm get values` zeigt nur die Werte aus der Datei.

## Abschlusskriterien

- Ein Release wurde installiert, über Werte geändert und vollständig entfernt.
- `helm list -n podinfo` ist leer, der Namespace `podinfo` existiert nicht mehr.

## Erweiterung

Zeige mit `kubectl get secrets -n podinfo` vor dem Deinstallieren die Secrets `sh.helm.release.v1.podinfo.v1` und `…v2`, in denen Helm die Revisionen speichert.

## Fallback

- `ghcr.io` gesperrt, GitHub Pages erreichbar: klassisches Repository nutzen, `helm repo add podinfo https://stefanprodan.github.io/podinfo`, danach überall `podinfo/podinfo --version 6.17.0` statt der `oci://`-Adresse.
- Kein Internet: ein lokales Beispiel-Chart erzeugen, `helm create demo` im Ordner `playground/`, dann `helm install demo playground/demo -n podinfo --create-namespace` und dieselben Befehle mit `--set replicaCount=2`. Einschränkung: das Beispiel-Chart nutzt das Image `nginx` von Docker Hub; ohne Image im lokalen Cache startet der Pod nicht, `helm list` und `helm get values` funktionieren trotzdem.
