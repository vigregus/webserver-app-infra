# Webserver App Helm Chart

Этот Helm чарт предназначен для деплоя веб-приложения, состоящего из React фронтенда и FastAPI бэкенда в Kubernetes кластер.

## Структура приложения

- **Backend**: FastAPI приложение на Python, предоставляющее REST API
- **Frontend**: React приложение на TypeScript, обслуживаемое через Nginx
- **Ingress**: Nginx Ingress Controller для внешнего доступа

## Предварительные требования

- Kubernetes 1.19+
- Helm 3.0+
- Nginx Ingress Controller (для внешнего доступа)

## Установка

### Из локального чарта

```bash
# Добавить репозиторий (если используется)
helm repo add your-repo https://your-helm-repo.com
helm repo update

# Установить чарт
helm install webserver-app ./webserver-app

# Или с кастомными значениями
helm install webserver-app ./webserver-app -f values-prod.yaml
```

### Для разработки

```bash
helm install webserver-app ./webserver-app -f values-dev.yaml
```

## Конфигурация

### Основные параметры

| Параметр | Описание | Значение по умолчанию |
|----------|----------|----------------------|
| `backend.enabled` | Включить бэкенд | `true` |
| `frontend.enabled` | Включить фронтенд | `true` |
| `backend.replicaCount` | Количество реплик бэкенда | `2` |
| `frontend.replicaCount` | Количество реплик фронтенда | `2` |
| `ingress.enabled` | Включить Ingress | `true` |

### Ресурсы

```yaml
backend:
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 250m
      memory: 256Mi

frontend:
  resources:
    limits:
      cpu: 200m
      memory: 256Mi
    requests:
      cpu: 100m
      memory: 128Mi
```

### Автомасштабирование

```yaml
backend:
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 10
    targetCPUUtilizationPercentage: 80
```

### Ingress

```yaml
ingress:
  enabled: true
  className: "nginx"
  hosts:
    - host: your-domain.com
      paths:
        - path: /
          service: frontend
        - path: /api
          service: backend
```

## Примеры использования

### Развертывание в development

```bash
helm install webserver-app-dev ./webserver-app \
  --namespace development \
  --create-namespace \
  -f values-dev.yaml
```

### Развертывание в production

```bash
helm install webserver-app-prod ./webserver-app \
  --namespace production \
  --create-namespace \
  -f values-prod.yaml \
  --set ingress.hosts[0].host=your-domain.com
```

### Обновление приложения

```bash
helm upgrade webserver-app ./webserver-app -f values-prod.yaml
```

### Удаление

```bash
helm uninstall webserver-app
```

## Мониторинг

### Проверка статуса

```bash
# Проверить поды
kubectl get pods -l app.kubernetes.io/instance=webserver-app

# Проверить сервисы
kubectl get svc -l app.kubernetes.io/instance=webserver-app

# Проверить Ingress
kubectl get ingress -l app.kubernetes.io/instance=webserver-app
```

### Логи

```bash
# Логи бэкенда
kubectl logs -l app.kubernetes.io/component=backend -f

# Логи фронтенда
kubectl logs -l app.kubernetes.io/component=frontend -f
```

### Доступ к приложению

После установки приложение будет доступно по адресу, указанному в Ingress. Для локального тестирования можно использовать port-forward:

```bash
# Доступ к фронтенду
kubectl port-forward svc/webserver-app-frontend 3000:80

# Доступ к бэкенду
kubectl port-forward svc/webserver-app-backend 8000:8000
```

## Troubleshooting

### Поды не запускаются

1. Проверьте образы:
```bash
kubectl describe pod <pod-name>
```

2. Проверьте ресурсы:
```bash
kubectl top pods
```

### Проблемы с Ingress

1. Убедитесь, что установлен Nginx Ingress Controller
2. Проверьте аннотации Ingress
3. Проверьте DNS настройки

### Проблемы с подключением между сервисами

1. Проверьте Service Discovery:
```bash
kubectl get endpoints
```

2. Проверьте сетевые политики:
```bash
kubectl get networkpolicies
```

## Кастомизация

### Добавление переменных окружения

```yaml
backend:
  env:
    - name: CUSTOM_VAR
      value: "custom-value"
    - name: SECRET_VAR
      valueFrom:
        secretKeyRef:
          name: my-secret
          key: secret-key
```

### Настройка health checks

```yaml
backend:
  healthCheck:
    enabled: true
    path: "/health"
    initialDelaySeconds: 30
    periodSeconds: 10
```

### Настройка Persistent Volumes

```yaml
persistence:
  enabled: true
  storageClass: "fast-ssd"
  size: 10Gi
```

## Безопасность

### Service Account

```yaml
serviceAccount:
  create: true
  name: "webserver-app-sa"
  annotations:
    eks.amazonaws.com/role-arn: "arn:aws:iam::ACCOUNT:role/webserver-app-role"
```

### Security Context

```yaml
podSecurityContext:
  fsGroup: 2000
  runAsNonRoot: true
  runAsUser: 1000

securityContext:
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  capabilities:
    drop:
    - ALL
```

## Лицензия

MIT
