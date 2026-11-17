# Fehlersuche und Release-Strategien – Cheatsheet (Modul 11)

Kette von außen nach innen: Route → Service → EndpointSlice → Pod → Container (Lab 11.1). Für andere Namespaces `-n <namespace>` anhängen.

## Route und Service prüfen

| Befehl | Wirkung |
| --- | --- |
| `kubectl get httproute` | Routen im Namespace mit Hostnamen |
| `kubectl describe httproute <name>` | Bedingungen `Accepted` und `ResolvedRefs`, Ziele der Route |
| `kubectl describe svc <name>` | Selector, `Port`, `TargetPort`, Endpunkte |
| `kubectl get endpointslices -l kubernetes.io/service-name=<name>` | Port und IPs der bereiten Pods hinter einem Service |
| `kubectl port-forward svc/<name> 8083:80` | Service-Port lokal öffnen (wählt einen laufenden Pod, prüft Bereitschaft nicht) |
| `kubectl run test --rm -it --restart=Never --image=busybox:1.37 -- wget -qO- -T 3 http://<service>` | Service aus dem Cluster heraus testen |

## Pod und Container prüfen

| Befehl | Wirkung |
| --- | --- |
| `kubectl get pods -o wide` | Status, READY, Neustarts, IP, Node |
| `kubectl get pods -w` | Statuswechsel live verfolgen (Strg+C beendet) |
| `kubectl describe pod <pod>` | Container, Ports, Variablen, Probes, Events |
| `kubectl events --for pod/<pod>` | Events eines Pods |
| `kubectl events --types=Warning` | alle Warnungen im Namespace |
| `kubectl logs <pod> -c <container>` | Ausgabe eines Containers |
| `kubectl logs <pod> -c <container> --previous` | Ausgabe vor dem letzten Neustart |
| `kubectl port-forward pod/<pod> 8084:80` | Pod direkt öffnen, ohne Service und Route |
| `kubectl debug -it <pod> --image=busybox:1.37 --target=<container>` | ephemeren Debug-Container mit Werkzeugen in den Pod setzen |
| `ps`, `netstat -tln`, `wget -qO- http://localhost:<port>/healthz` | im Debug-Container: Prozesse, offene Ports, lokaler Aufruf |

## Pod-Status deuten

| Status | Erster Befehl |
| --- | --- |
| `Pending` | `kubectl describe pod`, Events |
| `ErrImageNeverPull`, `ImagePullBackOff` | `docker images`, Image im Manifest |
| `CreateContainerConfigError` | `kubectl events --for pod/<pod>` |
| `CrashLoopBackOff` | `kubectl logs <pod> --previous` |
| `Running`, READY `0/1` | Events: `Readiness probe failed` |
| `Running`, READY `1/1`, Seite leer | `describe svc`, EndpointSlice |

## Canary, Blue/Green und A/B

| Befehl / Feld | Wirkung |
| --- | --- |
| `backendRefs: [{name: a, port: 80, weight: 90}, {name: b, port: 80, weight: 10}]` | HTTPRoute verteilt etwa 90 % an `a`, 10 % an `b` |
| `matches: [{headers: [{name: x-version, value: v2}]}]` | Regel greift nur bei diesem Header (A/B) |
| `kubectl apply -f canary-route.yaml` | neue Gewichte übernehmen |
| `for i in $(seq 1 50); do curl -s http://canary.hello.localhost/ \| grep -m1 -o 'Hello-App v[0-9]'; done \| sort \| uniq -c` | Verteilung der Versionen zählen |
| `curl -s -H "x-version: v2" http://canary.hello.localhost/` | Anfrage mit Header senden |
| `kubectl patch service <name> -p '{"spec":{"selector":{"version":"v2"}}}'` | Blue/Green: Service auf die andere Version umschalten |
| `kubectl get pods -l version=v2` | Pods einer Version anzeigen |

## Aufräumen

| Befehl | Wirkung |
| --- | --- |
| `kubectl delete namespace hello-debug` | alle Fehlerbilder aus Lab 11.1 entfernen |
| `kubectl delete -f playground/k8s/canary-route.yaml -f playground/k8s/frontend-v2-service.yaml -f playground/k8s/frontend-v2-deployment.yaml` | Canary aus Lab 11.2 entfernen |
