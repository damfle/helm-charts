# Shlink Web Client UI Helm Chart

A Helm chart for deploying Shlink Web Client UI on Kubernetes

## Description

[Shlink Web Client](https://github.com/shlinkio/shlink-web-client) is the official web-based user interface for managing Shlink URL shortener instances. It provides a modern, responsive interface for creating short URLs, viewing analytics, managing domains, and configuring your Shlink servers.

## 🚀 Features

- **Modern UI**: Clean, responsive web interface
- **Multiple Servers**: Manage multiple Shlink instances from one UI
- **Real-time Analytics**: Live visitor statistics and charts
- **QR Code Generation**: Automatic QR codes for short URLs
- **Tag Management**: Organize URLs with tags
- **Dark/Light Theme**: Automatic theme switching
- **Mobile Friendly**: Optimized for mobile devices

## 📋 Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- Running Shlink server instance
- Shlink API key for authentication

## 🔧 Installation

### Add the Helm repository

```bash
helm repo add damfle https://damfle.github.io/helm-charts
helm repo update
```

### Install the chart

```bash
helm install shlink-ui damfle/shlink-ui
```

### Install with custom values

```bash
helm install shlink-ui damfle/shlink-ui -f values.yaml
```

## ⚙️ Configuration

The following table lists the configurable parameters and their default values.

### Generic Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `generic.image.repository` | Shlink UI image repository | `ghcr.io/shlinkio/shlink-web-client` |
| `generic.image.tag` | Shlink UI image tag | Uses `appVersion` from Chart.yaml |
| `generic.image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `generic.replicaCount` | Number of replicas | `1` |
| `generic.service.type` | Service type | `ClusterIP` |
| `generic.service.port` | Service port | `80` |
| `generic.service.targetPort` | Container port | `8080` |

### Shlink Server Configuration

Environment variables are typically provided via Kubernetes secrets using `envFrom`:

| Secret Key | Description | Example Value |
|-----------|-------------|---------|
| `SHLINK_SERVER_NAME` | Display name for Shlink server | `My Shlink Server` |
| `SHLINK_SERVER_URL` | Shlink server URL | `https://short.yourdomain.com` |
| `SHLINK_SERVER_API_KEY` | Shlink API key | `your-api-key-here` |

### Resources

| Parameter | Description | Default |
|-----------|-------------|---------|
| `generic.resources.limits.cpu` | CPU limit | `500m` |
| `generic.resources.limits.memory` | Memory limit | `500Mi` |
| `generic.resources.requests.cpu` | CPU request | `50m` |
| `generic.resources.requests.memory` | Memory request | `128Mi` |

### Ingress

| Parameter | Description | Default |
|-----------|-------------|---------|
| `generic.ingress.enabled` | Enable ingress | `true` |
| `generic.ingress.className` | Ingress class name | `traefik` |
| `generic.ingress.hosts[0].host` | Ingress hostname | `shlink-ui.example.com` |

### UI-Specific Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `shlinkui.servers[].apiKeySecret.name` | Secret name for API key | `""` |
| `shlinkui.servers[].apiKeySecret.key` | Secret key for API key | `""` |
| `shlinkui.theme.mode` | Theme mode (light/dark/auto) | `auto` |
| `shlinkui.theme.primaryColor` | Primary color scheme | `#007bff` |
| `shlinkui.features.qrCodes` | Enable QR code generation | `true` |
| `shlinkui.features.realTimeUpdates` | Enable real-time updates | `true` |
| `shlinkui.features.charts` | Enable analytics charts | `true` |
| `shlinkui.settings.itemsPerPage` | Default items per page | `20` |

## 🛠️ Examples

### Basic Installation with Secret Configuration

```yaml
# values.yaml
generic:
  envFrom:
    - secretRef:
        name: shlink-ui-secrets  # Contains server configuration
  
  ingress:
    enabled: true
    annotations:
      traefik.ingress.kubernetes.io/router.entrypoints: web,websecure
      traefik.ingress.kubernetes.io/router.middlewares: authentik-ak-outpost-authentik-embedded-outpost@kubernetescrd
    hosts:
      - host: shlink-ui.yourdomain.com
        paths:
          - path: /
            pathType: Prefix
```

Create the secret:
```bash
kubectl create secret generic shlink-ui-secrets \
  --from-literal=SHLINK_SERVER_NAME="My Shlink" \
  --from-literal=SHLINK_SERVER_URL="https://short.yourdomain.com" \
  --from-literal=SHLINK_SERVER_API_KEY="your-shlink-api-key"
```

### Installation with Authentication Middleware

```yaml
# values.yaml
generic:
  envFrom:
    - secretRef:
        name: shlink-ui-secrets
  
  ingress:
    enabled: true
    annotations:
      traefik.ingress.kubernetes.io/router.entrypoints: web,websecure
      traefik.ingress.kubernetes.io/router.middlewares: authentik-ak-outpost-authentik-embedded-outpost@kubernetescrd
    hosts:
      - host: shlink-ui.yourdomain.com
        paths:
          - path: /
            pathType: Prefix
```

### Secure Multi-Server Configuration with Secrets

```yaml
# values.yaml
generic:
  env:
    - name: SHLINK_SERVER_NAME
      value: "Default Server"
    - name: SHLINK_SERVER_URL
      value: "https://shlink.yourdomain.com"
    - name: SHLINK_SERVER_API_KEY
      valueFrom:
        secretKeyRef:
          name: shlink-default-secret
          key: api-key

shlinkui:
  servers:
    - name: "production"
      url: "https://shlink-prod.yourdomain.com"
      apiKeySecret:
        name: "shlink-prod-secret"
        key: "api-key"
    - name: "staging"
      url: "https://shlink-staging.yourdomain.com"
      apiKeySecret:
        name: "shlink-staging-secret"
        key: "api-key"
```

Then create the secrets:
```bash
# Default server secret
kubectl create secret generic shlink-default-secret \
  --from-literal=api-key=default-api-key-here

# Production server secret
kubectl create secret generic shlink-prod-secret \
  --from-literal=api-key=prod-api-key-here

# Staging server secret
kubectl create secret generic shlink-staging-secret \
  --from-literal=api-key=staging-api-key-here
```

### Multi-Server Configuration

```yaml
# values.yaml
shlinkui:
  servers:
    - name: "Production"
      url: "https://short.yourdomain.com"
      apiKey: "prod-api-key"
    - name: "Staging"
      url: "https://short-staging.yourdomain.com"
      apiKey: "staging-api-key"
    - name: "Development"
      url: "https://short-dev.yourdomain.com"
      apiKey: "dev-api-key"
```

### Custom Theme Configuration

```yaml
# values.yaml
shlinkui:
  theme:
    mode: "dark"
    primaryColor: "#28a745"
  
  features:
    qrCodes: true
    realTimeUpdates: true
    charts: true
    tags: true
  
  settings:
    itemsPerPage: 50
    notifications: true
```

## 🔗 Connecting to Shlink Server

### Getting API Key from Shlink

If you have a running Shlink instance, you can generate an API key:

```bash
# Connect to your Shlink container/pod
kubectl exec -it deployment/shlink -- /bin/sh

# Generate a new API key
./vendor/bin/shlink api-key:generate

# Or list existing keys
./vendor/bin/shlink api-key:list
```

### Environment Variables Method

The simplest way to configure the connection:

```yaml
generic:
  env:
    - name: SHLINK_SERVER_NAME
      value: "My Shlink Server"
    - name: SHLINK_SERVER_URL
      value: "https://your-shlink-domain.com"
    - name: SHLINK_SERVER_API_KEY
      value: "your-api-key-here"
```

### Multiple Servers Method

For managing multiple Shlink instances:

```yaml
shlinkui:
  servers:
    - name: "Production"
      url: "https://prod.short.com"
      apiKey: "prod-key"
    - name: "Staging"
      url: "https://staging.short.com"
      apiKey: "staging-key"
```

## 🔒 Security Considerations

1. **API Key Security**: Store API keys securely using Kubernetes secrets
2. **HTTPS Only**: Always use HTTPS for both Shlink server and UI
3. **Authentication**: Consider adding authentication middleware (like Authentik)
4. **Network Policies**: Restrict network access between components
5. **Regular Updates**: Keep the UI updated to latest version

### Using Kubernetes Secrets for API Keys

There are two main ways to use secrets for API keys:

#### Method 1: Environment Variable with Secret Reference (Single Server)

```yaml
# values.yaml
generic:
  env:
    - name: SHLINK_SERVER_NAME
      value: "My Shlink"
    - name: SHLINK_SERVER_URL
      value: "https://shlink.example.com"
    - name: SHLINK_SERVER_API_KEY
      valueFrom:
        secretKeyRef:
          name: shlink-ui-secrets
          key: api-key
```

Create the secret:
```bash
kubectl create secret generic shlink-ui-secrets \
  --from-literal=api-key=your-actual-api-key
```

#### Method 2: Individual Server Secrets (Multiple Servers)

```yaml
# values.yaml
shlinkui:
  servers:
    - name: "production"
      url: "https://shlink-prod.example.com"
      apiKeySecret:
        name: "shlink-prod-secrets"
        key: "api-key"
    - name: "staging"
      url: "https://shlink-staging.example.com"
      apiKeySecret:
        name: "shlink-staging-secrets"
        key: "api-key"
```

Create individual secrets:
```bash
kubectl create secret generic shlink-prod-secrets \
  --from-literal=api-key=prod-api-key-here

kubectl create secret generic shlink-staging-secrets \
  --from-literal=api-key=staging-api-key-here
```

> **Note**: When using `apiKeySecret`, the chart will automatically mount and inject the secret values. Do not specify both `apiKey` and `apiKeySecret` for the same server.

## 🔍 Monitoring and Logs

### Viewing Logs

```bash
kubectl logs -f deployment/shlink-ui
```

### Health Checks

The Shlink UI serves on port 8080 and provides:

- Health endpoint: Available at the root path `/`
- Static assets: Served from the container

## 🚨 Troubleshooting

### Common Issues

1. **Cannot connect to Shlink server**
   - Verify Shlink server URL is accessible
   - Check API key validity
   - Ensure network connectivity between UI and server

2. **Authentication errors**
   - Verify API key is correct and active
   - Check Shlink server logs for authentication issues

3. **UI not loading**
   - Check if ingress is properly configured
   - Verify DNS resolution
   - Check container logs for errors

### Debug Commands

```bash
# Check pod status
kubectl get pods -l app.kubernetes.io/name=shlink-ui

# View pod logs
kubectl logs -l app.kubernetes.io/name=shlink-ui

# Check service endpoints
kubectl get endpoints shlink-ui

# Test connectivity to Shlink server
kubectl exec -it deployment/shlink-ui -- wget -qO- https://your-shlink-server/rest/health
```

### Configuration Validation

```bash
# Test Shlink server connectivity
curl -H "X-Api-Key: your-api-key" https://your-shlink-server/rest/v3/short-urls

# Check if API key works
curl -H "X-Api-Key: your-api-key" https://your-shlink-server/rest/health
```

## 📱 Usage

Once deployed, you can access the Shlink UI through your configured domain. The interface provides:

### Main Features

- **Dashboard**: Overview of your short URLs and statistics
- **Short URLs**: Create, edit, and manage short URLs
- **Analytics**: Detailed visit statistics and charts
- **Tags**: Organize URLs with custom tags
- **Domains**: Manage multiple domains
- **Settings**: Configure UI preferences

### Creating Short URLs

1. Navigate to "Short URLs" section
2. Click "Create short URL"
3. Enter the long URL
4. Optionally set custom short code, tags, and expiration
5. Click "Create"

### Viewing Analytics

1. Click on any short URL in the list
2. View detailed analytics including:
   - Visit count and timeline
   - Geographic distribution
   - Referrer information
   - Device and browser stats

## 🔄 Upgrading

### Upgrade the chart

```bash
helm upgrade shlink-ui damfle/shlink-ui
```

### Configuration Changes

The UI automatically picks up configuration changes through environment variables. For server list changes, a pod restart may be required.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This Helm chart is licensed under the ISC License.

## 🔗 Links

- [Shlink Web Client Repository](https://github.com/shlinkio/shlink-web-client)
- [Shlink Server Repository](https://github.com/shlinkio/shlink)
- [Shlink Documentation](https://shlink.io/documentation/)
- [Chart Repository](https://github.com/damfle/helm-charts)
