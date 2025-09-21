# 🚨 Быстрое исправление ошибки аутентификации

## Проблема
```
Failed to load target state: failed to generate manifest for source 1 of 1:
rpc error: code = Unknown desc = authentication required
```

## 🔧 Быстрое решение

### 1. Создать GitHub Personal Access Token

1. GitHub → **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
2. **Generate new token** → **Generate new token (classic)**
3. Настройки:
   - **Note**: `ArgoCD webserver-app-infra`
   - **Expiration**: `90 days`
   - **Scopes**: ✅ `repo`, ✅ `read:org`
4. Скопируйте токен (начинается с `ghp_`)

### 2. Настроить аутентификацию

#### Вариант A: Автоматический скрипт
```bash
cd /Users/grigoriypershin/Documents/temp/minicube
./setup-github-auth.sh YOUR_GITHUB_TOKEN
```

#### Вариант B: Ручная настройка
```bash
# Создать Secret для ArgoCD
kubectl create secret generic webserver-app-repo \
  --namespace=argocd \
  --from-literal=type=git \
  --from-literal=url=https://github.com/vigregus/webserver-app-infra.git \
  --from-literal=username=vigregus \
  --from-literal=password=YOUR_GITHUB_TOKEN

# Добавить метку для ArgoCD
kubectl label secret webserver-app-repo \
  --namespace=argocd \
  argocd.argoproj.io/secret-type=repository
```

### 3. Проверить настройку

```bash
# Проверить Secret
kubectl get secret webserver-app-repo -n argocd

# Проверить в ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Откройте https://localhost:8080 → Settings → Repositories
```

### 4. Синхронизировать приложения

```bash
# Синхронизация через ArgoCD CLI
argocd app sync webserver-app-dev
argocd app sync webserver-app-prod

# Или через kubectl
kubectl get applications -n argocd
```

## ✅ Проверка успеха

После настройки аутентификации:
- ArgoCD UI покажет статус репозитория как **Connected**
- Приложения синхронизируются без ошибок
- В логах ArgoCD не будет ошибок аутентификации

## 🆘 Если не помогло

1. **Проверьте токен**: убедитесь, что токен имеет права `repo` и `read:org`
2. **Проверьте репозиторий**: убедитесь, что репозиторий существует и доступен
3. **Проверьте ArgoCD**: убедитесь, что ArgoCD запущен и работает
4. **Проверьте логи**: `kubectl logs -n argocd deployment/argocd-application-controller`

---

**После выполнения этих шагов ArgoCD сможет синхронизировать приложения! 🎉**
