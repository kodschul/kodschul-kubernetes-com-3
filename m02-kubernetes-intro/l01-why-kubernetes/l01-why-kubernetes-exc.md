# Lab 2.1 – Übung: Warum Kubernetes?

**Dauer:** ca. 10 Minuten (Demo im Plenum)
**Ändert die Hello-App-Projektbasis?** Nein — die Demo läuft im Cluster der Kursleitung; das Nachspielen (Erweiterung) räumt am Ende alles wieder ab.

## Vorbereitung

- Diese Übung ist eine Demo: Die Kursleitung zeigt sie live, ein eigener Cluster ist dafür noch nicht nötig (er entsteht in Lab 2.2).
- Die Demo nutzt das Image `hello-backend:v1` aus Lab 1.3. Es antwortet mit JSON, das den Namen und die IP der antwortenden Kopie enthält.

## Aufgaben

1. Beobachte, wie mit einem Befehl drei Kopien (Replikas) von `hello-backend:v1` im Cluster entstehen und `kubectl get pods -o wide` sie mit Namen, Status `Running` und je eigener IP auflistet.
2. Beobachte die Antworten unter einer gemeinsamen Adresse: Mehrere Aufrufe hintereinander liefern unterschiedliche Namen und IPs in `"pod"` und `"ip"`.
3. Beobachte, was nach dem Löschen einer Kopie passiert: `kubectl get pods -o wide -w` zeigt die gelöschte Kopie als `Terminating` und fast gleichzeitig eine neue mit anderem Namen und anderer IP.
4. Vergleiche die Anzahl vor und nach dem Löschen: Es laufen wieder genau drei Kopien, ohne dass jemand einen Startbefehl gegeben hat.

## Checkpoint

- Nach dem Löschen laufen wieder drei Kopien mit Status `Running`.
- Eine der drei hat einen neuen Namen, ein `AGE` von wenigen Sekunden und eine neue IP.
- Die Antworten unter der gemeinsamen Adresse kommen ohne Unterbrechung weiter.

## Abschlusskriterien

- Das Prinzip „gewünschter Zustand wird hergestellt" ist an einem echten Cluster gesehen: drei Kopien gewünscht, eine fehlt, Kubernetes startet Ersatz.

## Erweiterung

Nach Lab 4.2 (Deployments) lässt sich die Demo im eigenen Cluster nachspielen, ohne Browser und ohne gemeinsame Adresse. Terminal im Ordner `project/` öffnen:

1. Erstelle drei Kopien: `kubectl create deployment hello-demo --image=hello-backend:v1 --replicas=3`.
2. Zeige sie mit `kubectl get pods -o wide -l app=hello-demo` an.
3. Starte in einem zweiten Terminal `kubectl get pods -o wide -l app=hello-demo -w` und lösche im ersten Terminal eine Kopie mit `kubectl delete pod <name>`.
4. Räume mit `kubectl delete deployment hello-demo` auf.

## Fallback

- Ohne Demo-Cluster: Die Lösung zeigt die Befehle und die Ausgaben der Demo Schritt für Schritt.
