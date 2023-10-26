{{/*
Expand the name of the chart.
*/}}
{{- define "nxrm-aws-resiliency.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "nxrm-aws-resiliency.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "nxrm-aws-resiliency.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "nxrm-aws-resiliency.labels" -}}
helm.sh/chart: {{ include "nxrm-aws-resiliency.chart" . }}
{{ include "nxrm-aws-resiliency.selectorLabels" . }}
app.kubernetes.io/version: {{ include "nxrm-aws-resiliency.appVersion" . | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app: nxrm
{{- end }}

{{/*
Selector labels
*/}}
{{- define "nxrm-aws-resiliency.selectorLabels" -}}
app.kubernetes.io/name: {{ include "nxrm-aws-resiliency.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Declare a version for the release, Chart version or image tag (strip SHAs from tags)
This can still trip the > 63 char limit...
*/}}
{{- define "nxrm-aws-resiliency.appVersion" -}}
{{- regexReplaceAll "@sha256:.*" (default .Chart.AppVersion .Values.deployment.container.image.tag) "" }}
{{- end }}
