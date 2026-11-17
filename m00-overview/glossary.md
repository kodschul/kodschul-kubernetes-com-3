# Glossar

| Begriff | Bedeutung | Lab |
| --- | --- | --- |
| Access Mode | wer ein Volume gleichzeitig nutzen darf: `ReadWriteOnce`, `ReadWriteMany`, `ReadWriteOncePod` | 7.2 |
| Annotation | Zusatzinfo an einem Objekt, nicht zum Filtern gedacht | 3.3 |
| API-Server | zentrale Schnittstelle des Clusters; alle Befehle laufen über ihn | 2.3 |
| Chart | Helm-Paket aus Vorlagen und Standardwerten | 9.1 |
| ClusterIP | Service-Typ mit fester interner Adresse, nur im Cluster erreichbar | 5.1 |
| ConfigMap | Objekt mit Einstellungen, die als Umgebungsvariablen oder Dateien in Pods landen | 6.1 |
| Container | isolierter Prozess aus einem Image, teilt den Kernel des Rechners | 1.1 |
| containerd | Container-Runtime, die auf den Nodes Container startet | 1.1 |
| Context | Eintrag in der kubeconfig: Cluster, Benutzer, Standard-Namespace | 2.2 |
| Control Plane | Steuerzentrale: API-Server, etcd, Scheduler, Controller-Manager | 2.3 |
| Controller | Regelschleife, die den Ist-Zustand an den Soll-Zustand angleicht | 4.1 |
| CronJob | startet Jobs nach Zeitplan | 7.3 |
| DaemonSet | genau ein Pod pro Node, z. B. für Log-Sammler | 7.3 |
| Deployment | verwaltet ReplicaSets, Rollouts und Rollbacks einer App | 4.2 |
| Dockerfile | Bauanleitung für ein Image | 1.3 |
| EndpointSlice | Liste der Pod-Adressen hinter einem Service | 5.1 |
| etcd | Schlüssel-Wert-Datenbank mit dem gesamten Cluster-Zustand | 2.3 |
| Events | Meldungen des Clusters zu einem Objekt, z. B. Pull-Fehler | 3.4 |
| Gateway | Eingangstor für HTTP-Verkehr, betrieben vom Plattform-Team | 5.3 |
| Gateway API | Standard für HTTP-Routing in Kubernetes, Nachfolger von Ingress | 5.3 |
| Headlamp | grafische Oberfläche für Kubernetes, Nachfolger des Dashboards | 2.3 |
| Helm | Paketmanager für Kubernetes | 9.1 |
| HPA | Horizontal Pod Autoscaler: passt die Replikazahl an die Last an | 8.3 |
| HTTPRoute | Regel, welcher Host und Pfad zu welchem Service geht | 5.3 |
| Image | unveränderliches Paket aus App, Laufzeit und Bibliotheken | 1.1 |
| Ingress | älterer Standard für HTTP-Routing, eingefroren | 5.3 |
| Init-Container | Container, der vor den App-Containern läuft und endet | 3.2 |
| Job | Pod, der eine Aufgabe einmal bis zum Ende ausführt | 7.3 |
| kubeconfig | Datei `~/.kube/config` mit Clustern, Benutzern und Kontexten | 2.2 |
| kubectl | Kommandozeilen-Werkzeug für Kubernetes | 2.2 |
| kubelet | Agent auf jedem Node, startet die Pods | 2.3 |
| Label | Schlüssel-Wert-Paar an Objekten zum Filtern und Zuordnen | 3.3 |
| Limit | Obergrenze für CPU und Speicher eines Containers | 8.2 |
| Liveness Probe | Prüfung, ob ein Container neu gestartet werden muss | 8.1 |
| LoadBalancer | Service-Typ mit externer Adresse, lokal `localhost` | 5.2 |
| Manifest | YAML-Datei mit dem gewünschten Zustand eines Objekts | 2.4 |
| Namespace | Bereich im Cluster, der Objekte von Teams oder Umgebungen trennt | 2.4 |
| Node | Rechner im Cluster, auf dem Pods laufen | 2.2 |
| NodePort | Service-Typ, der auf jedem Node einen Port 30000–32767 öffnet | 5.2 |
| OOMKilled | Container wurde beendet, weil er sein Speicherlimit überschritten hat | 8.2 |
| Pod | kleinste Einheit: ein oder mehrere Container mit gemeinsamer IP | 3.1 |
| Pod Security Admission | prüft Pods gegen die Stufen privileged, baseline, restricted | 10.3 |
| Port-Forward | leitet einen Port des Laptops zu einem Pod oder Service | 3.1 |
| PersistentVolume (PV) | bereitgestellter Speicher im Cluster | 7.2 |
| PersistentVolumeClaim (PVC) | Anforderung von Speicher durch eine App | 7.2 |
| QoS-Klasse | Guaranteed, Burstable oder BestEffort; entscheidet, wer bei Knappheit zuerst geht | 8.2 |
| RBAC | rollenbasierte Rechte: Role, ClusterRole, RoleBinding | 10.1 |
| Readiness Probe | Prüfung, ob ein Pod Anfragen bekommen darf | 8.1 |
| Registry | Ablage für Images, z. B. Docker Hub | 1.1 |
| Release | eine installierte Instanz eines Helm-Charts | 9.1 |
| ReplicaSet | hält eine feste Anzahl gleicher Pods am Leben | 4.1 |
| Request | reservierte CPU und Speicher, Grundlage für die Planung | 8.2 |
| Rolling Update | Pods werden schrittweise durch die neue Version ersetzt | 4.3 |
| Scheduler | wählt den Node für jeden neuen Pod | 2.3 |
| Secret | Objekt für Passwörter und Schlüssel, nur Base64-codiert | 6.2 |
| securityContext | Sicherheitseinstellungen eines Pods oder Containers | 10.3 |
| Selector | Filter auf Labels, mit dem ein Objekt seine Pods findet | 3.3 |
| Service | feste Adresse und DNS-Name vor einer Gruppe von Pods | 5.1 |
| ServiceAccount | Identität für Programme im Cluster | 10.2 |
| Sidecar | Hilfscontainer im selben Pod, z. B. zum Mitlesen von Logs | 3.2 |
| StatefulSet | Pods mit festen Namen und eigenem Speicher je Pod | 7.3 |
| StorageClass | Art von Speicher, die PVs automatisch anlegt | 7.2 |
| Tag | Versionsname eines Images, z. B. `v1` | 1.3 |
| Volume | Verzeichnis, das Containern im Pod bereitgestellt wird | 7.1 |
