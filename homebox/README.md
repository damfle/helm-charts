# Homebox Helm Chart

A Helm chart for deploying [Homebox](https://github.com/sysadminsmedia/homebox) - an inventory and organization system for the home.

This chart extends the [generic chart](../generic/README.md) to provide a ready-to-use Homebox deployment with sensible defaults.

## Features

- 📦 **Inventory Management**: Track and organize your belongings
- 📱 **Modern Web UI**: Clean, responsive interface accessible from any device
- 🗄️ **Database Support**: PostgreSQL integration for data persistence
- 📊 **Asset Tracking**: Detailed item information with photos and documentation
- 🔍 **Search & Filter**: Advanced search capabilities
- 📈 **Reports**: Generate reports on your inventory
- 🔒 **Secure**: Production-ready configuration with authentication
- 🚀 **Production Ready**: Health checks, resource limits, and security contexts

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- PostgreSQL database (external)
- Persistent Volume provisioner support in the underlying infrastructure
- Ingress controller (optional, for external access)

## Installation

### Add the repository

```bash
helm repo add damfle https://damfle.github.io/helm-charts
helm repo update
```

### Install the chart

```bash
# Basic installation (requires external PostgreSQL)
helm install homebox damfle/homebox

# With custom values
helm install homebox damfle/homebox -f values.yaml

# With inline configuration
helm install homebox damfle/homebox \
  --set generic.persistence.size=5Gi \
  --set generic.ingress.enabled=true \
  --set generic.ingress.hosts[0].host=homebox.example.com
```

## Configuration

### Basic Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `generic.image.repository` | Homebox image repository | `ghcr.io/sysadminsmedia/homebox` |
| `generic.image.tag` | Homebox image tag | `0.21.0-rootless` |
| `generic.service.port` | Service and container port | `7745` |
| `generic.persistence.enabled` | Enable persistent storage | `true` |
| `generic.persistence.size` | Storage size | `1Gi` |

### Database Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `generic.env[5].value` | Database host | `postgres.databases.svc.cluster.local` |
| `generic.env[6].value` | Database port | `5432` |
| `generic.env[7].value` | Database username | `homebox` |
| `generic.env[8].value` | Database password |  |
| `generic.env[9].value` | Database name | `homebox` |

### Application Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `generic.env[0].value` | Timezone | `Europe/Paris` |
| `generic.env[1].value` | Application mode | `production` |
| `generic.env[2].value` | Allow analytics | `false` |
| `generic.env[3].value` | Allow registration | `false` |

## Database Setup

Homebox requires a PostgreSQL database. Configure the connection via environment variables:

```yaml
generic:
  env:
    - name: HBOX_DATABASE_HOST
      value: "your-postgres-host"
    - name: HBOX_DATABASE_PORT
      value: "5432"
    - name: HBOX_DATABASE_USERNAME
      value: "homebox"
    - name: HBOX_DATABASE_PASSWORD
      valueFrom:
        secretKeyRef:
          name: homebox-db-secret
          key: password
    - name: HBOX_DATABASE_DATABASE
      value: "homebox"
```

### Using External PostgreSQL

```yaml
generic:
  env:
    - name: HBOX_DATABASE_HOST
      value: "postgres.example.com"
    - name: HBOX_DATABASE_USERNAME
      value: "homebox_user"
    - name: HBOX_DATABASE_PASSWORD
      valueFrom:
        secretKeyRef:
          name: postgres-credentials
          key: password
```

## Storage Configuration

Homebox stores data and uploaded files in persistent storage:

```yaml
generic:
  persistence:
    enabled: true
    storageClassName: "fast-ssd"
    size: 10Gi
    accessModes:
      - ReadWriteOnce
    mountPath: /data
```

## Network Access

### ClusterIP (Default)

Access Homebox within the cluster:

```bash
kubectl port-forward svc/homebox 8080:7745
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
      - host: homebox.example.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: homebox-tls
        hosts:
          - homebox.example.com
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
      - host: homebox.example.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - hosts:
        - homebox.example.com
```

## Usage Examples

### Basic Production Setup

```yaml
# values.yaml
generic:
  envFrom:
    - secretRef:
        name: homebox-secrets  # Contains all configuration
  
  ingress:
    enabled: true
    hosts:
      - host: homebox.yourdomain.com
        paths:
          - path: /
            pathType: Prefix
  
  persistence:
    enabled: true
    storageClassName: "local-path"
    size: 1Gi
```

Create the secret with your configuration:
```bash
kubectl create secret generic homebox-secrets \
  --from-literal=TZ="UTC" \
  --from-literal=HBOX_MODE="production" \
  --from-literal=HBOX_OPTIONS_ALLOW_REGISTRATION="false" \
  --from-literal=HBOX_DATABASE_HOST="postgres.production.svc.cluster.local" \
  --from-literal=HBOX_DATABASE_PASSWORD="your-secure-password"
```
    hosts:
      - host: inventory.company.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: homebox-tls
        hosts:
          - inventory.company.com
```

### Development Setup

```yaml
generic:
  # Allow registration for development
  env:
    - name: HBOX_MODE
      value: "development"
    - name: HBOX_OPTIONS_ALLOW_REGISTRATION
      value: "true"
    - name: HBOX_OPTIONS_ALLOW_ANALYTICS
      value: "true"

  # Smaller storage for dev
  persistence:
    size: 1Gi

  # Local development resources
  resources:
    requests:
      memory: "64Mi"
      cpu: "50m"
    limits:
      memory: "128Mi"
      cpu: "100m"
```

## Security Considerations

- **Database Security**: Use secrets for database passwords
- **Registration**: Disable registration in production (`HBOX_OPTIONS_ALLOW_REGISTRATION=false`)
- **HTTPS**: Use TLS/SSL for external access
- **Authentication**: Consider integrating with external auth providers
- **Network Policies**: Restrict network access in production
- **Data Backup**: Regular backup of database and persistent volume

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods -l app.kubernetes.io/name=homebox
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Verify Database Connection

```bash
kubectl logs <homebox-pod> | grep -i database
kubectl logs <homebox-pod> | grep -i postgres
```

### Common Issues

1. **Database connection failures**: Check database host, credentials, and network connectivity
2. **Pod startup issues**: Verify database is accessible and credentials are correct
3. **Storage issues**: Check PVC status and storage class availability
4. **Permission errors**: Verify security contexts and file permissions

### Database Connection Test

```bash
# Test database connectivity from within the pod
kubectl exec -it <homebox-pod> -- sh
# Try connecting to database (if psql is available)
```

## Performance Tuning

### Resource Optimization

```yaml
# Minimal resources for small deployments
generic:
  resources:
    requests:
      memory: "128Mi"
      cpu: "100m"
    limits:
      memory: "256Mi"
      cpu: "200m"

# Production resources
generic:
  resources:
    requests:
      memory: "256Mi"
      cpu: "200m"
    limits:
      memory: "512Mi"
      cpu: "500m"
```

### Database Performance

- Use a dedicated PostgreSQL instance
- Configure appropriate connection pooling
- Regular database maintenance and backups
- Monitor database performance metrics

## Upgrading

```bash
# Check current version
helm list

# Upgrade to latest version
helm upgrade homebox damfle/homebox

# Upgrade with new values
helm upgrade homebox damfle/homebox -f new-values.yaml
```

**Note**: Always backup your database and persistent volume before upgrading.

## Uninstalling

```bash
helm uninstall homebox
```

**Important**: This will not delete the PVC automatically. Remove it manually if needed:

```bash
kubectl delete pvc -l app.kubernetes.io/name=homebox
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

- [Homebox Repository](https://github.com/sysadminsmedia/homebox)
- [Homebox Documentation](https://homebox.sysadminsmedia.com/)
- [Generic Chart Documentation](../generic/README.md)
