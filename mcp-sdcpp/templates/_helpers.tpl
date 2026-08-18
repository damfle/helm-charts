{{/*
Expand the name of the chart.
*/}}
{{- define "mcp-sdcpp.name" -}}
{{- default "mcp-sdcpp" .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name for mcp-sdcpp UI.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mcp-sdcpp.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "mcp-sdcpp" .Values.nameOverride }}
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
{{- define "mcp-sdcpp.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels for mcp-sdcpp UI
*/}}
{{- define "mcp-sdcpp.labels" -}}
helm.sh/chart: {{ include "mcp-sdcpp.chart" . }}
{{ include "mcp-sdcpp.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels for mcp-sdcpp UI
*/}}
{{- define "mcp-sdcpp.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mcp-sdcpp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
