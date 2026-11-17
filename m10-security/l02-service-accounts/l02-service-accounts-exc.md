# Lab 10.2 – Übung: ServiceAccounts

**Dauer:** ca. 15 Minuten
**Ändert die Hello-App-Projektbasis?** Ja — neuer ServiceAccount `hello-reader` mit Role im Namespace `hello`, Test-Pod `api-test`; das Chart `hello` wird Version 0.2.0 ohne Token in den Hello-Pods.

## Vorbereitung

- Terminal im Ordner `project/`.
- Starter: [`project/starters/m10-l02-service-account.yaml`](../../project/starters/m10-l02-service-account.yaml), [`project/starters/m10-l02-api-test-pod.yaml`](../../project/starters/m10-l02-api-test-pod.yaml) · Arbeitsdateien: `project/playground/k8s/service-account.yaml`, `project/playground/k8s/api-test-pod.yaml`, `project/playground/hello/`
- Ausgangsstand: Release `hello` im Namespace `hello` aus Lab 9.2. Wiederherstellen: `rm -rf playground/hello && cp -R examples/m09-helm/l03-releases/hello playground/hello && helm upgrade --install hello playground/hello -n hello`.

## Aufgaben

1. Kopiere beide Starter nach `playground/k8s/`, ergänze die `# TODO:`-Stellen (Ressource, Verben, Subject, `serviceAccountName`) und wende beide Dateien an. Prüfe mit `kubectl get serviceaccount,role,rolebinding -n hello` und `kubectl get pod api-test -n hello -o jsonpath='{.spec.serviceAccountName}'`.
2. Prüfe die Rechte des ServiceAccounts von außen: `kubectl auth can-i list pods -n hello --as=system:serviceaccount:hello:hello-reader` und dasselbe mit `delete pods`.
3. Öffne eine Shell im Test-Pod mit `kubectl exec -it api-test -n hello -- sh`, zeige den Inhalt von `/var/run/secrets/kubernetes.io/serviceaccount/`, lies das Token in die Variable `TOKEN` und frage mit `curl` (mit `--cacert` und `Authorization: Bearer`) die Pods im Namespace `hello` ab; begrenze die Ausgabe mit `| head -n 20`.
4. Versuche in derselben Shell, den Pod `api-test` über die API zu löschen: gleiche Anfrage mit `-X DELETE` an `…/namespaces/hello/pods/api-test`. Verlasse die Shell danach mit `exit`.
5. Ergänze im Chart `playground/hello/` in `backend-deployment.yaml` und `frontend-deployment.yaml` direkt unter `template.spec` die Zeile `automountServiceAccountToken: false`, setze in `Chart.yaml` die Version auf `0.2.0` und führe `helm upgrade hello playground/hello -n hello` aus. Prüfe danach `kubectl exec deploy/hello-frontend -n hello -- ls /var/run/secrets/kubernetes.io/serviceaccount`.

## Checkpoint

- Aufgabe 1: Ausgabe `hello-reader`.
- Aufgabe 2: `list` → `yes`, `delete` → `no`.
- Aufgabe 3: der Ordner enthält `ca.crt`, `namespace`, `token`; `curl` liefert JSON mit `"kind": "PodList"` und den Hello-Pods.
- Aufgabe 4: JSON mit `"reason": "Forbidden"` und `"code": 403`; `api-test` läuft weiter.
- Aufgabe 5: `helm list -n hello` zeigt `hello-0.2.0`, Revision 2; `ls` meldet `No such file or directory`.

## Abschlusskriterien

- Der Pod `api-test` darf Pods lesen, aber nicht löschen.
- Die Hello-Pods im Namespace `hello` haben kein ServiceAccount-Token mehr; die Seite `http://hello.localhost` funktioniert unverändert.

## Erweiterung

Liste alle Rechte des ServiceAccounts mit `kubectl auth can-i --list -n hello --as=system:serviceaccount:hello:hello-reader` und vergleiche mit denselben Rechten für `system:serviceaccount:hello:default`.

## Fallback

- Image `curlimages/curl:8.23.0` lässt sich nicht laden (Docker-Hub-Limit): im Pod `api-test` das Image `busybox:1.37` verwenden und statt `curl` den Befehl `wget -qO- --header "Authorization: Bearer $TOKEN" --no-check-certificate https://kubernetes.default.svc/api/v1/namespaces/hello/pods` nutzen (ohne Zertifikatsprüfung, nur zum Test; das Löschen in Aufgabe 4 kann `wget` nicht senden).
- Fertiger Stand: [`project/examples/m10-security/l02-service-accounts/`](../../project/examples/m10-security/l02-service-accounts/) (`service-account.yaml`, `api-test-pod.yaml`, Chart `hello/` in Version 0.2.0).
