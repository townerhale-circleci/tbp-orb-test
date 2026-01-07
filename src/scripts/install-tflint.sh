#! /bin/bash -ex

curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

cat <<-EOT > .tflint.hcl
plugin "aws" {
  enabled = true
  version = "0.43.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

plugin "azurerm" {
  enabled = true
  version = "0.29.0"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

plugin "google" {
  enabled = true
  version = "0.35.0"
  source  = "github.com/terraform-linters/tflint-ruleset-google"
}

config {
}
EOT
