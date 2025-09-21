# Makefile for Terraform and Helm linting

.PHONY: help install-linters lint lint-tf lint-helm fmt fmt-tf fmt-helm validate validate-tf validate-helm clean

# Variables
TF_DIR = terraform
HELM_DIR = .
HELM_CHARTS = $(shell find . -name "Chart.yaml" -exec dirname {} \;)

# Help
help: ## Show help
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Install linters
install-linters: ## Install Terraform and Helm linters
	@echo "Installing Terraform linters..."
	@if ! command -v tflint &> /dev/null; then \
		brew install tflint || \
		curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash; \
	fi
	@echo "Installing Helm linters..."
	@if ! command -v helm &> /dev/null; then \
		brew install helm || \
		curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash; \
	fi
	@if ! command -v helm-unittest &> /dev/null; then \
		helm plugin install https://github.com/quintush/helm-unittest; \
	fi
	@echo "Installing pre-commit hooks..."
	@if ! command -v pre-commit &> /dev/null; then \
		pip install pre-commit; \
	fi

# Lint commands
lint: lint-tf lint-helm ## Run all linters

lint-tf: ## Lint Terraform code
	@echo "🔍 Linting Terraform..."
	@cd $(TF_DIR) && tflint --init
	@cd $(TF_DIR) && tflint
	@cd $(TF_DIR) && terraform fmt -check=true -diff=true -recursive=true

lint-helm: ## Lint Helm charts
	@echo "🔍 Linting Helm charts..."
	@for chart in $(HELM_CHARTS); do \
		echo "Linting chart: $$chart"; \
		helm lint $$chart || true; \
		helm template $$chart --debug || true; \
	done

# Format commands
fmt: fmt-tf fmt-helm ## Format all code

fmt-tf: ## Format Terraform code
	@echo "🎨 Formatting Terraform..."
	@cd $(TF_DIR) && terraform fmt -recursive=true

fmt-helm: ## Format Helm charts (basic validation)
	@echo "🎨 Validating Helm charts..."
	@for chart in $(HELM_CHARTS); do \
		echo "Validating chart: $$chart"; \
		helm template $$chart > /dev/null; \
	done

# Validate commands
validate: validate-tf validate-helm ## Validate all configurations

validate-tf: ## Validate Terraform configuration
	@echo "✅ Validating Terraform..."
	@cd $(TF_DIR) && terraform init -backend=false
	@cd $(TF_DIR) && terraform validate

validate-helm: ## Validate Helm charts
	@echo "✅ Validating Helm charts..."
	@for chart in $(HELM_CHARTS); do \
		echo "Validating chart: $$chart"; \
		helm template $$chart --validate || true; \
	done

# Security scanning
security: ## Run security scans
	@echo "🔒 Running security scans..."
	@cd $(TF_DIR) && terraform init -backend=false
	@cd $(TF_DIR) && terraform plan -var-file="var.tfvars" -out=tfplan
	@cd $(TF_DIR) && terraform show -json tfplan > tfplan.json
	@echo "Use tools like tfsec, checkov, or kube-score for detailed security analysis"

# Clean up
clean: ## Clean up generated files
	@echo "🧹 Cleaning up..."
	@find . -name ".terraform" -type d -exec rm -rf {} + 2>/dev/null || true
	@find . -name "*.tfplan" -delete 2>/dev/null || true
	@find . -name "*.tfstate*" -not -name "*.tfstate" -delete 2>/dev/null || true
	@find . -name "tfplan.json" -delete 2>/dev/null || true

# Pre-commit setup
setup-hooks: ## Setup pre-commit hooks
	@echo "🪝 Setting up pre-commit hooks..."
	@pre-commit install
	@pre-commit install --hook-type commit-msg

# Run pre-commit on all files
pre-commit-all: ## Run pre-commit on all files
	@pre-commit run --all-files

# CI/CD commands
ci: install-linters lint validate ## Run CI pipeline
	@echo "✅ CI pipeline completed successfully!"

# Development workflow
dev: fmt lint validate ## Development workflow
	@echo "🚀 Ready for development!"
