# 🚀 Деплой веб-приложения в Kubernetes

## 📋 Предварительные требования

1. **Kubernetes кластер** (локальный или облачный)
2. **Helm 3.0+** установлен
3. **Nginx Ingress Controller** (для внешнего доступа)
4. **Docker образы** собраны и доступны в registry

## 🏗️ Подготовка образов

### 1. Сборка Docker образов

```bash
# Сборка образа бэкенда
cd /Users/grigoriypershin/Documents/temp/webserver-app/app-backend
docker build -t webserver-app-backend:latest .

# Сборка образа фронтенда
cd /Users/grigoriypershin/Documents/temp/webserver-app/app-frontend
docker build -t webserver-app-frontend:latest .
```

### 2. Загрузка в registry (опционально)

```bash
# Для Docker Hub
docker tag webserver-app-backend:latest your-username/webserver-app-backend:latest
docker tag webserver-app-frontend:latest your-username/webserver-app-frontend:latest
docker push your-username/webserver-app-backend:latest
docker push your-username/webserver-app-frontend:latest

# Для локального registry
docker tag webserver-app-backend:latest localhost:5000/webserver-app-backend:latest
docker tag webserver-app-frontend:latest localhost:5000/webserver-app-frontend:latest
docker push localhost:5000/webserver-app-backend:latest
docker push localhost:5000/webserver-app-frontend:latest
```

## 🔧 Конфигурация Helm

### 1. Обновление values.yaml

Измените значения в `webserver-app/values.yaml`:

```yaml
backend:
  image:
    repository: your-registry/webserver-app-backend  # или localhost:5000/webserver-app-backend
    tag: "latest"

frontend:
  image:
    repository: your-registry/webserver-app-frontend  # или localhost:5000/webserver-app-frontend
    tag: "latest"
```

### 2. Настройка Ingress

Для внешнего доступа обновите:

```yaml
ingress:
  enabled: true
  hosts:
    - host: your-domain.com  # Замените на ваш домен
      paths:
        - path: /
          service: frontend
        - path: /api
          service: backend
```

## 🚀 Деплой

### 1. Проверка чарта

```bash
cd /Users/grigoriypershin/Documents/temp/minicube

# Линтинг
helm lint webserver-app

# Тест шаблонизации
helm template webserver-app webserver-app --dry-run
```

### 2. Установка в development

```bash
# Создание namespace
kubectl create namespace development

# Установка с dev конфигурацией
helm install webserver-app-dev webserver-app \
  --namespace development \
  -f webserver-app/values-dev.yaml \
  --set backend.image.repository=webserver-app-backend \
  --set frontend.image.repository=webserver-app-frontend
```

### 3. Установка в production

```bash
# Создание namespace
kubectl create namespace production

# Установка с prod конфигурацией
helm install webserver-app-prod webserver-app \
  --namespace production \
  -f webserver-app/values-prod.yaml \
  --set backend.image.repository=your-registry/webserver-app-backend \
  --set frontend.image.repository=your-registry/webserver-app-frontend \
  --set ingress.hosts[0].host=your-domain.com
```

## 📊 Мониторинг деплоя

### 1. Проверка статуса

```bash
# Проверка подов
kubectl get pods -n development -l app.kubernetes.io/instance=webserver-app-dev

# Проверка сервисов
kubectl get svc -n development -l app.kubernetes.io/instance=webserver-app-dev

# Проверка Ingress
kubectl get ingress -n development
```

### 2. Просмотр логов

```bash
# Логи бэкенда
kubectl logs -n development -l app.kubernetes.io/component=backend -f

# Логи фронтенда
kubectl logs -n development -l app.kubernetes.io/component=frontend -f
```

### 3. Доступ к приложению

#### Для development (NodePort)

```bash
# Получение NodePort для фронтенда
kubectl get svc webserver-app-dev-frontend -n development

# Получение NodePort для бэкенда
kubectl get svc webserver-app-dev-backend -n development

# Доступ через NodePort
# Frontend: http://<node-ip>:<frontend-nodeport>
# Backend: http://<node-ip>:<backend-nodeport>
```

#### Для production (Ingress)

```bash
# Добавьте запись в /etc/hosts (для тестирования)
echo "<ingress-ip> your-domain.com" | sudo tee -a /etc/hosts

# Доступ через Ingress
# Frontend: http://your-domain.com/
# Backend: http://your-domain.com/api
```

#### Port-forward для локального доступа

```bash
# Доступ к фронтенду
kubectl port-forward -n development svc/webserver-app-dev-frontend 3000:80

# Доступ к бэкенду
kubectl port-forward -n development svc/webserver-app-dev-backend 8000:8000

# Теперь доступно:
# Frontend: http://localhost:3000
# Backend: http://localhost:8000
```

## 🔄 Обновление приложения

### 1. Обновление образов

```bash
# Обновление образа
docker build -t webserver-app-backend:v1.1.0 .
docker push your-registry/webserver-app-backend:v1.1.0

# Обновление деплоя
helm upgrade webserver-app-dev webserver-app \
  --namespace development \
  -f webserver-app/values-dev.yaml \
  --set backend.image.tag=v1.1.0
```

### 2. Откат

```bash
# Просмотр истории релизов
helm history webserver-app-dev -n development

# Откат к предыдущей версии
helm rollback webserver-app-dev 1 -n development
```

## 🗑️ Удаление

```bash
# Удаление релиза
helm uninstall webserver-app-dev -n development

# Удаление namespace (опционально)
kubectl delete namespace development
```

## 🐛 Troubleshooting

### Поды не запускаются

```bash
# Детальная информация о поде
kubectl describe pod <pod-name> -n development

# Проверка событий
kubectl get events -n development --sort-by='.lastTimestamp'
```

### Проблемы с образами

```bash
# Проверка доступности образа
kubectl get pods -n development -o wide

# Проверка ImagePullBackOff
kubectl describe pod <pod-name> -n development | grep -A 10 "Events:"
```

### Проблемы с сетью

```bash
# Проверка сервисов и эндпоинтов
kubectl get svc,endpoints -n development

# Проверка DNS
kubectl run test-pod --image=busybox --rm -it --restart=Never -- nslookup webserver-app-dev-backend
```

### Проблемы с Ingress

```bash
# Проверка Ingress контроллера
kubectl get pods -n ingress-nginx

# Проверка конфигурации Ingress
kubectl describe ingress webserver-app-dev -n development
```

## 📚 Дополнительные ресурсы

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)
- [Nginx Ingress Controller](https://kubernetes.github.io/ingress-nginx/)

---

**Готово! Ваше приложение развернуто в Kubernetes! 🎉**
