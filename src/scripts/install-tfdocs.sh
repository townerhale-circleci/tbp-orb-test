#! /bin/bash
go install github.com/terraform-docs/terraform-docs@latest

modules=$(if [ -d "modules" ]; then echo true; else echo false; fi)

cat <<-EOT > .terraform-docs.yml
formatter: markdown
recursive:
  enabled: $modules
output:
  file: README.md
  mode: inject
  template: |-
    <!-- BEGIN_TF_DOCS -->
    {{ .Content }}
    <!-- END_TF_DOCS -->
sort:
  enabled: true
  by: name
settings:
  anchor: true
  color: true
  default: true
  description: true
  escape: true
  hide-empty: false
  html: true
  indent: 2
  lockfile: true
  read-comments: true
  required: true
  sensitive: true
  type: true
EOT
