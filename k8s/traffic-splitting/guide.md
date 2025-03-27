- Istio kommuniziert mit deinen Kubernetes-Diensten, indem es den Traffic Routing für den Service verwaltet. Dies geschieht mithilfe von VirtualServices und DestinationRules, die die Verteilung und Steuerung des Traffics zwischen verschiedenen Versionen deines Services ermöglichen.

- Jeder Pod, der von Istio verwaltet wird, enthält einen Envoy Proxy. Wenn ein Benutzer oder ein Service eine Anfrage an my-app stellt, wird diese Anfrage zuerst an den Envoy Proxy im entsprechenden Pod weitergeleitet.

- Istio spricht mit deinem Service über den Envoy Proxy, der als Sidecar im Kubernetes-Pod läuft.

- DestinationRule definieren, welche Versionen eines Services existieren und wie diese aufgerufen werden können.

- VirtualService legt fest, wie der Traffic an die verschiedenen Versionen des Services verteilt wird (z. B. für Canary Releases).

```
minikube addons enable istio
```
