# Makefile for minikube cluster
.PHONY: help create destroy

# Variables
CLUSTER_NAME := multi
NODES := 4
MEMORY := 4096
CPUS := 2

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

help: ## Show help
	@echo "$(GREEN)Available commands:$(NC)"
	@echo "  create  - Create minikube cluster and deploy applications"
	@echo "  create-cluster  - Create minikube cluster"
	@echo "  deploy-apps - Deploy applications"
	@echo "  destroy - Destroy cluster and all applications"

create: ## Create cluster and deploy applications
	@echo "$(YELLOW)🚀 Creating minikube cluster...$(NC)"
	minikube start --nodes=$(NODES) --addons=storage-provisioner --memory=$(MEMORY) --cpus=$(CPUS) -p $(CLUSTER_NAME)
	@echo "$(GREEN)✅ Cluster created!$(NC)"
	@echo "$(YELLOW)📦 Deploying applications...$(NC)"
	@echo "$(YELLOW)Step 1: Deploying basic infrastructure...$(NC)"
	cd terraform && terraform apply  -auto-approve -target=helm_release.argocd -target=kubernetes_secret.github_repo -target=kubernetes_secret.ghcr_secret -target=helm_release.external_secrets -target=time_sleep.wait_external_secrets_crds -target=kubernetes_role.eso_read_secrets_argocd -target=kubernetes_role_binding.eso_read_secrets_argocd
	@echo "$(YELLOW)Step 2: Deploying applications...$(NC)"
	cd terraform && terraform apply  -auto-approve -target=kubernetes_manifest.app_of_apps -target=kubernetes_manifest.cluster_secret_store_k8s -target=helm_release.updater
	@echo "$(GREEN)✅ Applications deployed!$(NC)"
	@echo "$(YELLOW)📋 Access information:$(NC)"
	@echo "ArgoCD URL: http://localhost:8080"
	@echo "ArgoCD login: admin"
	@echo -n "ArgoCD password: "
	@kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
	@echo ""
	@echo "$(YELLOW)🔗 To access ArgoCD run:$(NC)"
	@echo "kubectl port-forward -n argocd svc/argocd-server 8080:80"
	@echo ""
	@echo "$(YELLOW)📊 To access Grafana run:$(NC)"
	@echo "kubectl port-forward -n monitoring svc/vm-stack-grafana 3000:80"
	@echo "URL: http://localhost:3000"
	@echo "Login: admin"
	@echo "Password: admin"



create-cluster: ## Create minikube cluster
	@echo "$(YELLOW)🚀 Creating minikube cluster...$(NC)"
	minikube start --nodes=$(NODES) --addons=storage-provisioner --memory=$(MEMORY) --cpus=$(CPUS) -p $(CLUSTER_NAME)
	@echo "$(GREEN)✅ Cluster created!$(NC)"

deploy-apps: ## Deploy applications
	@echo "$(YELLOW)📦 Deploying applications...$(NC)"
	@echo "$(YELLOW)Step 1: Deploying basic infrastructure...$(NC)"
	cd terraform && terraform apply  -auto-approve -target=helm_release.argocd -target=kubernetes_secret.github_repo -target=kubernetes_secret.ghcr_secret -target=helm_release.external_secrets -target=time_sleep.wait_external_secrets_crds -target=kubernetes_role.eso_read_secrets_argocd -target=kubernetes_role_binding.eso_read_secrets_argocd
	@echo "$(YELLOW)Step 2: Deploying applications...$(NC)"
	cd terraform && terraform apply  -auto-approve -target=kubernetes_manifest.app_of_apps -target=kubernetes_manifest.cluster_secret_store_k8s -target=helm_release.updater
	@echo "$(GREEN)✅ Applications deployed!$(NC)"

destroy: ## Destroy cluster and all applications
	@echo "$(YELLOW)🗑️  Removing applications...$(NC)"
	cd terraform && terraform destroy  -auto-approve -target=kubernetes_manifest.app_of_apps -target=kubernetes_manifest.cluster_secret_store_k8s -target=helm_release.updater
	cd terraform && terraform destroy  -auto-approve -target=helm_release.argocd -target=kubernetes_secret.github_repo -target=kubernetes_secret.ghcr_secret -target=helm_release.external_secrets -target=time_sleep.wait_external_secrets_crds -target=kubernetes_role.eso_read_secrets_argocd -target=kubernetes_role_binding.eso_read_secrets_argocd
	@echo "$(YELLOW)🗑️  Destroying cluster...$(NC)"
	minikube delete -p $(CLUSTER_NAME)
	@echo "$(GREEN)✅ Cluster and applications destroyed!$(NC)"
