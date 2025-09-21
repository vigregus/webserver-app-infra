# 🔐 Настройка аутентификации ArgoCD с GitHub

## 🚨 Проблема

Ошибка `authentication required` возникает, когда ArgoCD не может получить доступ к GitHub репозиторию из-за отсутствия аутентификации.

## 🔧 Решения

### Вариант 1: Personal Access Token (Рекомендуется)

#### 1. Создание GitHub Token

1. Перейдите в **GitHub** → **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
2. Нажмите **Generate new token** → **Generate new token (classic)**
3. Настройте токен:
   - **Note**: `ArgoCD webserver-app-infra`
   - **Expiration**: `90 days` (или по вашему выбору)
   - **Scopes**: выберите:
     - ✅ `repo` (Full control of private repositories)
     - ✅ `read:org` (Read org and team membership)

4. Скопируйте созданный токен

#### 2. Создание Secret в Kubernetes

```bash
# Создать Secret с токеном
kubectl create secret generic webserver-app-repo \
  --namespace=argocd \
  --from-literal=type=git \
  --from-literal=url=https://github.com/vigregus/webserver-app-infra.git \
  --from-literal=username=vigregus \
  --from-literal=password=YOUR_GITHUB_TOKEN
```

#### 3. Добавление метки для ArgoCD

```bash
# Добавить метку для распознавания ArgoCD
kubectl label secret webserver-app-repo \
  --namespace=argocd \
  argocd.argoproj.io/secret-type=repository
```

### Вариант 2: SSH ключ

#### 1. Генерация SSH ключа

```bash
# Генерация SSH ключа
ssh-keygen -t ed25519 -C "argocd@webserver-app" -f ~/.ssh/argocd_github

# Добавление в SSH агент
ssh-add ~/.ssh/argocd_github

# Копирование публичного ключа
cat ~/.ssh/argocd_github.pub
```

#### 2. Добавление ключа в GitHub

1. Перейдите в **GitHub** → **Settings** → **SSH and GPG keys**
2. Нажмите **New SSH key**
3. Вставьте содержимое публичного ключа
4. Сохраните

#### 3. Создание Secret с SSH ключом

```bash
# Создать Secret с SSH ключом
kubectl create secret generic webserver-app-repo-ssh \
  --namespace=argocd \
  --from-literal=type=git \
  --from-literal=url=git@github.com:vigregus/webserver-app-infra.git \
  --from-file=sshPrivateKey=~/.ssh/argocd_github

# Добавить метку для ArgoCD
kubectl label secret webserver-app-repo-ssh \
  --namespace=argocd \
  argocd.argoproj.io/secret-type=repository
```

### Вариант 3: Публичный репозиторий

Если репозиторий публичный, можно использовать пустую аутентификацию:

```bash
# Создать Secret для публичного репозитория
kubectl create secret generic webserver-app-repo-public \
  --namespace=argocd \
  --from-literal=type=git \
  --from-literal=url=https://github.com/vigregus/webserver-app-infra.git \
  --from-literal=username="" \
  --from-literal=password=""

# Добавить метку для ArgoCD
kubectl label secret webserver-app-repo-public \
  --namespace=argocd \
  argocd.argoproj.io/secret-type=repository
```

## 🔍 Проверка настройки

### 1. Проверить Secret

```bash
# Проверить созданные Secrets
kubectl get secrets -n argocd -l argocd.argoproj.io/secret-type=repository

# Проверить содержимое Secret
kubectl get secret webserver-app-repo -n argocd -o yaml
```

### 2. Проверить в ArgoCD UI

1. Откройте ArgoCD UI
2. Перейдите в **Settings** → **Repositories**
3. Убедитесь, что репозиторий отображается и имеет статус **Connected**

### 3. Проверить через ArgoCD CLI

```bash
# Список репозиториев
argocd repo list

# Тест подключения
argocd repo get https://github.com/vigregus/webserver-app-infra.git
```

## 🔄 Обновление приложений

После настройки аутентификации обновите приложения:

```bash
# Синхронизация приложений
argocd app sync webserver-app-dev
argocd app sync webserver-app-prod

# Или через kubectl
kubectl patch application webserver-app-dev -n argocd --type merge -p '{"operation":{"sync":{"syncStrategy":{"force":true}}}}'
```

## 🛠️ Troubleshooting

### Проблема: "repository not found"

```bash
# Проверить доступность репозитория
curl -H "Authorization: token YOUR_TOKEN" https://api.github.com/repos/vigregus/webserver-app-infra

# Проверить права доступа
curl -H "Authorization: token YOUR_TOKEN" https://api.github.com/user
```

### Проблема: "invalid credentials"

```bash
# Пересоздать Secret с правильными данными
kubectl delete secret webserver-app-repo -n argocd
kubectl create secret generic webserver-app-repo \
  --namespace=argocd \
  --from-literal=type=git \
  --from-literal=url=https://github.com/vigregus/webserver-app-infra.git \
  --from-literal=username=vigregus \
  --from-literal=password=YOUR_CORRECT_TOKEN
```

### Проблема: "SSL certificate verify failed"

```bash
# Для самоподписанных сертификатов
kubectl create secret generic webserver-app-repo \
  --namespace=argocd \
  --from-literal=type=git \
  --from-literal=url=https://github.com/vigregus/webserver-app-infra.git \
  --from-literal=username=vigregus \
  --from-literal=password=YOUR_TOKEN \
  --from-literal=insecure=true
```

## 🔒 Безопасность

### Рекомендации по безопасности

1. **Используйте минимальные права**: токен должен иметь только необходимые scope
2. **Ограничьте срок действия**: установите разумный срок действия токена
3. **Регулярно ротируйте**: обновляйте токены периодически
4. **Мониторьте использование**: следите за активностью токена в GitHub

### Мониторинг токенов

```bash
# Проверить активность токена
curl -H "Authorization: token YOUR_TOKEN" https://api.github.com/user/events
```

## 📝 Примеры использования

### Создание Secret через YAML

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: webserver-app-repo
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
type: Opaque
stringData:
  type: git
  url: https://github.com/vigregus/webserver-app-infra.git
  username: vigregus
  password: ghp_xxxxxxxxxxxxxxxxxxxx
```

### Проверка статуса через ArgoCD CLI

```bash
# Получить информацию о репозитории
argocd repo get https://github.com/vigregus/webserver-app-infra.git

# Список всех репозиториев
argocd repo list

# Добавить репозиторий через CLI
argocd repo add https://github.com/vigregus/webserver-app-infra.git \
  --username vigregus \
  --password YOUR_TOKEN
```

---

**После настройки аутентификации ArgoCD сможет синхронизировать приложения! 🎉**
