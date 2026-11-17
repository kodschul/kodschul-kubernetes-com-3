# Lab 8.2: Requests, Limits und QoS

**Leitfragen:**

<details>
<summary>Zehn Programme teilen sich einen Server: wer bekommt wie viel Speicher?</summary>

Ohne Absprache nimmt sich jedes, was es braucht, bis der Speicher ausgeht und das Betriebssystem Prozesse beendet. Kubernetes lässt jeden Container angeben, was er sicher braucht (Request) und wie viel er höchstens nehmen darf (Limit).

</details>

<details>
<summary>Was ist schlimmer: ein Programm, das langsamer wird, oder eins, das beendet wird?</summary>

Meist das beendete: Anfragen brechen ab, Daten im Speicher gehen verloren. Genau so unterscheiden sich die Grenzen: Zu viel CPU wird nur gebremst, zu viel Arbeitsspeicher führt zum Beenden (`OOMKilled`).

</details>

- Requests sind die Planungsgröße für den Scheduler, Limits die Obergrenze zur Laufzeit.
- Aus Requests und Limits ergibt sich die QoS-Klasse eines Pods; sie bestimmt, wen Kubernetes bei Speichermangel zuerst verdrängt.

## Begriffe

| Begriff | Bedeutung |
| --- | --- |
| Request | Menge CPU/Speicher, die der Scheduler (Lab 2.3) für den Container auf einem Node reserviert; wie ein reservierter Tisch im Restaurant |
| Limit | Obergrenze, die der Container zur Laufzeit nicht überschreiten darf |
| Millicore (`m`) | Tausendstel eines CPU-Kerns: `100m` = 0,1 Kern, `1` = ein ganzer Kern |
| `Mi`, `Gi` | Mebibyte (1024² Byte), Gibibyte (1024³ Byte); `M` ohne `i` = 1000², `m` (klein) = Tausendstel |
| Drosselung | Container mit zu viel CPU-Bedarf bekommt nur seine Limit-Menge Rechenzeit; er wird langsamer, läuft aber weiter |
| `OOMKilled` | „Out of Memory": der Linux-Kernel beendet den Container, weil er mehr Speicher als sein Limit belegt; Exit-Code 137 |
| QoS-Klasse | Quality of Service: `Guaranteed`, `Burstable` oder `BestEffort`, berechnet aus Requests und Limits |
| Verdrängung (Eviction) | kubelet beendet Pods, weil dem Node der Speicher ausgeht; Reihenfolge nach QoS-Klasse |
| Allocatable | was ein Node für Pods anbietet: Kapazität minus Reserve für System und kubelet |
| LimitRange | Objekt im Namespace, das Standardwerte und Grenzen für Requests und Limits setzt |
| In-place-Resize | Requests und Limits eines laufenden Pods ändern, ohne ihn neu zu erstellen |

## Requests und Limits

```yaml
# Ausschnitt aus playground/k8s/frontend-deployment.yaml (Lab 8.2), im Container frontend
          resources:
            requests:            # Planung: so viel reserviert der Scheduler
              cpu: 100m          # 0,1 CPU-Kern
              memory: 64Mi
            limits:              # Obergrenze zur Laufzeit
              cpu: 500m          # darüber: gedrosselt
              memory: 128Mi      # darüber: OOMKilled
```

| | Request | Limit |
| --- | --- | --- |
| Wer nutzt den Wert? | Scheduler beim Platzieren | Linux-Kernel (cgroups) zur Laufzeit |
| Bedeutung | „so viel brauche ich mindestens" | „mehr darf ich nicht" |
| Fehlt der Wert | Pod zählt als 0, Node kann überbucht werden | keine Obergrenze, der Container kann den Node leerräumen |
| Zu hoch gewählt | Pod bleibt `Pending` (`Insufficient cpu`), Node schlecht ausgelastet | kaum Schutz für die anderen Pods |

| Ressource | Container braucht mehr als das Limit | Folge |
| --- | --- | --- |
| CPU | bekommt nur `limit` Rechenzeit | langsamer, kein Neustart |
| Arbeitsspeicher | Kernel beendet den Prozess | `OOMKilled`, Container-Neustart, bei Wiederholung `CrashLoopBackOff` |

