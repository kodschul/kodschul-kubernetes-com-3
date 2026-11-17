# Health Checks und Ressourcen – Cheatsheet (Modul 8)

Alle Befehle wirken im aktuellen Namespace (`hello`); `<pod>` durch einen Namen aus `kubectl get pods` ersetzen.

## Probes (Lab 8.1)

| Befehl | Wirkung |
| --- | --- |
| `kubectl describe deployment frontend \| grep -E "Liveness\|Readiness"` | eingestellte Probes mit Pfad, Port, Intervall, Schwellen |
| `kubectl get pods -l tier=frontend -w` | `READY` und `RESTARTS` live verfolgen |
| `kubectl exec <pod> -- wget -qO- http://localhost/fail` | simulierten Ausfall in einem Frontend-Pod auslösen |
| `kubectl exec <pod> -- wget -qO- http://localhost/recover` | Ausfall beenden, ohne Neustart |
| `kubectl describe endpointslices -l kubernetes.io/service-name=frontend` | Endpoints mit `Conditions: Ready: true/false` |
| `kubectl describe pod <pod>` | Events `Readiness probe failed`, `Liveness probe failed`, `will be restarted` |
| `kubectl rollout status deployment/frontend` | wartet auf bereite neue Pods; hängt bei falscher Readiness |
| `kubectl rollout undo deployment/frontend` | Rollout mit kaputter Probe zurücknehmen |

| Probe-Feld | Standard | Bedeutung |
| --- | --- | --- |
| `readinessProbe` | – | nicht bereit → keine Anfragen über den Service |
| `livenessProbe` | – | gescheitert → Container-Neustart |
| `startupProbe` | – | bis bestanden ruhen die anderen beiden |
| `httpGet.path` / `port` | – | geprüfte Adresse; 200–399 = bestanden |
| `tcpSocket.port` | – | Port nimmt Verbindungen an = bestanden |
| `exec.command` | – | Befehl im Container, Exit-Code 0 = bestanden |
| `periodSeconds` | 10 | Abstand der Prüfungen |
| `failureThreshold` | 3 | Fehlschläge bis „gescheitert" |
| `timeoutSeconds` | 1 | maximale Antwortzeit |
| `initialDelaySeconds` | 0 | Wartezeit nach Start |

## Requests, Limits, QoS (Lab 8.2)

| Befehl | Wirkung |
| --- | --- |
| `kubectl get pods -l app=hello -o custom-columns=NAME:.metadata.name,QOS:.status.qosClass` | QoS-Klasse je Pod |
| `kubectl describe pod <pod>` | `Limits`, `Requests`, `QoS Class`, `Last State: … OOMKilled` |
| `kubectl describe node docker-desktop` | Abschnitt `Allocated resources`: Summe aller Requests/Limits |
| `kubectl patch pod <pod> --subresource resize --patch '{"spec":{"containers":[{"name":"frontend","resources":{"limits":{"cpu":"800m"}}}]}}'` | CPU-Limit im laufenden Pod ändern (In-place-Resize, ab 1.35 stabil) |
| `kubectl get pod <pod> -o jsonpath='{.status.containerStatuses[0].resources.limits.cpu}'` | vom kubelet umgesetzter Wert |
| `kubectl get pod <pod> -o jsonpath='{.status.containerStatuses[0].restartCount}'` | Neustarts des ersten Containers |

| Schreibweise | Bedeutung |
| --- | --- |
| `cpu: 100m` | 0,1 CPU-Kern |
| `cpu: "1"` | ein ganzer Kern |
| `memory: 64Mi` | 64 Mebibyte (64 × 1024² Byte) |
| `memory: 128m` | Fehler: 0,128 Byte |

| QoS-Klasse | Regel | bei Speichermangel |
| --- | --- | --- |
| `Guaranteed` | alle Container: Requests = Limits für CPU und Speicher | zuletzt verdrängt |
| `Burstable` | irgendein Request oder Limit gesetzt | danach |
| `BestEffort` | nichts gesetzt | zuerst verdrängt |

Reihenfolge beim Verdrängen: `BestEffort` vor `Burstable` vor `Guaranteed`.

## Autoscaling (Lab 8.3)

| Befehl | Wirkung |
| --- | --- |
| `kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.9.1/components.yaml` | metrics-server installieren |
| `kubectl patch deployment metrics-server -n kube-system --type=json -p '[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'` | Docker Desktop: kubelet-Zertifikat nicht prüfen |
| `kubectl top nodes` / `kubectl top pods` | aktueller CPU- und Speicherverbrauch |
| `kubectl autoscale deployment frontend --cpu=50% --min=1 --max=5` | HPA per Befehl anlegen |
| `kubectl apply -f playground/k8s/hpa.yaml` | HPA aus YAML anlegen (`autoscaling/v2`) |
| `kubectl get hpa frontend -w` | `TARGETS` und `REPLICAS` live verfolgen |
| `kubectl describe hpa frontend` | Events `New size: …; reason: …` |
| `kubectl run load --image=busybox:1.37 --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://frontend/work; done"` | Lastgenerator starten |
| `kubectl delete pod load` | Last beenden |
| `kubectl delete hpa frontend` | HPA entfernen; Replikazahl bleibt auf dem letzten Wert |

| HPA-Verhalten | Standard |
| --- | --- |
| Prüfintervall | 15 s |
| Toleranz | 10 % |
| Hochskalieren | sofort |
| Herunterskalieren | nach 300 s Stabilisierung (`behavior.scaleDown.stabilizationWindowSeconds`) |
