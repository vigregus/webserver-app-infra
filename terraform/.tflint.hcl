config {
  # Only warn, don't fail on errors
  force = false
  # Disable module inspection
  disable = false
}

# Plugin for AWS rules (even if not using AWS, some rules are useful)
plugin "aws" {
  enabled = true
  version = "0.21.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# Plugin for Google Cloud Platform
plugin "google" {
  enabled = true
  version = "0.23.0"
  source  = "github.com/terraform-linters/tflint-ruleset-google"
}

# Plugin for Azure
plugin "azurerm" {
  enabled = true
  version = "0.20.0"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

# Plugin for Kubernetes
plugin "kubernetes" {
  enabled = true
  version = "0.2.0"
  source  = "github.com/terraform-linters/tflint-ruleset-kubernetes"
}

# Plugin for Helm
plugin "helm" {
  enabled = true
  version = "0.1.0"
  source  = "github.com/terraform-linters/tflint-ruleset-helm"
}

# Disable specific rules that might be too strict
rule "aws_resource_missing_tags" {
  enabled = false
}

rule "aws_iam_policy_document_gov_friendly_arns" {
  enabled = false
}

rule "aws_iam_policy_gov_friendly_arns" {
  enabled = false
}

rule "aws_iam_role_policy_gov_friendly_arns" {
  enabled = false
}

# Terraform specific rules
rule "terraform_deprecated_interpolation" {
  enabled = true
}

rule "terraform_deprecated_index" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_comment_syntax" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = false  # Too strict for development
}

rule "terraform_documented_variables" {
  enabled = false  # Too strict for development
}

rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_standard_module_structure" {
  enabled = false  # Too strict for simple projects
}

rule "terraform_workspace_remote" {
  enabled = true
}
