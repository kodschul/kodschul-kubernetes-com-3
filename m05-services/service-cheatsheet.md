# Services und Gateway API – Cheatsheet (Modul 5)

Alle Befehle im Ordner `project/`, Namespace `hello` als Standard im Kontext.

## Services anlegen und ansehen

| Befehl | Wirkung |
| --- | --- |
| `kubectl apply -f playground/k8s/backend-service.yaml` | Service anlegen oder ändern |
| `kubectl get services` | alle Services mit Typ, ClusterIP, `EXTERNAL-IP` und Ports |
| `kubectl get service frontend` | ein Service; `PORT(S) 8080:31847/TCP` = Service-Port : NodePort |
| `kubectl describe service backend` | Selector, ClusterIP, `TargetPort`, aktuelle Endpoints, Events |
| `kubectl delete service frontend` | Service löschen (Pods bleiben) |

## Endpoints und Selector prüfen

| Befehl | Wirkung |
| --- | --- |
| `kubectl get endpointslices -l kubernetes.io/service-name=backend` | Pod-IPs hinter dem Service; `<unset>` = kein Pod passt |
| `kubectl get endpointslices -l kubernetes.io/service-name=backend -w` | Änderungen live verfolgen (Strg+C beendet) |
| `kubectl get pods --show-labels` | Labels der Pods neben den Selector legen |
| `kubectl get pods -l tier=backend -o wide` | Pods mit IP, zum Vergleich mit der EndpointSlice |

`kubectl get endpoints` ist seit Kubernetes 1.33 veraltet und gibt eine Warnung aus.

## DNS und Erreichbarkeit im Cluster testen

| Befehl | Wirkung |
| --- | --- |
| `kubectl run tmp --rm -it --image=busybox:1.37 --restart=Never -- nslookup backend` | Namen im Cluster-DNS auflösen, Test-Pod danach löschen |
| `kubectl run tmp --rm -it --image=busybox:1.37 --restart=Never -- wget -qO- http://backend` | Service aus einem Test-Pod aufrufen |
| `kubectl exec deploy/frontend -- wget -qO- http://backend` | Service aus einem Frontend-Pod aufrufen (ohne neues Image) |

| DNS-Name | gilt für |
| --- | --- |
| `backend` | Pods im selben Namespace |
| `backend.hello` | Pods in allen Namespaces |
| `backend.hello.svc.cluster.local` | vollständiger Name (FQDN) |

## Zugriff von außen

| Befehl / Adresse | Wirkung |
| --- | --- |
| `type: NodePort` | Port 30000–32767 auf jedem Node öffnen |
| `type: LoadBalancer` | externen Load Balancer anfordern; Docker Desktop: `localhost:<port>` |
| `kubectl port-forward deployment/frontend 8080:80` | Tunnel vom Laptop zu einem Pod des Deployments |
| `kubectl port-forward service/frontend 9090:8080` | Tunnel über den Service-Port zu einem Pod |
| `minikube tunnel` | nur minikube: `LoadBalancer`-Services erreichbar machen |
| `kubectl proxy` + `http://localhost:8001/api/v1/namespaces/hello/services/http:backend:80/proxy/` | ClusterIP-Service über den API-Server aufrufen (Test, Strg+C beendet) |
| `type: ExternalName` + `externalName: db.example.com` | Cluster-Name als DNS-Alias für einen Dienst außerhalb |
| `clusterIP: None` | Headless Service: DNS-Name je Pod statt Sammel-IP (StatefulSet, Lab 7.3) |

## Envoy Gateway installieren

| Befehl | Wirkung |
| --- | --- |
| `kubectl apply --server-side -f https://github.com/envoyproxy/gateway/releases/download/v1.10.0/install.yaml` | CRDs der Gateway API und Envoy Gateway v1.10.0 installieren |
| `kubectl wait --timeout=5m -n envoy-gateway-system deployment/envoy-gateway --for=condition=Available` | warten, bis der Controller läuft |
| `kubectl get pods -n envoy-gateway-system` | Controller und Envoy-Proxys ansehen |
| `kubectl get crd \| grep gateway.networking.k8s.io` | prüfen, ob die Gateway-API-CRDs da sind |

## Gateway und Routen prüfen

| Befehl | Wirkung |
| --- | --- |
| `kubectl get gatewayclass` | `ACCEPTED True` = Controller hat die Klasse übernommen |
| `kubectl get gateway -n gateway` | `PROGRAMMED True` und `ADDRESS` des Eingangs |
| `kubectl describe gateway -n gateway hello-gateway` | Listener, angehängte Routen, Conditions |
| `kubectl get httproute` | Routen mit Hostnamen |
| `kubectl describe httproute hello` | `Accepted` und `ResolvedRefs` je Gateway |
| `kubectl get service -n envoy-gateway-system` | `LoadBalancer`-Service des Envoy-Proxys (`localhost:80`) |
| `curl http://hello.localhost/api` | Route von der Kommandozeile testen |
| `curl -H "Host: hello.localhost" http://localhost/` | Test ohne `*.localhost`-Auflösung (z. B. für Safari-Nutzer) |

## Objekte der Hello-App nach Modul 5

| Objekt | Name | Namespace | Kern |
| --- | --- | --- | --- |
| Service | `backend` | `hello` | ClusterIP, 80 → 80 |
| Service | `frontend` | `hello` | ClusterIP, 80 → 80 (in Lab 5.2 `LoadBalancer` 8080) |
| GatewayClass | `eg` | clusterweit | Envoy Gateway |
| Gateway | `hello-gateway` | `gateway` | Listener `http`, Port 80, Routen aus allen Namespaces |
| HTTPRoute | `hello` | `hello` | `hello.localhost`: `/api` → `backend`, `/` → `frontend` |
