# 🚀 Использование Helm чарта webserver-app

## 📋 Быстрый старт

### 1. Проверка чарта
```bash
cd /Users/grigoriypershin/Documents/temp/minicube
helm lint helm
helm template webserver-app helm --dry-run
```

### 2. Установка в development
```bash
# Создание namespace
kubectl create namespace development

# Установка с dev конфигурацией
helm install webserver-app-dev helm \
  --namespace development \
  -f helm/values-dev.yaml
```

### 3. Установка в production
```bash
# Создание namespace
kubectl create namespace production

# Установка с prod конфигурацией
helm install webserver-app-prod helm \
  --namespace production \
  -f helm/values-prod.yaml \
  --set ingress.hosts[0].host=your-domain.com
```

## 🔧 Основные команды

### Проверка статуса
```bash
# Поды
kubectl get pods -l app.kubernetes.io/instance=webserver-app-dev

# Сервисы
kubectl get svc -l app.kubernetes.io/instance=webserver-app-dev

# Ingress
kubectl get ingress -l app.kubernetes.io/instance=webserver-app-dev
```

### Логи
```bash
# Backend
kubectl logs -l app.kubernetes.io/component=backend -f

# Frontend
kubectl logs -l app.kubernetes.io/component=frontend -f
```

### Доступ к приложению
```bash
# Port-forward для локального доступа
kubectl port-forward svc/webserver-app-dev-frontend 3000:80
kubectl port-forward svc/webserver-app-dev-backend 8000:8000

# Доступ:
# Frontend: http://localhost:3000
# Backend: http://localhost:8000
```

### Обновление
```bash
helm upgrade webserver-app-dev helm -f helm/values-dev.yaml
```

### Удаление
```bash
helm uninstall webserver-app-dev --namespace development
```

## 📊 Конфигурации

### Development (values-dev.yaml)
- **Реплики**: 1 для каждого сервиса
- **Ресурсы**: минимальные
- **Ingress**: отключен
- **Сервисы**: NodePort для прямого доступа
- **Автоскейлинг**: отключен

### Production (values-prod.yaml)
- **Реплики**: 3 для каждого сервиса
- **Ресурсы**: увеличенные
- **Ingress**: включен с SSL
- **Сервисы**: ClusterIP
- **Автоскейлинг**: включен
- **Мониторинг**: ServiceMonitor для Prometheus

## 🎯 Особенности

- **Микросервисная архитектура**: отдельные деплойменты для frontend и backend
- **Health checks**: liveness и readiness пробы для обоих сервисов
- **Автомасштабирование**: HPA на основе CPU утилизации
- **Безопасность**: ServiceAccount, SecurityContext
- **Мониторинг**: готовность к интеграции с Prometheus
- **Гибкость**: легко настраивается через values файлы

## 🔗 Ссылки

- **Frontend**: React приложение с TypeScript
- **Backend**: FastAPI приложение на Python
- **Ingress**: Nginx Ingress Controller
- **База данных**: не требуется (in-memory storage)

---

**Готово к использованию! 🎉**
