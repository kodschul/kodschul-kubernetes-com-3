# Helm – Cheatsheet (Modul 9)

Alle Befehle aus dem Ordner `project/`, Helm 4 (Stand: 11/2026).

## Charts finden und ansehen

| Befehl | Wirkung |
| --- | --- |
| `helm version` | zeigt die Helm-Version |
| `helm show chart oci://ghcr.io/stefanprodan/charts/podinfo --version 6.17.0` | Steckbrief eines Charts aus einer OCI-Registry |
| `helm show values <chart> --version <v>` | alle Standardwerte mit Kommentaren |
| `helm repo add podinfo https://stefanprodan.github.io/podinfo` | klassisches Repository unter dem Namen `podinfo` eintragen |
| `helm repo update` | Inhaltslisten aller eingetragenen Repositories neu laden |
| `helm repo list` | eingetragene Repositories anzeigen |
| `helm search repo podinfo` | in eingetragenen Repositories suchen (`--versions` zeigt alle Versionen) |
| `helm search hub podinfo` | auf Artifact Hub suchen |

## Installieren, ändern, entfernen

| Befehl | Wirkung |
| --- | --- |
| `helm install podinfo <chart> --version 6.17.0 -n podinfo --create-namespace` | Release `podinfo` anlegen, Namespace bei Bedarf erzeugen |
| `helm install … --set ui.message="Hallo"` | einzelnen Wert setzen (Punkte = Ebenen) |
| `helm upgrade podinfo <chart> -n podinfo -f playground/podinfo-values.yaml` | Release mit Werte-Datei ändern (neue Revision) |
| `helm upgrade --install hello playground/hello -n hello-prod -f playground/values-prod.yaml` | installieren oder ändern, je nachdem, ob das Release existiert |
| `helm upgrade … --reuse-values --set …` | Werte der letzten Revision behalten und ergänzen |
| `helm uninstall podinfo -n podinfo` | alle Objekte und Revisionen des Releases löschen |

## Releases ansehen

| Befehl | Wirkung |
| --- | --- |
| `helm list -n hello` | Releases im Namespace: Revision, Status, Chart, App-Version |
| `helm list -A` | Releases in allen Namespaces |
| `helm get values hello -n hello` | selbst gesetzte Werte der aktuellen Revision |
| `helm get values hello -n hello --revision 2` | Werte einer bestimmten Revision |
| `kubectl get secrets -n hello -l owner=helm` | Revisions-Secrets `sh.helm.release.v1.<release>.v<n>` |

## Eigenes Chart prüfen

| Befehl | Wirkung |
| --- | --- |
| `helm create demo` | Beispiel-Chart `demo` mit allen Dateien erzeugen |
| `helm dependency update <chart-ordner>` | Subcharts aus `dependencies` in `Chart.yaml` nach `charts/` laden, `Chart.lock` schreiben |
| `helm lint playground/hello` | Chart auf Fehler prüfen, ohne Cluster |
| `helm template hello playground/hello -n hello` | Chart rendern und YAML ausgeben, ohne Cluster |
| `helm template … --set color=pink \| grep APP_COLOR` | Wirkung eines Werts prüfen |
| `helm template … --debug` | bei Fehlern das kaputte YAML mit ausgeben |
| `helm install hello playground/hello -n hello --dry-run=server` | API-Server prüft, nichts wird angelegt |

## Upgrade und Rollback

| Befehl | Wirkung |
| --- | --- |
| `helm upgrade … --rollback-on-failure --timeout 90s` | warten, bis alles bereit ist; bei Fehler automatisch zurück (früher `--atomic`) |
| `helm upgrade … --wait` | warten, bis alle Objekte bereit sind (ohne automatischen Rollback) |
| `helm history hello -n hello-prod` | alle Revisionen mit Status und Beschreibung |
| `helm rollback hello 1 -n hello-prod` | neue Revision mit dem Stand von Revision 1 |

## Charts weitergeben

| Befehl | Wirkung |
| --- | --- |
| `helm package playground/hello -d playground/` | Archiv `hello-<chart-version>.tgz` erzeugen |
| `helm registry login ghcr.io -u <benutzer>` | bei einer OCI-Registry anmelden (nur Domainname) |
| `helm push hello-0.1.0.tgz oci://ghcr.io/<benutzer>/charts` | Chart in die Registry laden |
| `helm install hello oci://…/hello@sha256:<digest>` | nur genau diesen Inhalt installieren (Helm 4) |
| `helm repo index <ordner> --url https://…` | `index.yaml` für ein klassisches Repository (GitHub Pages, S3, Webserver) erzeugen |

## Template-Syntax

| Ausdruck | Wirkung |
| --- | --- |
| `{{ .Values.frontend.replicas }}` | Wert aus `values.yaml` |
| `{{ .Release.Name }}` / `{{ .Release.Namespace }}` | Release-Name / Namespace |
| `{{ .Chart.Version }}` / `{{ .Chart.AppVersion }}` | Felder aus `Chart.yaml` |
| `{{ .Values.color \| quote }}` | Wert in Anführungszeichen |
| `{{ .Values.tag \| default .Chart.AppVersion }}` | Ersatzwert, wenn leer |
| `{{- toYaml .Values.frontend.resources \| nindent 12 }}` | YAML-Block eingerückt übernehmen |
| `{{- include "hello.labels" . \| nindent 4 }}` | Baustein aus `_helpers.tpl` einfügen |
| `{{- if .Values.persistence.enabled }} … {{- else }} … {{- end }}` | Teil ein- oder ausschalten |