<img src="https://thumb.wikimedia.org/wikipedia/commons/thumb/6/6f/Out_of_Memory_in_Linux.jpg/960px-Out_of_Memory_in_Linux.jpg" alt="Foto einer Linux-Konsole mit mehreren Meldungen Out of memory: kill process und Killed process für apache2, pcmanfm und nautilus" width="520">

_Quelle: Wikimedia Commons, „Out of Memory in Linux.jpg" (https://commons.wikimedia.org/wiki/File:Out_of_Memory_in_Linux.jpg), Neo139, CC BY-SA 3.0, abgerufen am 17.11.2026._

Das Bild zeigt den OOM-Killer des Linux-Kernels auf einem ganzen Rechner. Im Container passiert dasselbe, nur mit dem Memory-Limit als Grenze: Kubernetes meldet den Grund als `OOMKilled`.

```text
$ kubectl describe pod frontend-6b7c9d5f8-zq4lx
    State:          Waiting
      Reason:       CrashLoopBackOff
    Last State:     Terminated
      Reason:       OOMKilled
      Exit Code:    137
    Restart Count:  3
```

Python mit Flask belegt im Leerlauf rund 30 bis 50 MiB; ein Limit von `16Mi` reicht nicht einmal für den Start. Die genaue Schwelle hängt von Image und Python-Version ab; `16Mi` liegt klar darunter.

## QoS-Klassen

| QoS-Klasse | Regel | Bei Speichermangel auf dem Node | geeignet für |
| --- | --- | --- | --- |
| `Guaranteed` | jeder Container hat CPU- und Speicher-Limits, Requests = Limits | zuletzt verdrängt | Datenbanken, Anmeldedienste: alles, was stabil laufen muss |
| `Burstable` | mindestens ein Request oder Limit, aber nicht `Guaranteed` | danach, Pods weit über ihrem Request zuerst | Web-Apps und Hintergrunddienste mit schwankender Last |
| `BestEffort` | kein Container hat Requests oder Limits | zuerst verdrängt | kurze Tests, unwichtige Hilfsaufgaben |

