# Pterodactyl Helm Chart

A Helm chart for deploying [Pterodactyl Panel](https://pterodactyl.io) - a game management panel.

This chart deploys Pterodactyl Panel with optional embedded MariaDB and Redis as separate pods in the same namespace, or connects to external database and Redis services.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- Persistent Volume provisioner support
- Ingress controller (Traefik recommended, but any will work)

## Installation

### Add the repository

```bash
helm repo add damfle https://damfle.github.io/helm-charts
helm repo update
```

### Install with embedded MariaDB and Redis

```bash
helm install pterodactyl damfle/pterodactyl \
  --set mariadb.enabled=true \
  --set redis.enabled=true \
  --set redis.auth.enabled=true
```

### Install with external database and Redis

```bash
helm install pterodactyl damfle/pterodactyl \
  --set mariadb.enabled=false \
  --set redis.enabled=false
```

### Install with embedded MariaDB only

```bash
helm install pterodactyl damfle/pterodactyl \
  --set mariadb.enabled=true \
  --set redis.enabled=false
```

## Configuration

### Database Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `pterodactyl.database.name` | Database name | `pterodactyl` |
| `pterodactyl.database.host` | Database host (defaults to embedded mariadb) | `` |
| `pterodactyl.database.port` | Database port | `3306` |
| `pterodactyl.database.user` | Database user | `pterodactyl` |
| `pterodactyl.database.password` | Database password | `` |
| `mariadb.enabled` | Deploy embedded MariaDB | `true` |
| `mariadb.rootPassword` | MariaDB root password (random if empty) | `` |
| `mariadb.image.repository` | MariaDB image | `mariadb` |
| `mariadb.image.tag` | MariaDB image tag | `11` |
| `mariadb.persistence.size` | MariaDB PVC size | `1Gi` |

### Redis Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `pterodactyl.redis.host` | Redis host (defaults to embedded redis) | `` |
| `pterodactyl.redis.port` | Redis port | `6379` |
| `pterodactyl.redis.password` | Redis password | `` |
| `redis.enabled` | Deploy embedded Redis | `false` |
| `redis.auth.enabled` | Enable Redis authentication | `false` |
| `redis.image.repository` | Redis image | `redis` |
| `redis.image.tag` | Redis image tag | `alpine` |
| `redis.persistence.size` | Redis PVC size | `1Gi` |

### Panel Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `panel.replicaCount` | Number of panel pods | `1` |
| `panel.image.repository` | Panel image | `ghcr.io/pterodactyl/panel` |
| `panel.image.tag` | Panel image tag | `v1.12.2` |
| `panel.image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `panel.service.type` | Service type | `ClusterIP` |
| `panel.service.port` | Service port | `80` |
| `panel.persistence.enabled` | Enable panel PVC | `true` |
| `panel.persistence.size` | Panel PVC size | `1Gi` |
| `panel.persistence.mountPath` | Panel data mount path | `/app/var` |
| `panel.resources.requests.cpu` | CPU request | `200m` |
| `panel.resources.requests.memory` | Memory request | `256Mi` |
| `panel.resources.limits.cpu` | CPU limit | `500m` |
| `panel.resources.limits.memory` | Memory limit | `512Mi` |

### Ingress Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `panel.ingress.enabled` | Enable ingress | `false` |
| `panel.ingress.className` | Ingress class | `traefik` |
| `panel.ingress.hosts[0].host` | Hostname | `pterodactyl.example.com` |

### Application Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `pterodactyl.app.url` | Application URL | `https://pterodactyl.example.com` |
| `pterodactyl.app.env` | Application environment | `production` |
| `pterodactyl.app.timezone` | Timezone | `UTC` |
| `pterodactyl.app.adminEmail` | Admin email | `noreply@example.com` |

## Secrets

All passwords can be configured directly in values or via secretKeyRef.

### Using Kubernetes Secrets

Create a secret:

```bash
kubectl create secret generic pterodactyl-secrets \
  --from-literal=mariadb-root-password=<root_password> \
  --from-literal=mariadb-password=<user_password> \
  --from-literal=redis-password=<redis_password>
```

Reference it in values.yaml:

```yaml
mariadb:
  rootPassword:
    secretKeyRef:
      name: pterodactyl-secrets
      key: mariadb-root-password

pterodactyl:
  database:
    password:
      secretKeyRef:
        name: pterodactyl-secrets
        key: mariadb-password
  redis:
    password:
      secretKeyRef:
        name: pterodactyl-secrets
        key: redis-password
```

### Using Plain Values

```yaml
mariadb:
  rootPassword: "my-secure-root-pass"

pterodactyl:
  database:
    password: "my-db-password"
  redis:
    password: "my-redis-password"
```

If no password is provided for MariaDB root, a random 32-character password is generated automatically.

## Example Values

### Production with embedded services

```yaml
mariadb:
  enabled: true
  rootPassword: ""
  persistence:
    size: 10Gi
    storageClassName: "fast-ssd"

redis:
  enabled: true
  auth:
    enabled: true
  persistence:
    size: 2Gi

panel:
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
    hosts:
      - host: pterodactyl.yourdomain.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: pterodactyl-tls
        hosts:
          - pterodactyl.yourdomain.com

pterodactyl:
  app:
    url: "https://pterodactyl.yourdomain.com"
    adminEmail: "admin@yourdomain.com"
```

### Development with external services

```yaml
mariadb:
  enabled: false

redis:
  enabled: false

pterodactyl:
  database:
    host: "mysql.external.svc"
    user: "pterodactyl"
    password: "external-db-password"
  redis:
    host: "redis.external.svc"
    password: "external-redis-password"
```

## Usage

### Access the Panel

Get the application URL:

```bash
# If ingress enabled
kubectl get ingress

# If NodePort
kubectl get svc

# If ClusterIP
kubectl port-forward svc/<release-name>-pterodactyl 8080:80
```

### Check Pods

```bash
kubectl get pods -l app.kubernetes.io/name=pterodactyl
```

### View Logs

```bash
kubectl logs -l app.kubernetes.io/name=pterodactyl -c panel
```

## Upgrading

```bash
helm upgrade pterodactyl damfle/pterodactyl
```

## Uninstalling

```bash
helm uninstall pterodactyl
```

Note: PVCs are not automatically deleted. Delete them manually if needed:

```bash
kubectl delete pvc -l app.kubernetes.io/name=pterodactyl
kubectl delete pvc -l app.kubernetes.io/component=mariadb
kubectl delete pvc -l app.kubernetes.io/component=redis
```

## Architecture

### Embedded Services (mariadb.enabled=true, redis.enabled=true)

```
┌─────────────────────────────────────────────────────────────┐
│                      Kubernetes Namespace                       │
│                                                                  │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────┐ │
│  │  Pterodactyl │    │   MariaDB   │    │      Redis       │ │
│  │    Panel    │    │   (Pod)     │    │     (Pod)        │ │
│  └──────┬──────┘    └──────┬──────┘    └─────────┬───────┘ │
│         │                   │                  │           │
│   ┌─────▼─────┐      ┌─────▼─────┐          ┌────▼────────┐  │
│   │ pterodactyl │      │pterodactyl- │          │pterodactyl- │  │
│   │   (Service)│      │  mariadb    │          │   redis    │  │
│   │   :80      │      │   :3306    │          │   :6379    │  │
│   └─────────────┘      └─────────────┘          └─────────────┘  │
│                                                          │
│                    All running in same namespace                │
└─────────────────────────────────────────────────────────────┘
```

### External Services (mariadb.enabled=false, redis.enabled=false)

```
┌─────────────────────────────────────────────────────────────┐
│                      Kubernetes Namespace                       │
│                                                                  │
│  ┌─────────────┐                                        │
│  │  Pterodactyl │█─────────────┐                           │
│  │    Panel    │═════════════╪═► External MariaDB           │
│  └──────┬──────┘           │                           │
│         │                 │                           │
│   ┌─────▼─────┐           │                           │
│   │ pterodactyl │           │                           │
│   │   (Service)│           ▼                           │
│   │   :80      │█─────────────┐                           │
│   └─────────────┘           ► External Redis               │
│                                (or embedded if enabled)     │
│                                                                  │
└─────────────────────────────────────────────────────────────┘
```

## Troubleshooting

### Pods not starting

```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Database connection issues

Check that:
- MariaDB pod is running
- Credentials are correct in values
- Host is reachable from panel pod

### Redis connection issues

Check that:
- Redis pod is running (if embedded)
- Authentication is enabled if required
- Host is reachable from panel pod

### Persistent Volume issues

```bash
kubectl get pvc
kubectl describe pvc <pvc-name>
```

## Security

- Use strong passwords or secrets
- Enable Redis authentication when deploying embedded Redis
- Use TLS for external database connections
- Use ingress with TLS for public access
- Regularly backup your data

## Links

- [Pterodactyl Panel](https://pterodactyl.io)
- [Pterodactyl Documentation](https://pterodactyl.io/panel/1.0/getting_started.html)
- [Pterodactyl GitHub](https://github.com/pterodactyl/panel)
- [Helm Chart Repository](https://github.com/damfle/helm-charts)
