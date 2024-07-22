{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "cluster.initial_master_nodes" -}}
{{- $result := "" -}}
{{- $myInt := int .Values.es.node.data_node.replica -}}
{{- range $i, $_ := until $myInt -}}
{{- if ne $i 0 -}}
{{- $result = print $result "," -}}
{{- end -}}
{{- $result = print $result $.Values.cluster.id "-node-" $i -}}
{{- end -}}
{{print $result}}
{{- end }}


{{- define "discovery.seed_hosts" -}}
{{- $myInt := int .Values.es.node.data_node.replica -}}
{{- $result := "" -}}
{{- range $i, $_ := until $myInt -}}
{{- if ne $i 0 -}}
{{- $result = print $result "," -}}
{{- end -}}
{{- $result = print $result $.Values.cluster.id "-node-" $i ".es-" $.Values.cluster.id "-headless." $.Release.Namespace -}}
{{- end -}}
{{print $result}}
{{- end }}