Die Hello-App liegt mit `requests < limits` in `Burstable`: Die App darf kurzfristig mehr nehmen, als reserviert ist. Wer `Guaranteed` braucht, setzt Requests und Limits gleich (Quelle: [Pod Quality of Service Classes](https://kubernetes.io/docs/concepts/workloads/pods/pod-qos/), Stand: 11/2026):

```yaml
          resources:               # Guaranteed: Requests = Limits für CPU und Speicher
            requests: { cpu: 500m, memory: 256Mi }
            limits:   { cpu: 500m, memory: 256Mi }
```

Stehen für CPU und Speicher nur Limits im Manifest, setzt Kubernetes die Requests auf dieselben Werte; der Pod ist dann ebenfalls `Guaranteed`.

```bash
kubectl get pods -l app=hello -o custom-columns=NAME:.metadata.name,QOS:.status.qosClass
```

`-o custom-columns` baut eine eigene Tabelle: Spaltenname, Doppelpunkt, Pfad im Objekt.

```bash
kubectl describe node docker-desktop      # Abschnitt "Allocated resources": Summe aller Requests und Limits
```

```text
Allocated resources:
  Resource           Requests      Limits
  --------           --------      ------
  cpu                1300m (16%)   2600m (32%)
  memory             650Mi (8%)    1252Mi (16%)
```

## In-place-Resize: Ressourcen ändern ohne Neustart

**Neu 2025:** Seit Kubernetes 1.35 (17.12.2025) ist In-place-Resize stabil. CPU und Speicher eines laufenden Pods lassen sich über die Unterressource `resize` ändern, ohne den Pod neu zu erstellen (Quelle: [Kubernetes v1.35 Release](https://kubernetes.io/blog/2025/12/17/kubernetes-v1-35-release), [Resize CPU and Memory Resources assigned to Containers](https://kubernetes.io/docs/tasks/configure-pod-container/resize-container-resources/)).

```bash
kubectl patch pod <pod> --subresource resize --patch \
  '{"spec":{"containers":[{"name":"frontend","resources":{"limits":{"cpu":"800m"}}}]}}'
```

`kubectl patch` ändert einzelne Felder eines Objekts direkt im Cluster; der Text in `--patch` nennt nur die Felder, die sich ändern (JSON).

Ob die Änderung angekommen ist, zeigen zwei Felder: `spec` (gewünscht) und `status` (vom kubelet umgesetzt). `-o jsonpath='{…}'` gibt genau ein Feld aus:

```bash
kubectl get pod <pod> -o jsonpath='{.spec.containers[0].resources.limits.cpu}'                # gewünscht: 800m
kubectl get pod <pod> -o jsonpath='{.status.containerStatuses[0].resources.limits.cpu}'       # umgesetzt: 800m
kubectl get pod <pod> -o jsonpath='{.status.containerStatuses[0].restartCount}'               # bleibt 0
```

| Regel | Bedeutung |
| --- | --- |
| `resizePolicy` je Ressource | `NotRequired` (Standard): Änderung ohne Container-Neustart; `RestartContainer`: Container startet neu |
| QoS-Klasse bleibt | ein `Burstable`-Pod darf nicht zu `Guaranteed` werden und umgekehrt |
| gilt nur für diesen Pod | das Deployment kennt die Änderung nicht; ein neuer Pod (Rollout, Löschen) hat wieder die Werte aus dem Manifest |
| kubectl ab 1.32 | ältere Versionen melden `invalid subresource` |
| zu viel verlangt | Pod-Bedingung `PodResizePending` mit Grund `Infeasible`, alte Werte bleiben aktiv |

## LimitRange: Standardwerte im Namespace

Fehlen in einem Manifest Requests oder Limits, setzt eine LimitRange Standardwerte und prüft Grenzen. Zusammen mit der ResourceQuota aus Lab 6.3 regelt der Betrieb so, was ein Team verbrauchen darf.

```yaml
# Beispiel, nicht Teil der Übung
apiVersion: v1
kind: LimitRange
metadata:
  name: standard-limits
  namespace: hello-dev
spec:
  limits:
    - type: Container
      defaultRequest:          # Request, wenn das Manifest keinen nennt
        cpu: 100m
        memory: 64Mi
      default:                 # Limit, wenn das Manifest keins nennt
        cpu: 500m
        memory: 256Mi
      max:                     # mehr darf kein Container verlangen
        cpu: "1"
        memory: 512Mi
```

## Typische Fehler

| Symptom | Ursache | Lösung |
| --- | --- | --- |
| Pod `Pending`, Event `0/1 nodes are available: 1 Insufficient cpu` | Summe der Requests größer als Allocatable | Requests senken oder Docker Desktop mehr CPUs geben |
| `OOMKilled`, Exit-Code 137, `CrashLoopBackOff` | Memory-Limit unter dem Bedarf | Limit erhöhen; Bedarf mit `kubectl top pods` messen (Lab 8.3) |
| `spec.containers[0].resources.requests: Invalid value: "64Mi": must be less than or equal to memory limit` | Request größer als Limit | Request ≤ Limit |
| Speicher-Limit `128m` statt `128Mi` | kleines `m` = Tausendstel Byte | `Mi` oder `Gi` schreiben |
| App langsam, keine Fehler | CPU-Limit zu knapp, Container wird gedrosselt | Limit erhöhen oder mehr Repliken (Lab 8.3) |
| `pods "frontend-…" is forbidden: failed quota: … must specify limits.memory` | ResourceQuota im Namespace verlangt Angaben | Requests und Limits setzen oder LimitRange anlegen |

## Vertiefung

- Pod-Level-Ressourcen (Beta seit 1.34, Stand: 11/2026): `resources` direkt unter `spec` gibt allen Containern eines Pods ein gemeinsames Budget (Quelle: [Kubernetes v1.34 Release, 27.08.2025](https://kubernetes.io/blog/2025/08/27/kubernetes-v1-34-release)).
- Der Vertical Pod Autoscaler (VPA) schlägt Requests auf Basis gemessener Werte vor und kann sie per In-place-Resize setzen; Ausblick in Lab 8.3.

## Fazit

- Requests planen (Scheduler), Limits begrenzen (Kernel): CPU wird gedrosselt, Speicher führt zu `OOMKilled`.
- QoS-Klasse aus Requests und Limits: `Guaranteed` > `Burstable` > `BestEffort`; die Hello-App ist `Burstable`.
- In-place-Resize (stabil seit 1.35) ändert einen laufenden Pod ohne Neustart, das Manifest bleibt die Quelle für neue Pods.

In der Übung bekommen Frontend und Backend Requests und Limits, ein zu kleines Memory-Limit führt zu `OOMKilled`, und ein CPU-Limit wird im laufenden Pod geändert.
