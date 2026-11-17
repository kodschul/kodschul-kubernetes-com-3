{{/*
Hilfsvorlagen: Dateien mit _ am Anfang erzeugen keine Objekte.
Einbinden mit: {{- include "hello.labels" . | nindent 4 }}
*/}}

{{/* Labels für alle Objekte des Charts */}}
{{- define "hello.labels" -}}
app: hello
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end }}

{{/* Labels für Selektoren: nie die Version, damit ein Rollout die Pods weiter findet */}}
{{- define "hello.selectorLabels" -}}
app: hello
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
