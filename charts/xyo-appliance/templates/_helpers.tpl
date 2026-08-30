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
Resolve the PostgreSQL password.

Deliberately has no default. A chart that ships working credentials gives every
operator who does not override them an identically-credentialled database, and
the value is readable by anyone with the chart. Failing the render is noisy, but
it is noisy at install time rather than in a deployment review.

Only reached when postgresql.auth.existingSecret is unset, since the secret and
DSN are only rendered on that branch.
*/}}
{{- define "xyo-appliance.postgresPassword" -}}
{{- required "postgresql.auth.password is required. Set postgresql.auth.existingSecret to reference a Secret you manage, or pass postgresql.auth.password explicitly. See charts/xyo-appliance/README.md." .Values.postgresql.auth.password -}}
{{- end }}

{{/*
Resolve the external database DSN.

Same reasoning: when an external database is enabled and no existing Secret is
named, a DSN must be supplied. Previously an unset DSN silently rendered no
Secret at all, so the failure surfaced later as a connection error rather than
as a clear message here.
*/}}
{{- define "xyo-appliance.externalDsn" -}}
{{- required "postgresql.external.dsn is required when postgresql.external.enabled is true. Set postgresql.external.existingSecret to reference a Secret you manage, or pass postgresql.external.dsn explicitly. See charts/xyo-appliance/README.md." .Values.postgresql.external.dsn -}}
{{- end }}

{{/*
Assert that a licence has been supplied one way or the other.

required() cannot do this job: the licence Secret only renders when licenseKey
is truthy, so a required() inside that branch is unreachable. With neither value
set the chart previously rendered deployments referencing a Secret that was never
created, so the install failed later with a missing-secret error rather than here
with an explanation.
*/}}
{{- define "xyo-appliance.validateLicense" -}}
{{- if and (not .Values.global.licenseKey) (not .Values.global.existingLicenseSecret) -}}
{{- fail "A licence is required. Set global.existingLicenseSecret to reference a Secret you manage, or pass global.licenseKey explicitly. See charts/xyo-appliance/README.md." -}}
{{- end -}}
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
{{- printf "postgres://%s:%s@%s-postgres:%d/%s?sslmode=disable" .Values.postgresql.auth.username (include "xyo-appliance.postgresPassword" .) (include "xyo-appliance.fullname" .) (.Values.postgresql.service.port | int) .Values.postgresql.auth.database -}}
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
