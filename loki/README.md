# Loki Helm Chart

A Helm chart for deploying [Grafana Loki](https://grafana.com/oss/loki/) - a horizontally-scalable, highly-available, multi-tenant log aggregation system inspired by Prometheus.

This chart extends the [generic chart](../generic/README.md) to provide a ready-to-use Loki deployment with sensible defaults.

## Features

- 🔍 **Single Instance Deployment**: Configured for simple, single-instance Loki setup
- 📦 **Official Container**: Uses the official `grafana/loki` container image
- 💾 **Persistent Storage**: Configurable persistent volumes for log storage
- 📊 **Prometheus Integration**: Built-in ServiceMonitor for metrics collection
- 🔒 **Security**: Runs as non-root user with security contexts
- 🚀 **Production Ready**: Health checks, resource limits, and observability included
- 🔧 **Configurable**: Extensive configuration options via values.yaml

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- Persistent Volume provisioner support in the underlying infrastructure (optional, for persistence)
- Prometheus Operator (optional, for ServiceMonitor)

## Installation

### Add the repository (when available)

```bash
helm repo add damfle https://damfle.github.io/helm-charts
helm repo update
```

### Install the chart

```bash
# Basic installation
helm install loki damfle/loki

# With custom values
helm install loki damfle/loki -f values.yaml

# With inline values
helm install loki damfle/loki \
  --set generic.persistence.size=20Gi \
  --set generic.ingress.enabled=true \
  --set generic.ingress.hosts[0].host=loki.example.com
```

## Configuration

### Basic Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `generic.image.repository` | Loki image repository | `grafana/loki` |
| `generic.image.tag` | Loki image tag | `2.9.0` |
| `generic.service.port` | Service port | `3100` |
| `generic.persistence.enabled` | Enable persistent storage | `true` |
| `generic.persistence.size` | Storage size | `8Gi` |
| `generic.resources.requests.memory` | Memory request | `128Mi` |
| `generic.resources.limits.memory` | Memory limit | `512Mi` |

### Advanced Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `config.loki` | Loki configuration YAML | See values.yaml |
| `generic.serviceMonitor.enabled` | Enable Prometheus monitoring | `true` |
| `generic.ingress.enabled` | Enable ingress | `false` |
| `generic.securityContext` | Security context for containers | See values.yaml |
| `additionalLabels` | Additional labels for all resources | `{}` |
| `additionalAnnotations` | Additional annotations for all resources | `{}` |

## Storage Configuration

Loki requires persistent storage for logs. Configure storage class and size:

```yaml
generic:
  persistence:
    enabled: true
    storageClassName: "fast-ssd"  # Optional: specify storage class
    size: 50Gi
    accessModes:
      - ReadWriteOnce
```

## Monitoring and Observability

### Prometheus Integration

Enable ServiceMonitor for Prometheus scraping:

```yaml
generic:
  serviceMonitor:
    enabled: true
    interval: 30s
    path: /metrics
```

### Health Checks

The chart includes readiness and liveness probes:

```yaml
generic:
  readinessProbe:
    httpGet:
      path: /ready
      port: http
  livenessProbe:
    httpGet:
      path: /ready
      port: http
```

## Network Access

### ClusterIP (Default)

Access Loki within the cluster:

```bash
kubectl port-forward svc/loki 3100:3100
curl http://localhost:3100/ready
```

### Ingress

Enable external access via ingress:

```yaml
generic:
  ingress:
    enabled: true
    className: "nginx"
    hosts:
      - host: loki.example.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: loki-tls
        hosts:
          - loki.example.com
```

## Usage Examples

### Basic Deployment with Persistence

```yaml
# values.yaml
persistence:
  enabled: true
  storageClassName: "local-path"
  size: 16Gi
```

### Production Setup

```yaml
# values.yaml
generic:
  replicaCount: 3
  
  resources:
    requests:
      memory: "512Mi"
      cpu: "250m"
    limits:
      memory: "2Gi"
      cpu: "1000m"

persistence:
  enabled: true
  storageClassName: "fast-ssd"
  size: 100Gi
```

### Integration with Grafana

Add Loki as a data source in Grafana:

1. Go to Configuration > Data Sources
2. Add new data source: Loki
3. URL: `http://loki:3100` (if in same cluster)
4. Save & Test

## Security Considerations

- Runs as non-root user (UID: 10001)
- Security contexts applied to pods and containers
- No authentication enabled by default (suitable for internal clusters)
- Consider enabling authentication for production deployments

## Upgrading

```bash
# Check current version
helm list

# Upgrade to latest version
helm upgrade loki damfle/loki

# Upgrade with new values
helm upgrade loki damfle/loki -f new-values.yaml
```

## Uninstalling

```bash
helm uninstall loki
```

Note: PVCs are not automatically deleted. Remove them manually if needed:

```bash
kubectl delete pvc -l app.kubernetes.io/name=loki
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

- [Grafana Loki Documentation](https://grafana.com/docs/loki/)
- [Loki Configuration Reference](https://grafana.com/docs/loki/latest/configuration/)
- [Generic Chart Documentation](../generic/README.md)
