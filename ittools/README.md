# IT Tools Helm Chart

A Helm chart for deploying [IT Tools](https://github.com/CorentinTh/it-tools) - a collection of handy online tools for developers, with great UX.

This chart extends the [generic chart](../generic/README.md) to provide a ready-to-use IT Tools deployment with sensible defaults.

## Features

- 🛠️ **Developer Tools**: Collection of useful utilities for developers
- 📦 **Official Container**: Uses the `ghcr.io/corentinth/it-tools` container image
- 🚀 **Lightweight**: Stateless web application with minimal resource requirements
- 🔒 **Secure**: Runs as non-root user with read-only root filesystem
- 🌐 **Web Interface**: Clean, modern web interface accessible via browser
- 🚀 **Production Ready**: Health checks, resource limits, and security contexts
- 🔧 **Zero Configuration**: Works out of the box with no additional setup

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- Ingress controller (optional, for external access)

## Installation

### Add the repository

```bash
helm repo add damfle https://damfle.github.io/helm-charts
helm repo update
```

### Install the chart

```bash
# Basic installation
helm install ittools damfle/ittools

# With custom values
helm install ittools damfle/ittools -f values.yaml

# With inline values for external access
helm install ittools damfle/ittools \
  --set generic.ingress.enabled=true \
  --set generic.ingress.hosts[0].host=tools.example.com
```

## Configuration

### Basic Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `generic.image.repository` | IT Tools image repository | `ghcr.io/corentinth/it-tools` |
| `generic.image.tag` | IT Tools image tag | `2024.10.22-7ca5933` |
| `generic.service.port` | Service port | `80` |
| `generic.persistence.enabled` | Enable persistent storage | `false` |
| `generic.resources.requests.memory` | Memory request | `64Mi` |
| `generic.resources.limits.memory` | Memory limit | `128Mi` |

### Advanced Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `generic.ingress.enabled` | Enable ingress | `false` |
| `generic.replicaCount` | Number of replicas | `1` |
| `generic.securityContext.runAsUser` | User ID | `1000` |
| `generic.securityContext.readOnlyRootFilesystem` | Read-only root filesystem | `true` |
| `generic.resources.requests.cpu` | CPU request | `50m` |
| `generic.resources.limits.cpu` | CPU limit | `100m` |

## Network Access

### ClusterIP (Default)

Access IT Tools within the cluster:

```bash
kubectl port-forward svc/ittools 8080:80
# Access via http://localhost:8080
```

### Ingress (Recommended)

Enable external access via ingress:

```yaml
generic:
  ingress:
    enabled: true
    className: "nginx"
    hosts:
      - host: tools.example.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: ittools-tls
        hosts:
          - tools.example.com
```

### Traefik Configuration

For Traefik ingress (as per your setup):

```yaml
generic:
  ingress:
    enabled: true
    annotations:
      traefik.ingress.kubernetes.io/router.entrypoints: web,websecure
    hosts:
      - host: tools.example.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - hosts:
        - tools.example.com
```

## Available Tools

IT Tools includes a wide variety of developer utilities:

### **Converters**
- JSON ⟷ YAML
- Base64 encode/decode
- URL encode/decode
- HTML encode/decode
- Markdown to HTML
- Case converter

### **Web Tools**
- QR Code generator
- Lorem ipsum generator
- Password generator
- Hash generator (MD5, SHA1, SHA256, etc.)
- JWT decoder
- URL shortener

### **Network Tools**
- IP address lookup
- User agent parser
- Device information
- Basic auth generator

### **Text Tools**
- Text diff
- String utilities
- Regex tester
- Unicode converter

### **Crypto Tools**
- Hash functions
- HMAC generator
- RSA key pair generator
- Certificate decoder

## Usage Examples

### Basic Deployment

```yaml
# values.yaml
generic:
  securityContext:
    runAsNonRoot: false
    runAsUser: 0
    fsGroup: 0
    allowPrivilegeEscalation: true
    readOnlyRootFilesystem: false

  podSecurityContext:
    runAsNonRoot: false
    runAsUser: 0
    fsGroup: 0

  ingress:
    enabled: true
    hosts:
      - host: tools.yourdomain.com
        paths:
          - path: /
            pathType: Prefix
```

### High Availability Setup

```yaml
# Multiple replicas for high availability
generic:
  replicaCount: 3
  
  # Anti-affinity to spread pods across nodes
  affinity:
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: app.kubernetes.io/name
              operator: In
              values:
              - ittools
          topologyKey: kubernetes.io/hostname

  # Resource limits for production
  resources:
    requests:
      memory: "128Mi"
      cpu: "100m"
    limits:
      memory: "256Mi"
      cpu: "200m"
```

### External Access Configuration

```yaml
# Full external access setup
generic:
  ingress:
    enabled: true
    className: "nginx"
    annotations:
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
      cert-manager.io/cluster-issuer: "letsencrypt-prod"
    hosts:
      - host: devtools.company.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: ittools-tls
        hosts:
          - devtools.company.com
```

## Security Considerations

- **Read-only filesystem**: Root filesystem is mounted read-only for security
- **Non-root user**: Runs as user ID 1000
- **No network policies**: Consider adding network policies for production
- **HTTPS**: Use TLS/SSL for external access
- **No persistent data**: Stateless application with no data persistence

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods -l app.kubernetes.io/name=ittools
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Verify Service

```bash
kubectl get svc ittools
kubectl port-forward svc/ittools 8080:80
curl http://localhost:8080/
```

### Common Issues

1. **Pod stuck in Pending**: Check resource quotas and node capacity
2. **Image pull errors**: Verify image repository and tag
3. **Health check failures**: Check if the application starts correctly
4. **Ingress not working**: Verify ingress controller and DNS configuration

## Performance Tuning

### Resource Optimization

```yaml
# Minimal resources for development
generic:
  resources:
    requests:
      memory: "32Mi"
      cpu: "25m"
    limits:
      memory: "64Mi"
      cpu: "50m"

# Production resources
generic:
  resources:
    requests:
      memory: "128Mi"
      cpu: "100m"
    limits:
      memory: "256Mi"
      cpu: "200m"
```

### Scaling

```yaml
# Horizontal scaling
generic:
  replicaCount: 3
```

## Upgrading

```bash
# Check current version
helm list

# Upgrade to latest version
helm upgrade ittools damfle/ittools

# Upgrade with new values
helm upgrade ittools damfle/ittools -f new-values.yaml
```

## Uninstalling

```bash
helm uninstall ittools
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the chart
5. Submit a pull request

## License

This chart is licensed under the ISC License. See the [LICENSE](../LICENSE) file for details.

## Links

- [IT Tools Repository](https://github.com/CorentinTh/it-tools)
- [IT Tools Demo](https://it-tools.tech)
- [Generic Chart Documentation](../generic/README.md)
