# Generic Helm Chart

A flexible Helm chart for deploying applications on Kubernetes with optional monitoring and persistence support.

## New Features

### Prometheus ServiceMonitor

The chart now supports optional Prometheus ServiceMonitor creation for automatic metrics collection:

```yaml
serviceMonitor:
  enabled: true
  interval: 30s
  scrapeTimeout: 10s
  path: /metrics
  portName: http
  labels:
    app: monitoring
  annotations:
    prometheus.io/scrape: "true"
```

**Requirements:**
- Prometheus Operator installed in the cluster
- Application must expose metrics endpoint

### Persistent Volume Support

The chart now supports persistent volume claims that work with any storage class:

```yaml
persistence:
  enabled: true
  storageClassName: "gp2"
  accessModes:
    - ReadWriteOnce
  size: 10Gi
  mountPath: /app/data
  subPath: ""
```

**Reclaim Policy:**
The reclaim policy (Retain, Delete, Recycle) is controlled by the StorageClass configuration, not by this chart. This ensures compatibility with any storage backend and follows Kubernetes best practices.

### Health Probe Configuration

The chart supports configurable health probes with enabled flags (default: true):

```yaml
livenessProbe:
  enabled: true
  httpGet:
    path: /health
    port: http
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  enabled: true
  httpGet:
    path: /ready
    port: http
  initialDelaySeconds: 5
  periodSeconds: 5
```

**Note:** All probe types (liveness, readiness, startup) can be individually disabled by setting `enabled: false`.

### Environment Variables & Existing Secrets Support

The chart supports environment variables and can reference existing Kubernetes secrets:

```yaml
# Direct environment variables
env:
  - name: APP_ENV
    value: "production"
  # Reference existing secrets
  - name: DATABASE_PASSWORD
    valueFrom:
      secretKeyRef:
        name: database-credentials
        key: password

# Load all keys from existing secrets/configmaps
envFrom:
  - secretRef:
      name: app-secrets
  - configMapRef:
      name: app-config
```

**Requirements:**
- Secrets and ConfigMaps must exist in the same namespace
- Use `optional: true` for optional secrets that may not exist

## Usage Examples

### Basic deployment with monitoring and persistence:

```bash
helm install my-app ./generic -f examples/monitoring-and-persistence.yaml
```

### Enable only ServiceMonitor:

```bash
helm install my-app ./generic --set serviceMonitor.enabled=true
```

### Enable only persistence:

```bash
helm install my-app ./generic --set persistence.enabled=true --set persistence.size=20Gi
```

### Using existing secrets:

```bash
helm install my-app ./generic -f examples/existing-secrets.yaml
```

## Configuration

See `values.yaml` for all available configuration options.

## Templates

- `servicemonitor.yaml`: Creates ServiceMonitor resource when `serviceMonitor.enabled=true`
- `persistentvolumeclaim.yaml`: Creates PVC when `persistence.enabled=true`
- `deployment.yaml`: Updated to include volume mounts for persistent storage and environment variables
- `service.yaml`: Updated with prometheus annotations when monitoring is enabled

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally with `helm lint` and `helm template`
5. Submit a pull request

## License

This chart is licensed under the ISC License. See the [LICENSE](../LICENSE) file for details.

## Links

- [Repository](https://github.com/damfle/helm-charts)
- [Helm Repository](https://damfle.github.io/helm-charts)
