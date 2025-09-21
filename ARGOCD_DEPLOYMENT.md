# 🚀 Деплой через ArgoCD Application of Applications

## 📋 Предварительные требования

1. **ArgoCD** установлен в кластере
2. **GitHub репозиторий** доступен для ArgoCD
3. **RBAC** настроен для доступа к GitHub репозиторию

## 🏗️ Структура репозитория

Репозиторий `https://github.com/vigregus/webserver-app-infra.git` должен содержать:

```
webserver-app-infra/
├── helm/                    # Helm чарт
│   ├── Chart.yaml
│   ├── values.yaml         # Основные значения
│   ├── values-dev.yaml     # Development конфигурация
│   ├── values-prod.yaml    # Production конфигурация
│   └── templates/          # Kubernetes манифесты
└── argocd/                 # ArgoCD конфигурации
    ├── root-app.yaml       # Главное приложение
    ├── app-of-apps.yaml    # Приложения для разных окружений
    └── argocd-project.yaml # ArgoCD проект
```

## 🔧 Установка через ArgoCD

### 1. Создание ArgoCD проекта

```bash
# Применить ArgoCD проект
kubectl apply -f argocd-project.yaml

# Проверить создание проекта
kubectl get appprojects -n argocd
```

### 2. Создание главного приложения

```bash
# Применить главное приложение
kubectl apply -f root-app.yaml

# Проверить статус
kubectl get applications -n argocd
```

### 3. Создание приложений для окружений

```bash
# Применить приложения для dev/prod
kubectl apply -f app-of-apps.yaml

# Проверить все приложения
kubectl get applications -n argocd -l app.kubernetes.io/part-of=webserver-app
```

## 📊 Мониторинг через ArgoCD UI

### Доступ к ArgoCD UI

```bash
# Port-forward для доступа к UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Получить пароль администратора
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Открыть в браузере
open https://localhost:8080
```

### Проверка статуса приложений

1. **ArgoCD UI** → Applications
2. Проверить статус:
   - ✅ **Synced** - приложение синхронизировано
   - ⚠️ **OutOfSync** - есть изменения для синхронизации
   - ❌ **Error** - ошибка в деплое

## 🚀 Управление через ArgoCD CLI

### Установка ArgoCD CLI

```bash
# macOS
brew install argocd

# Linux
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
```

### Логин в ArgoCD

```bash
# Логин в ArgoCD
argocd login localhost:8080

# Список приложений
argocd app list

# Статус конкретного приложения
argocd app get webserver-app-dev
```

### Синхронизация приложений

```bash
# Синхронизация всех приложений проекта
argocd app sync --project webserver-app

# Синхронизация конкретного приложения
argocd app sync webserver-app-dev

# Принудительная синхронизация
argocd app sync webserver-app-dev --force
```

## 🔄 GitOps Workflow

### 1. Обновление кода

```bash
# Внести изменения в код приложения
cd /path/to/webserver-app
# ... изменения в коде ...

# Собрать новые образы
docker build -t webserver-app-backend:v1.1.0 ./app-backend
docker build -t webserver-app-frontend:v1.1.0 ./app-frontend

# Загрузить в registry
docker push your-registry/webserver-app-backend:v1.1.0
docker push your-registry/webserver-app-frontend:v1.1.0
```

### 2. Обновление Helm чарта

```bash
# Обновить версии образов в values.yaml
cd /path/to/webserver-app-infra/helm
# ... изменить tag в values.yaml ...

# Закоммитить изменения
git add .
git commit -m "Update app version to v1.1.0"
git push origin main
```

### 3. Автоматическая синхронизация

ArgoCD автоматически обнаружит изменения и синхронизирует приложения согласно настройкам `syncPolicy`.

## 🎯 Окружения

### Development

- **Namespace**: `development`
- **Values**: `values-dev.yaml`
- **Ресурсы**: минимальные
- **Синхронизация**: автоматическая

### Production

- **Namespace**: `production`
- **Values**: `values-prod.yaml`
- **Ресурсы**: увеличенные
- **Синхронизация**: с окнами обслуживания

## 🔒 Безопасность

### RBAC настройки

```yaml
# В argocd-project.yaml настроены роли:
# - webserver-app-admin: полный доступ
# - webserver-app-readonly: только чтение
```

### Sync Windows

```yaml
# Окна синхронизации для production:
# - Разрешено: ежедневно с 00:00 до 01:00
# - Запрещено: пятница 18:00 - понедельник 18:00
```

## 🐛 Troubleshooting

### Проблемы с синхронизацией

```bash
# Проверить события приложения
kubectl describe application webserver-app-dev -n argocd

# Проверить логи ArgoCD
kubectl logs -n argocd deployment/argocd-application-controller

# Проверить статус синхронизации
argocd app sync webserver-app-dev --dry-run
```

### Проблемы с доступом к репозиторию

```bash
# Проверить доступность репозитория
argocd repo get https://github.com/vigregus/webserver-app-infra.git

# Добавить репозиторий вручную
argocd repo add https://github.com/vigregus/webserver-app-infra.git
```

### Проблемы с Helm

```bash
# Проверить Helm чарт
argocd app get webserver-app-dev --show-params

# Проверить значения
argocd app get webserver-app-dev --show-params | grep -A 20 "helm:"
```

## 📈 Мониторинг и алерты

### Prometheus метрики

ArgoCD предоставляет метрики для Prometheus:

```yaml
# Пример ServiceMonitor
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: argocd-metrics
  namespace: argocd
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: argocd-metrics
  endpoints:
    - port: metrics
```

### Алерты

```yaml
# Пример алерта для ArgoCD
groups:
  - name: argocd
    rules:
      - alert: ArgoCDApplicationOutOfSync
        expr: argocd_app_info{sync_status!="Synced"} > 0
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "ArgoCD Application {{ $labels.name }} is out of sync"
```

## 🔗 Полезные ссылки

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [ArgoCD Best Practices](https://argo-cd.readthedocs.io/en/stable/operator-manual/)
- [GitOps Principles](https://www.gitops.tech/)

---

**Готово к GitOps деплою! 🎉**
