# webserver-app-infra

Infrastructure as Code and GitOps configuration for [webserver-app](https://github.com/vigregus/webserver-app).

This repository demonstrates how a small application can be provisioned and delivered through a structured workflow using Terraform, Helm, Kubernetes, and GitOps.

## What this project demonstrates

- Infrastructure provisioning with Terraform
- Kubernetes application packaging with Helm
- Declarative GitOps delivery
- Separation of application and platform concerns
- Reproducible environment configuration
- Automated quality checks with pre-commit and linting

## Repository structure

```text
terraform/     Infrastructure provisioning
helm/          Application Helm chart and values
gitops/        Declarative deployment configuration
makefile       Common automation commands
.yamllint      YAML linting configuration
.pre-commit-config.yaml
               Local validation hooks
.secrets.baseline
               Secret-detection baseline
```

## Architecture

```text
webserver-app
    │
    ├── tests and CI
    └── container image
             │
             ▼
webserver-app-infra
    ├── Terraform ──> cloud and Kubernetes infrastructure
    ├── Helm ───────> application packaging
    └── GitOps ─────> declarative deployment and reconciliation
```

## Prerequisites

- Terraform
- kubectl
- Helm
- Access to the target cloud and Kubernetes environment
- GitOps controller when using the `gitops/` configuration

## Typical workflow

### 1. Review and provision infrastructure

```bash
cd terraform
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
```

Review every plan before applying it. Do not commit state files, plan files, credentials, or local variable files containing sensitive values.

### 2. Validate the Helm chart

```bash
helm lint helm
helm template webserver-app helm
```

### 3. Apply through GitOps

Use the manifests in `gitops/` with the GitOps controller configured for the target cluster. Keep environment-specific values and secrets outside the repository or reference them through a dedicated secret-management system.

## Teardown

Destroy test infrastructure when it is no longer needed to avoid unnecessary cloud charges:

```bash
cd terraform
terraform destroy
```

Always review the destroy plan before confirming it.

## Security notes

- Never commit Terraform state or cloud credentials.
- Keep real secrets in an external secret manager.
- Review generated plans before applying changes.
- Pin provider, module, chart, and image versions for production use.
- Run secret scanning against the complete Git history before reusing the repository.

## Related project

- [webserver-app](https://github.com/vigregus/webserver-app) — Python application, tests, Docker build, and CI workflows.

## Author

[Grigorii Pershin](https://github.com/vigregus) — Senior DevOps / Platform Engineer.
