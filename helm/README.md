# Webserver App Helm Chart

This Helm chart is designed for deploying a web application consisting of a React frontend and FastAPI backend to a Kubernetes cluster.

## Application Structure

- **Backend**: FastAPI Python application providing REST API
- **Frontend**: React TypeScript application served via Nginx
- **Ingress**: Nginx Ingress Controller for external access

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- Nginx Ingress Controller (for external access)

## Installation

### From local chart

```bash
# Add repository (if used)
helm repo add your-repo https://your-helm-repo.com
helm repo update

# Install chart
helm install webserver-app ./webserver-app

# Or with custom values
helm install webserver-app ./webserver-app -f values-prod.yaml
```

### For development

```bash
helm install webserver-app ./webserver-app -f values-dev.yaml
```

## Configuration

### Main parameters

| Parameter | Description | Default value |
|----------|----------|----------------------|
| `backend.enabled` | Enable backend | `true` |
| `frontend.enabled` | Enable frontend | `true` |
| `backend.replicaCount` | Number of backend replicas | `2` |
| `frontend.replicaCount` | Number of frontend replicas | `2` |
| `ingress.enabled` | Enable Ingress | `true` |

### Resources

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

### Autoscaling

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

## Usage Examples

### Deployment in development

```bash
helm install webserver-app-dev ./webserver-app \
  --namespace development \
  --create-namespace \
  -f values-dev.yaml
```

### Deployment in production

```bash
helm install webserver-app-prod ./webserver-app \
  --namespace production \
  --create-namespace \
  -f values-prod.yaml \
  --set ingress.hosts[0].host=your-domain.com
```

### Application update

```bash
helm upgrade webserver-app ./webserver-app -f values-prod.yaml
```

### Removal

```bash
helm uninstall webserver-app
```

## Monitoring

### Status check

```bash
# Check pods
kubectl get pods -l app.kubernetes.io/instance=webserver-app

# Check services
kubectl get svc -l app.kubernetes.io/instance=webserver-app

# Check Ingress
kubectl get ingress -l app.kubernetes.io/instance=webserver-app
```

### Logs

```bash
# Backend logs
kubectl logs -l app.kubernetes.io/component=backend -f

# Frontend logs
kubectl logs -l app.kubernetes.io/component=frontend -f
```

### Application access

After installation, the application will be available at the address specified in Ingress. For local testing, you can use port-forward:

```bash
# Access to frontend
kubectl port-forward svc/webserver-app-frontend 3000:80

# Access to backend
kubectl port-forward svc/webserver-app-backend 8000:8000
```

## Troubleshooting

### Pods not starting

1. Check images:
```bash
kubectl describe pod <pod-name>
```

2. Check resources:
```bash
kubectl top pods
```

### Ingress issues

1. Make sure Nginx Ingress Controller is installed
2. Check Ingress annotations
3. Check DNS settings

### Service connection issues

1. Check Service Discovery:
```bash
kubectl get endpoints
```

2. Check network policies:
```bash
kubectl get networkpolicies
```

## Customization

### Adding environment variables

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

### Health checks configuration

```yaml
backend:
  healthCheck:
    enabled: true
    path: "/health"
    initialDelaySeconds: 30
    periodSeconds: 10
```

### Persistent Volumes configuration

```yaml
persistence:
  enabled: true
  storageClass: "fast-ssd"
  size: 10Gi
```

## Security

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

## License

MIT
