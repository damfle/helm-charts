# Pterodactyl Helm Chart

A Helm chart for deploying [Pterodactyl Panel](https://pterodactyl.io) - a game management panel.

This chart deploys Pterodactyl Panel with options for embedded MariaDB and Redis as separate pods in the same namespace, or it can connect to external database and Redis services.

## Features

- 🎮 **Game Server Management**: Full Pterodactyl Panel functionality
- 🐬 ** MariaDB Database**: Embedded MariaDB pod or external database support
- 🔴 **Redis Cache**: Embedded Redis pod or external Redis support
- 🌐 **Traefik Integration**: Pre-configured for Traefik ingress
- 📦 **Persistent Storage**: PVCs for panel data, MariaDB, and Redis
- 🔒 **Security**: Runs as non-root, secret-based authentication
- 🚀 **Production Ready**: Health checks, resource limits, and security contexts

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- Persistent Volume provisioner support in the underlying infrastructure
- Ingress controller (Traefik recommended)

## Installation

### Add the repository

```bash
helm repo add damfle https://damfle.github.io/helm-charts
helm repo update
```

### Install the chart with embedded MariaDB and external Redis

```bash
helm install pterodactyl damfle/pterodactyl \
  --set mariadb.enabled=true \
  --set redis.enabled=false
```

### Install with external database and Redis

```bash
helm install pterodactyl damfle/pterodactyl \
  --set mariadb.enabled=false \
  --set redis.enabled=false \
  --set externalDatabase.host=my-mariadb.example.com \
  --set externalRedis.host=my-redis.example.com
```

### Install with embedded MariaDB and Redis

```bash
helm install pterodactyl damfle/pterodactyl \
  --set mariadb.enabled=true \
  --set redis.enabled=true \
  --set redis.auth.enabled=true
```

## Configuration

### Quick Start with Custom Values

```yaml
# values.yaml
mariadb:
  enabled: true
  persistence:
    size: 5Gi
  env:
    - name: MYSQL_ROOT_PASSWORD
      valueFrom:
        secretKeyRef:
          name: pterodactyl-secrets
          key: mariadb-root-password

redis:
  enabled: true
  auth:
    enabled: true
    password:
      secretKeyRef:
        name: pterodactyl-secrets
        key: redis-password

ingress:
  enabled: true
  hosts:
    - host: pterodactyl.example.com
      paths:
        - path: /
          pathType: Prefix
```

### Database Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `mariadb.enabled` | Deploy embedded MariaDB | `true` |
| `mariadb.image.repository` | MariaDB image repository | `mariadb` |
| `mariadb.image.tag` | MariaDB image tag | `11` |
| `mariadb.persistence.enabled` | Enable PVC for MariaDB | `true` |
| `mariadb.persistence.size` | Storage size | `1Gi` |
| `externalDatabase.host` | External DB hostname | `mariadb.databases.svc.cluster.local` |
| `externalDatabase.port` | External DB port | `3306` |
| `externalDatabase.type` | Database type | `mysql` |
| `externalDatabase.database` | Database name | `panel` |
| `externalDatabase.username` | Database username | `pterodactyl` |

### Redis Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `redis.enabled` | Deploy embedded Redis | `false` |
| `redis.image.repository` | Redis image repository | `redis` |
| `redis.image.tag` | Redis image tag | `alpine` |
| `redis.auth.enabled` | Enable Redis authentication | `false` |
| `redis.persistence.enabled` | Enable PVC for Redis | `true` |
| `redis.persistence.size` | Storage size | `1Gi` |
| `externalRedis.host` | External Redis hostname | `redis.databases.svc.cluster.local` |
| `externalRedis.port` | External Redis port | `6379` |

### Panel Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Panel image repository | `ghcr.io/pterodactyl/panel` |
| `image.tag` | Panel image tag | `latest` |
| `service.port` | Service port | `80` |
| `persistence.enabled` | Enable PVC for panel data | `true` |
| `persistence.size` | Storage size | `1Gi` |
| `persistence.mountPath` | Mount path | `/app/var` |

### Ingress Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class | `traefik` |
| `ingress.hosts[0].host` | Hostname | `pterodactyl.example.com` |

### Resource Limits

| Parameter | Description | Default |
|-----------|-------------|---------|
| `resources.requests.cpu` | CPU request | `200m` |
| `resources.requests.memory` | Memory request | `256Mi` |
| `resources.limits.cpu` | CPU limit | `500m` |
| `resources.limits.memory` | Memory limit | `512Mi` |

## Secrets Configuration

Create a single Kubernetes secret for all password configuration:

```bash
kubectl create secret generic pterodactyl-secrets \
  --from-literal=mariadb-root-password=CHANGE_ME \
  --from-literal=mariadb-password=CHANGE_ME_TOO \
  --from-literal=redis-password=CHANGE_ME_REDIS \
  --from-literal=db-password=CHANGE_ME_EXTERNAL_DB
```

### Required Secret Keys

| Key | Used By | Description |
|-----|---------|-------------|
| `mariadb-root-password` | MariaDB | Root password for MariaDB |
| `mariadb-password` | MariaDB, Panel | User password for MariaDB |
| `redis-password` | Redis, Panel | Password for Redis (when auth enabled) |
| `db-password` | Panel | Password for external database |

Then reference the secret in your values:

```yaml
secret:
  name: "pterodactyl-secrets"
```

## Usage Examples

### Production Setup with Embedded Database and Redis

```yaml
# values-prod.yaml
secret:
  name: "pterodactyl-secrets"

mariadb:
  enabled: true
  persistence:
    size: 10Gi
    storageClassName: "fast-ssd"

redis:
  enabled: true
  auth:
    enabled: true
  persistence:
    size: 2Gi

persistence:
  size: 5Gi
  storageClassName: "fast-ssd"

resources:
  requests:
    cpu: 500m
    memory: 512Mi
  limits:
    cpu: 1000m
    memory: 1Gi

ingress:
  enabled: true
  className: "traefik"
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: web,websecure
  hosts:
    - host: pterodactyl.yourdomain.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: pterodactyl-tls
      hosts:
        - pterodactyl.yourdomain.com
```

Install with:
```bash
helm install pterodactyl damfle/pterodactyl -f values-prod.yaml
```

### Development Setup with External Services

```yaml
# values-dev.yaml
mariadb:
  enabled: false

redis:
  enabled: false

externalDatabase:
  host: "mariadb.dev.svc.cluster.local"
  port: "3306"
  type: "mysql"
  database: "panel_dev"
  username: "pterodactyl"

externalRedis:
  host: "redis.dev.svc.cluster.local"
  port: "6379"

persistence:
  enabled: false

service:
  type: NodePort
```

### Minimal Setup (External Everything)

```bash
helm install pterodactyl damfle/pterodactyl \
  --set mariadb.enabled=false \
  --set redis.enabled=false \
  --set externalDatabase.host=my-mysql.example.com \
  --set externalRedis.host=my-redis.example.com
```

## Database Migration

If you need to migrate from an external database to embedded MariaDB or vice versa:

1. Backup your existing database
2. Update your values to switch the configuration
3. The panel will connect to the new database on restart

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods -l app.kubernetes.io/name=pterodactyl
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Check Services

```bash
kubectl get svc -l app.kubernetes.io/name=pterodactyl
```

### Check MariaDB Connection

```bash
kubectl exec -it <pterodactyl-pod> -- mysql -h <mariadb-service> -u pterodactyl -p
```

### Check Redis Connection

```bash
kubectl exec -it <pterodactyl-pod> -- redis-cli -h <redis-service> ping
```

### Common Issues

1. **Database connection failures**: Verify MariaDB pod is running and credentials are correct
2. **Redis connection failures**: Verify Redis pod is running and network is accessible
3. **Pod crash loops**: Check logs for authentication or configuration errors
4. **PVC issues**: Verify storage class is available and PVCs are bound

### Database Connection Test

```bash
# If using embedded MariaDB
kubectl exec -it <pterodactyl-panel-pod> -- mysql -h pterodactyl-mariadb -u pterodactyl -p

# If using external database
kubectl exec -it <pterodactyl-pod> -- mysql -h <external-host> -u pterodactyl -p
```

## Architecture

When `mariadb.enabled: true`:
```
┌─────────────────────────────────────────────────────┐
│                    Namespace                            │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────┐ │
│  │  Pterodactyl│    │   MariaDB   │    │  Redis   │ │
│  │    Panel    │    │   (Pod)     │    │  (Pod)   │ │
│  └──────┬──────┘    └──────┬──────┘    └────┬────┘ │
│         │                   │                │        │
│  ┌──────▼──────┐    ┌──────▼──────┐         │        │
│  │ pterodactyl │    │pterodactyl-  │         │        │
│  │   (Svc)    │    │  mariadb    │         │        │
│  │   :80      │    │   :3306     │         │        │
│  └─────────────┘    └─────────────┘         │        │
│                                     ┌──────▼──────┐ │
│                                     │pterodactyl-  │ │
│                                     │  redis      │ │
│                                     │   :6379     │ │
│                                     └─────────────┘ │
└─────────────────────────────────────────────────────┘
```

When `mariadb.enabled: false` and `redis.enabled: false`:
```
┌─────────────────────────────────────────────────────┐
│                    Namespace                            │
│  ┌─────────────┐                                        │
│  │  Pterodactyl│                                        │
│  │    Panel    │                                        │
│  └──────┬──────┘                                        │
│         │                                               │
│  ┌──────▼──────┐                                        │
│  │ pterodactyl │──────────────► External DB             │
│  │   (Svc)    │         (mariadb.databases.svc)        │
│  │   :80      │──────────────► External Redis           │
│  └─────────────┘         (redis.databases.svc)         │
└─────────────────────────────────────────────────────┘
```

## Security Considerations

- **Database Security**: Always use strong passwords and secrets
- **Redis Security**: Enable authentication when deploying embedded Redis
- **Network Isolation**: Consider NetworkPolicies for production deployments
- **TLS**: Use TLS/SSL for external database connections
- **HTTPS**: Use ingress with TLS for external access
- **Data Backup**: Regularly backup PVC data and databases

## Performance Tuning

### Resource Optimization

```yaml
# For small deployments
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 200m
    memory: 256Mi

# For production deployments
resources:
  requests:
    cpu: 500m
    memory: 512Mi
  limits:
    cpu: 1000m
    memory: 1Gi

mariadb:
  resources:
    requests:
      cpu: 200m
      memory: 256Mi
    limits:
      cpu: 500m
      memory: 512Mi

redis:
  resources:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 200m
      memory: 256Mi
```

### Storage Optimization

Use appropriate storage classes for different workloads:

```yaml
persistence:
  storageClassName: "fast-ssd"
  size: 10Gi

mariadb:
  persistence:
    storageClassName: "fast-ssd"
    size: 10Gi

redis:
  persistence:
    storageClassName: "fast-ssd"
    size: 2Gi
```

## Upgrading

```bash
# Check current version
helm list

# Upgrade to latest version
helm upgrade pterodactyl damfle/pterodactyl

# Upgrade with new values
helm upgrade pterodactyl damfle/pterodactyl -f new-values.yaml
```

**Note**: Always backup your database and persistent volumes before upgrading.

## Uninstalling

```bash
helm uninstall pterodactyl
```

**Important**: This will not delete the PVCs automatically. Remove them manually if needed:

```bash
kubectl delete pvc -l app.kubernetes.io/name=pterodactyl
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

- [Pterodactyl Panel Documentation](https://pterodactyl.io/panel/1.0/getting_started.html)
- [Pterodactyl Repository](https://github.com/pterodactyl/panel)
- [Helm Charts Repository](https://github.com/damfle/helm-charts)
