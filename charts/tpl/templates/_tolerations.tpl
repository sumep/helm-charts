{{/*
Return the range of tolerations if defined.

Example for infrastructure nodes in the values-file:
      tolerations:
        - effect: NoSchedule
          key: infra
          operator: Equal
          value: reserved
        - effect: NoSchedule
          key: infra
          operator: Equal
          value: reserved
     
{{ include "tpl.tolerations" . -}}
*/}}

{{- define "tpl.tolerations" -}}
tolerations:
{{- range . }}
- effect: "{{ .effect }}"
  key: "{{ .key }}"
  operator: "{{ .operator }}"
  value: "{{ .value }}"
  {{- if .tolerationSeconds }}
  tolerationSeconds: {{ .tolerationSeconds }}
  {{- end }}
{{- end }}
{{- end -}}
