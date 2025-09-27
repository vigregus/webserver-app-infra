# Makefile для миникуб кластера
.PHONY: help create destroy

# Переменные
CLUSTER_NAME := multi
NODES := 4
MEMORY := 4096
CPUS := 2

# Цвета для вывода
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

help: ## Показать справку
	@echo "$(GREEN)Доступные команды:$(NC)"
	@echo "  create  - Создать миникуб кластер и развернуть приложения"
	@echo "  create-cluster  - Создать миникуб кластер"
	@echo "  deploy-apps - Развернуть приложения"
	@echo "  destroy - Уничтожить кластер и все приложения"

create: ## Создать кластер и развернуть приложения
	@echo "$(YELLOW)🚀 Создание миникуб кластера...$(NC)"
	minikube start --nodes=$(NODES) --addons=storage-provisioner --memory=$(MEMORY) --cpus=$(CPUS) -p $(CLUSTER_NAME)
	@echo "$(GREEN)✅ Кластер создан!$(NC)"
	@echo "$(YELLOW)📦 Развертывание приложений...$(NC)"
	@echo "$(YELLOW)Шаг 1: Развертывание базовой инфраструктуры...$(NC)"
	cd terraform && terraform apply  -auto-approve -target=helm_release.argocd -target=kubernetes_secret.github_repo -target=kubernetes_secret.ghcr_secret -target=helm_release.external_secrets -target=time_sleep.wait_external_secrets_crds -target=kubernetes_role.eso_read_secrets_argocd -target=kubernetes_role_binding.eso_read_secrets_argocd
	@echo "$(YELLOW)Шаг 2: Развертывание приложений...$(NC)"
	cd terraform && terraform apply  -auto-approve -target=kubernetes_manifest.app_of_apps -target=kubernetes_manifest.cluster_secret_store_k8s -target=helm_release.updater
	@echo "$(GREEN)✅ Приложения развернуты!$(NC)"
	@echo "$(YELLOW)📋 Информация для доступа:$(NC)"
	@echo "ArgoCD URL: http://localhost:8080"
	@echo "ArgoCD логин: admin"
	@echo -n "ArgoCD пароль: "
	@kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
	@echo ""
	@echo "$(YELLOW)🔗 Для доступа к ArgoCD выполните:$(NC)"
	@echo "kubectl port-forward -n argocd svc/argocd-server 8080:80"
	@echo ""
	@echo "$(YELLOW)📊 Для доступа к Grafana выполните:$(NC)"
	@echo "kubectl port-forward -n monitoring svc/vm-stack-grafana 3000:80"
	@echo "URL: http://localhost:3000"
	@echo "Логин: admin"
	@echo "Пароль: admin"



create-cluster: ## Создать миникуб кластер
	@echo "$(YELLOW)🚀 Создание миникуб кластера...$(NC)"
	minikube start --nodes=$(NODES) --addons=storage-provisioner --memory=$(MEMORY) --cpus=$(CPUS) -p $(CLUSTER_NAME)
	@echo "$(GREEN)✅ Кластер создан!$(NC)"

deploy-apps: ## Развернуть приложения
	@echo "$(YELLOW)📦 Развертывание приложений...$(NC)"
	@echo "$(YELLOW)Шаг 1: Развертывание базовой инфраструктуры...$(NC)"
	cd terraform && terraform apply  -auto-approve -target=helm_release.argocd -target=kubernetes_secret.github_repo -target=kubernetes_secret.ghcr_secret -target=helm_release.external_secrets -target=time_sleep.wait_external_secrets_crds -target=kubernetes_role.eso_read_secrets_argocd -target=kubernetes_role_binding.eso_read_secrets_argocd
	@echo "$(YELLOW)Шаг 2: Развертывание приложений...$(NC)"
	cd terraform && terraform apply  -auto-approve -target=kubernetes_manifest.app_of_apps -target=kubernetes_manifest.cluster_secret_store_k8s -target=helm_release.updater
	@echo "$(GREEN)✅ Приложения развернуты!$(NC)"

destroy: ## Уничтожить кластер и все приложения
	@echo "$(YELLOW)🗑️  Удаление приложений...$(NC)"
	cd terraform && terraform destroy  -auto-approve -target=kubernetes_manifest.app_of_apps -target=kubernetes_manifest.cluster_secret_store_k8s -target=helm_release.updater
	cd terraform && terraform destroy  -auto-approve -target=helm_release.argocd -target=kubernetes_secret.github_repo -target=kubernetes_secret.ghcr_secret -target=helm_release.external_secrets -target=time_sleep.wait_external_secrets_crds -target=kubernetes_role.eso_read_secrets_argocd -target=kubernetes_role_binding.eso_read_secrets_argocd
	@echo "$(YELLOW)🗑️  Уничтожение кластера...$(NC)"
	minikube delete -p $(CLUSTER_NAME)
	@echo "$(GREEN)✅ Кластер и приложения уничтожены!$(NC)"
