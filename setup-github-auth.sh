#!/bin/bash

# Скрипт для настройки аутентификации ArgoCD с GitHub репозиторием
# Использование: ./setup-github-auth.sh YOUR_GITHUB_TOKEN

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Функция для вывода сообщений
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Проверка аргументов
if [ $# -eq 0 ]; then
    log_error "Необходимо указать GitHub токен"
    echo "Использование: $0 YOUR_GITHUB_TOKEN"
    echo ""
    echo "Для создания токена:"
    echo "1. GitHub → Settings → Developer settings → Personal access tokens"
    echo "2. Generate new token (classic)"
    echo "3. Выберите scope: repo, read:org"
    exit 1
fi

GITHUB_TOKEN="$1"
REPO_URL="https://github.com/vigregus/webserver-app-infra.git"
SECRET_NAME="webserver-app-repo"
NAMESPACE="argocd"

log_info "Настройка аутентификации ArgoCD с GitHub репозиторием"
log_info "Репозиторий: $REPO_URL"
log_info "Secret: $SECRET_NAME"
log_info "Namespace: $NAMESPACE"

# Проверка существования namespace
if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
    log_error "Namespace '$NAMESPACE' не найден. Убедитесь, что ArgoCD установлен."
    exit 1
fi

# Проверка токена (базовая валидация)
if [[ ! "$GITHUB_TOKEN" =~ ^ghp_[a-zA-Z0-9]{36}$ ]] && [[ ! "$GITHUB_TOKEN" =~ ^github_pat_[a-zA-Z0-9_]{82}$ ]]; then
    log_warn "Токен не соответствует ожидаемому формату GitHub токена"
    log_warn "Продолжаем, но убедитесь, что токен корректный"
fi

# Удаление существующего Secret (если есть)
if kubectl get secret "$SECRET_NAME" -n "$NAMESPACE" >/dev/null 2>&1; then
    log_info "Удаление существующего Secret..."
    kubectl delete secret "$SECRET_NAME" -n "$NAMESPACE"
fi

# Создание нового Secret
log_info "Создание Secret для аутентификации..."

kubectl create secret generic "$SECRET_NAME" \
    --namespace="$NAMESPACE" \
    --from-literal=type=git \
    --from-literal=url="$REPO_URL" \
    --from-literal=username=vigregus \
    --from-literal=password="$GITHUB_TOKEN"

# Добавление метки для ArgoCD
log_info "Добавление метки для ArgoCD..."
kubectl label secret "$SECRET_NAME" \
    --namespace="$NAMESPACE" \
    argocd.argoproj.io/secret-type=repository \
    --overwrite

# Проверка создания Secret
if kubectl get secret "$SECRET_NAME" -n "$NAMESPACE" >/dev/null 2>&1; then
    log_info "✅ Secret успешно создан"
else
    log_error "❌ Ошибка при создании Secret"
    exit 1
fi

# Ожидание применения изменений
log_info "Ожидание применения изменений..."
sleep 5

# Проверка подключения репозитория
log_info "Проверка подключения к репозиторию..."

# Проверка через kubectl
if kubectl get secret "$SECRET_NAME" -n "$NAMESPACE" -o jsonpath='{.metadata.labels.argocd\.argoproj\.io/secret-type}' | grep -q "repository"; then
    log_info "✅ Secret правильно помечен как repository"
else
    log_warn "⚠️  Secret не имеет правильной метки"
fi

# Инструкции для дальнейших действий
echo ""
log_info "🎉 Настройка аутентификации завершена!"
echo ""
log_info "Следующие шаги:"
echo "1. Проверьте репозиторий в ArgoCD UI:"
echo "   kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "   Затем откройте https://localhost:8080 → Settings → Repositories"
echo ""
echo "2. Синхронизируйте приложения:"
echo "   argocd app sync webserver-app-dev"
echo "   argocd app sync webserver-app-prod"
echo ""
echo "3. Или через kubectl:"
echo "   kubectl get applications -n argocd"
echo ""

# Проверка ArgoCD CLI (если доступен)
if command -v argocd >/dev/null 2>&1; then
    log_info "Проверка через ArgoCD CLI..."
    if argocd repo list 2>/dev/null | grep -q "webserver-app-infra"; then
        log_info "✅ Репозиторий найден в ArgoCD CLI"
    else
        log_warn "⚠️  Репозиторий не найден в ArgoCD CLI. Возможно, нужна синхронизация."
    fi
else
    log_warn "ArgoCD CLI не найден. Установите для удобства управления:"
    echo "   brew install argocd  # macOS"
    echo "   curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64"
fi

log_info "Готово! 🚀"
