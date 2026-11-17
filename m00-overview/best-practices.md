# Best Practices

## Images

| Regel | Warum |
| --- | --- |
| Immer feste Tags (`v1`, `v2`), nie nur `latest` | sichtbar, welche Version läuft; Rollback möglich |
| Kleines, aktuelles Basisimage | weniger Angriffsfläche, schnellerer Pull |
| Abhängigkeiten vor dem Code kopieren | Build-Cache greift, Builds werden schneller |
| Als Nicht-root-Benutzer laufen | Angreifer im Container hat weniger Rechte |
| Keine Konfiguration und Passwörter im Image | dasselbe Image für alle Umgebungen |

## Manifeste

| Regel | Warum |
| --- | --- |
| Deklarativ mit `kubectl apply -f` arbeiten | Zustand steht in Dateien, nachvollziehbar und wiederholbar |
| Immer Deployments statt einzelner Pods | Self-Healing und Rollouts |
| Einheitliche Labels `app`, `tier`, `version` | Services und Abfragen finden die richtigen Pods |
| Selector nie auf `version` | Rollouts tauschen sonst die Pods unter dem Service weg |
| Namespaces für Teams und Umgebungen | Objekte bleiben getrennt, Rechte lassen sich vergeben |

## Betrieb

| Regel | Warum |
| --- | --- |
| Readiness- und Liveness-Probe für jede App | Traffic nur an bereite Pods, Hänger werden neu gestartet |
| Liveness prüft nur die App selbst | sonst startet ein Backend-Ausfall alle Frontends neu |
| Requests und Limits setzen | Planung des Schedulers stimmt, kein Pod frisst den Node |
| Dauerhafte Daten auf PVC | Pods sind flüchtig, ihr Dateisystem auch |
| Fehlersuche von außen nach innen | Route → Service → EndpointSlice → Pod → Container |

## Sicherheit

| Regel | Warum |
| --- | --- |
| Rechte nach dem Prinzip der geringsten Rechte | ein gestohlenes Konto richtet wenig Schaden an |
| Eigener ServiceAccount je App, Token nur bei Bedarf | Pods ohne API-Zugriff können keine Rechte missbrauchen |
| Namespaces mit Pod Security `restricted` | unsichere Pods werden abgewiesen |
| Secrets nie in Git | Base64 ist keine Verschlüsselung |

## Helm und Releases

| Regel | Warum |
| --- | --- |
| Eine Values-Datei je Umgebung | Unterschiede stehen an einer Stelle |
| `helm lint` und `helm template` vor jeder Installation | Fehler fallen vor dem Cluster auf |
| `--rollback-on-failure` bei Upgrades | fehlgeschlagene Upgrades werden automatisch zurückgerollt |
| Charts nur aus geprüften Quellen | Lieferketten ändern sich (Bitnami 2025) |
| Neue Versionen erst als Canary | Fehler treffen nur einen kleinen Teil der Nutzer |
