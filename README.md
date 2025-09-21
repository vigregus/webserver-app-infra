# 🚀 Minikube Infrastructure

Infrastructure as Code для развертывания ArgoCD в Minikube с использованием Terraform и Helm.

## 📁 Структура проекта

```
minicube/
├── terraform/              # Terraform конфигурация
│   ├── main.tf            # Основная конфигурация
│   ├── variables.tf       # Объявление переменных
│   ├── var.tfvars         # Значения переменных
│   └── .tflint.hcl        # Конфигурация TFLint
├── git-app.yaml           # ArgoCD Application (Git)
├── root-app.yaml          # ArgoCD Application (Root)
├── .pre-commit-config.yaml # Pre-commit хуки
├── .yamllint              # Конфигурация YAML линтера
├── .secrets.baseline      # Baseline для detect-secrets
└── Makefile              # Команды для линтинга и CI/CD
```

## 🛠️ Установка линтеров

```bash
# Установить все линтеры
make install-linters

# Или установить вручную
brew install tflint helm pre-commit
pip install detect-secrets
```

## 🔍 Линтинг

### Terraform
```bash
# Форматирование
make fmt-tf

# Валидация
make validate-tf

# Линтинг с TFLint
make lint-tf
```

### Helm
```bash
# Валидация Helm charts
make validate-helm

# Линтинг Helm charts
make lint-helm
```

### Все сразу
```bash
# Форматирование всего
make fmt

# Валидация всего
make validate

# Линтинг всего
make lint
```

## 🪝 Pre-commit хуки

```bash
# Настроить pre-commit хуки
make setup-hooks

# Запустить на всех файлах
make pre-commit-all
```

Pre-commit хуки автоматически запускают:
- `terraform fmt` - форматирование Terraform
- `terraform validate` - валидация Terraform
- `tflint` - линтинг Terraform
- `yamllint` - линтинг YAML файлов
- `detect-secrets` - поиск секретов в коде
- `kubeval` - валидация Kubernetes манифестов

## 🚀 CI/CD Pipeline

```bash
# Запустить полный CI pipeline
make ci

# Development workflow
make dev
```

## 🔒 Безопасность

```bash
# Сканирование на секреты
make security

# Использовать инструменты:
# - tfsec (Terraform security)
# - checkov (Infrastructure security)
# - kube-score (Kubernetes security)
```

## 📋 Доступные команды

```bash
make help                    # Показать справку
make install-linters         # Установить линтеры
make lint                    # Линтинг всего
make fmt                     # Форматирование всего
make validate                # Валидация всего
make clean                   # Очистка временных файлов
make ci                      # CI pipeline
make dev                     # Development workflow
```

## 🎯 Terraform команды

```bash
# Инициализация
cd terraform && terraform init

# План
terraform plan -var-file="var.tfvars"

# Применение
terraform apply -var-file="var.tfvars"

# Уничтожение
terraform destroy -var-file="var.tfvars"
```

## 🔧 Конфигурация линтеров

### TFLint (.tflint.hcl)
- Проверка синтаксиса Terraform
- Проверка deprecated функций
- Проверка naming conventions
- Kubernetes и Helm правила

### YAML Lint (.yamllint)
- Проверка синтаксиса YAML
- Проверка отступов
- Проверка длины строк
- Специальные правила для Helm

### Pre-commit (.pre-commit-config.yaml)
- Автоматическое форматирование
- Валидация перед коммитом
- Проверка секретов
- Проверка Kubernetes манифестов

## 🚨 Troubleshooting

### TFLint не работает
```bash
cd terraform
tflint --init
tflint
```

### Pre-commit не работает
```bash
pre-commit clean
pre-commit install
```

### Helm линтер не работает
```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
```

## 📚 Полезные ссылки

- [Terraform Best Practices](https://www.terraform.io/docs/language/files/index.html)
- [TFLint Rules](https://github.com/terraform-linters/tflint/tree/master/docs/rules)
- [Helm Best Practices](https://helm.sh/docs/chart_best_practices/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Pre-commit Hooks](https://pre-commit.com/hooks.html)
