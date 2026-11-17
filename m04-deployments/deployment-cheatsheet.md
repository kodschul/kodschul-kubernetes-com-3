# Deployments – Cheatsheet (Modul 4)

Alle Befehle wirken im Standard-Namespace des Kontexts (`hello`). Pod-Befehle (`logs`, `describe`, `exec`): [Pod-Cheatsheet](../m03-pods/pod-cheatsheet.md).

## ReplicaSets

| Befehl | Wirkung |
| --- | --- |
| `kubectl apply -f playground/k8s/frontend-replicaset.yaml` | ReplicaSet anlegen oder ändern |
| `kubectl get rs` | ReplicaSets mit `DESIRED`, `CURRENT`, `READY` |
| `kubectl scale rs frontend --replicas=5` | Soll-Anzahl sofort ändern (bis zum nächsten `apply`) |
| `kubectl delete rs frontend` | ReplicaSet samt seinen Pods löschen |
| `kubectl describe pod <name>` | `Controlled By` zeigt das verwaltende Objekt |

## Deployments anlegen und skalieren

| Befehl | Wirkung |
| --- | --- |
| `kubectl create deployment backend --image=hello-backend:v1 --port=80 --dry-run=client -o yaml > playground/k8s/backend-deployment.yaml` | Manifest-Vorlage erzeugen, nichts anlegen |
| `kubectl apply -f playground/k8s/` | alle Manifeste des Ordners anwenden |
| `kubectl get deploy` | Deployments mit `READY`, `UP-TO-DATE`, `AVAILABLE` |
| `kubectl get deploy,rs,pods` | alle drei Ebenen auf einen Blick |
| `kubectl scale deployment frontend --replicas=3` | Anzahl ändern |
| `kubectl scale deployment/backend deployment/frontend --replicas=3` | mehrere Deployments auf einmal |
| `kubectl port-forward deployment/frontend 8080:80` | Weiterleitung zu einem Pod des Deployments |
| `kubectl delete deployment frontend` | Deployment mit ReplicaSets und Pods löschen |

## Beobachten

| Befehl | Wirkung |
| --- | --- |
| `kubectl get pods -l tier=frontend -w` | Pods live verfolgen (**Strg+C**) |
| `kubectl rollout status deployment/frontend` | warten, bis der Rollout fertig ist |
| `kubectl rollout status deployment/frontend --timeout=30s` | höchstens 30 s warten, sonst Fehler |

## Rollout und Rollback

| Befehl | Wirkung |
| --- | --- |
| Image und `kubernetes.io/change-cause` in der Datei ändern, `kubectl apply -f …` | neuen Rollout starten (deklarativ) |
| `kubectl rollout history deployment/frontend` | Revisionen mit `CHANGE-CAUSE` |
| `kubectl rollout history deployment/frontend --revision=3` | Template einer Revision anzeigen |
| `kubectl rollout undo deployment/frontend` | zur vorherigen Revision zurück |
| `kubectl rollout undo deployment/frontend --to-revision=1` | zu einer bestimmten Revision zurück |

Nach einem `undo` die Datei auf den laufenden Stand zurücksetzen.

## Manifest-Felder

| Feld | Wirkung |
| --- | --- |
| `apiVersion: apps/v1` | API-Gruppe für ReplicaSet und Deployment |
| `spec.replicas` | Soll-Anzahl der Pods |
| `spec.selector.matchLabels` | Pods, die dazugehören (`app` + `tier`, nie `version`) |
| `spec.template` | Pod-Bauplan; jede Änderung daran erzeugt beim Deployment eine neue Revision |
| `spec.strategy.type: RollingUpdate` / `Recreate` | schrittweise austauschen / alle beenden, dann neu starten |
| `spec.strategy.rollingUpdate.maxSurge: 1` | höchstens ein Pod über `replicas` |
| `spec.strategy.rollingUpdate.maxUnavailable: 0` | nie weniger bereite Pods als `replicas` |
| `metadata.annotations."kubernetes.io/change-cause"` | Grund der Änderung in der Historie |
