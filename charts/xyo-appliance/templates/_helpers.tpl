{{/*
Expand the name of the chart.
*/}}
{{- define "xyo-appliance.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "xyo-appliance.fullname" -}}
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
{{- define "xyo-appliance.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels applied to all resources
*/}}
{{- define "xyo-appliance.labels" -}}
helm.sh/chart: {{ include "xyo-appliance.chart" . }}
{{ include "xyo-appliance.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: xyo-appliance
{{- end }}

{{/*
Component labels
*/}}
{{- define "xyo-appliance.componentLabels" -}}
helm.sh/chart: {{ include "xyo-appliance.chart" .root }}
app.kubernetes.io/name: {{ include "xyo-appliance.name" .root }}
app.kubernetes.io/instance: {{ .root.Release.Name }}
app.kubernetes.io/component: {{ .component }}
{{- if .root.Chart.AppVersion }}
app.kubernetes.io/version: {{ .root.Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .root.Release.Service }}
app.kubernetes.io/part-of: xyo-appliance
{{- end }}

{{/*
Selector labels
*/}}
{{- define "xyo-appliance.selectorLabels" -}}
app.kubernetes.io/name: {{ include "xyo-appliance.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Component Selector labels
*/}}
{{- define "xyo-appliance.componentSelectorLabels" -}}
app.kubernetes.io/name: {{ include "xyo-appliance.name" .root }}
app.kubernetes.io/instance: {{ .root.Release.Name }}
app.kubernetes.io/component: {{ .component }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "xyo-appliance.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "xyo-appliance.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Resolve Image Registry
*/}}
{{- define "xyo-appliance.imageRegistry" -}}
{{- $registry := .image.registry | default .root.Values.global.imageRegistry -}}
{{- if $registry -}}
{{- printf "%s/" $registry -}}
{{- end -}}
{{- end }}

{{/*
Resolve Image Pull Secrets
*/}}
{{- define "xyo-appliance.imagePullSecrets" -}}
{{- $pullSecrets := list -}}
{{- if .Values.global.imagePullSecrets -}}
  {{- range .Values.global.imagePullSecrets -}}
    {{- $pullSecrets = append $pullSecrets . -}}
  {{- end -}}
{{- end -}}
{{- if (not (empty $pullSecrets)) -}}
imagePullSecrets:
{{- range $pullSecrets }}
  - name: {{ .name }}
{{- end }}
{{- end -}}
{{- end }}

{{/*
Resolve License Secret Name
*/}}
{{- define "xyo-appliance.licenseSecretName" -}}
{{- if .Values.global.existingLicenseSecret -}}
{{- .Values.global.existingLicenseSecret -}}
{{- else -}}
{{- printf "%s-license" (include "xyo-appliance.fullname" .) -}}
{{- end -}}
{{- end }}

{{/*
Resolve License Secret Key
*/}}
{{- define "xyo-appliance.licenseSecretKey" -}}
{{- .Values.global.licenseSecretKey | default "license-key" -}}
{{- end }}

{{/*
Resolve Database Secret Name
*/}}
{{- define "xyo-appliance.dbSecretName" -}}
{{- if .Values.postgresql.external.enabled -}}
  {{- if .Values.postgresql.external.existingSecret -}}
    {{- .Values.postgresql.external.existingSecret -}}
  {{- else -}}
    {{- printf "%s-db-secret" (include "xyo-appliance.fullname" .) -}}
  {{- end -}}
{{- else -}}
  {{- if .Values.postgresql.auth.existingSecret -}}
    {{- .Values.postgresql.auth.existingSecret -}}
  {{- else -}}
    {{- printf "%s-postgres-secret" (include "xyo-appliance.fullname" .) -}}
  {{- end -}}
{{- end -}}
{{- end }}

{{/*
Resolve Database DSN
*/}}
{{- define "xyo-appliance.dbDsn" -}}
{{- if .Values.postgresql.external.enabled -}}
{{- .Values.postgresql.external.dsn -}}
{{- else -}}
{{- printf "postgres://%s:%s@%s-postgres:%d/%s?sslmode=disable" .Values.postgresql.auth.username .Values.postgresql.auth.password (include "xyo-appliance.fullname" .) (.Values.postgresql.service.port | int) .Values.postgresql.auth.database -}}
{{- end -}}
{{- end }}

{{/*
Resolve Logos PVC Name
*/}}
{{- define "xyo-appliance.logosPvcName" -}}
{{- if .Values.persistence.logos.existingClaim -}}
{{- .Values.persistence.logos.existingClaim -}}
{{- else -}}
{{- printf "%s-logos" (include "xyo-appliance.fullname" .) -}}
{{- end -}}
{{- end }}
