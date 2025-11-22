# Shlink URL Shortener Helm Chart

A Helm chart for deploying Shlink URL shortener on Kubernetes

## Description

[Shlink](https://shlink.io/) is a self-hosted URL shortener that provides advanced features like custom domains, detailed analytics, QR codes, and comprehensive API access. This Helm chart deploys Shlink on Kubernetes with PostgreSQL database support.

## 🚀 Features

- **URL Shortening**: Create short URLs with custom aliases
- **Analytics**: Detailed visit tracking and statistics
- **QR Codes**: Automatic QR code generation for short URLs
- **REST API**: Complete API for programmatic access
- **Custom Domains**: Support for multiple domains
- **Geolocation**: Optional visitor geolocation tracking
- **Security**: Built-in security features and rate limiting

## 📋 Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PostgreSQL database (can be external or in-cluster)

## 🔧 Installation

### Add the Helm repository

```bash
helm repo add damfle https://damfle.github.io/helm-charts
helm repo update
```

### Install the chart

```bash
helm install shlink damfle/shlink
```

### Install with custom values

```bash
helm install shlink damfle/shlink -f values.yaml
```

## ⚙️ Configuration

The following table lists the configurable parameters and their default values.

### Generic Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `generic.image.repository` | Shlink image repository | `ghcr.io/shlinkio/shlink` |
| `generic.image.tag` | Shlink image tag | Uses `appVersion` from Chart.yaml |
| `generic.image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `generic.replicaCount` | Number of replicas | `1` |
| `generic.service.type` | Service type | `ClusterIP` |
| `generic.service.port` | Service port | `80` |
| `generic.service.targetPort` | Container port | `8080` |

### Environment Variables

Environment variables are typically provided via Kubernetes secrets using `envFrom`:

| Secret Key | Description | Example Value |
|-----------|-------------|---------|
| `DEFAULT_DOMAIN` | Default domain for short URLs | `short.yourdomain.com` |
| `IS_HTTPS_ENABLED` | Enable HTTPS | `true` |
| `DB_DRIVER` | Database driver | `postgres` |
| `DB_HOST` | Database host | `postgres.databases.svc.cluster.local` |
| `DB_PORT` | Database port | `5432` |
| `DB_NAME` | Database name | `shlink` |
| `DB_USER` | Database user | `shlink` |
| `DB_PASSWORD` | Database password | `your-secure-password` |

### Resources

| Parameter | Description | Default |
|-----------|-------------|---------|
| `generic.resources.limits.cpu` | CPU limit | `500m` |
| `generic.resources.limits.memory` | Memory limit | `1024Mi` |
| `generic.resources.requests.cpu` | CPU request | `100m` |
| `generic.resources.requests.memory` | Memory request | `256Mi` |

### Ingress

| Parameter | Description | Default |
|-----------|-------------|---------|
| `generic.ingress.enabled` | Enable ingress | `true` |
| `generic.ingress.className` | Ingress class name | `traefik` |
| `generic.ingress.hosts[0].host` | Ingress hostname | `shlink.example.com` |

### Shlink-Specific Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `shlink.database.createSchema` | Create database schema | `true` |
| `shlink.database.runMigrations` | Run database migrations | `true` |
| `shlink.shortening.defaultShortCodeLength` | Default short code length | `5` |
| `shlink.api.enabled` | Enable REST API | `true` |
| `shlink.tracking.anonymizeRemoteAddr` | Anonymize visitor IP addresses | `true` |
| `shlink.redirects.redirectStatusCode` | HTTP status code for redirects | `302` |

## 🛠️ Examples

### Basic Installation with External PostgreSQL

```yaml
# values.yaml
generic:
  envFrom:
    - secretRef:
        name: shlink-secrets  # Contains DB credentials and configuration
  
  ingress:
    enabled: true
    hosts:
      - host: short.yourdomain.com
        paths:
          - path: /
            pathType: Prefix
```

Create the secret with your configuration:
```bash
kubectl create secret generic shlink-secrets \
  --from-literal=DEFAULT_DOMAIN=short.yourdomain.com \
  --from-literal=DB_HOST=your-postgres-host \
  --from-literal=DB_PASSWORD=your-secure-password \
  --from-literal=DB_USER=shlink \
  --from-literal=DB_NAME=shlink
```

### Installation with Custom Configuration

```yaml
# values.yaml
generic:
  replicaCount: 2
  
  envFrom:
    - secretRef:
        name: shlink-secrets  # Contains all environment variables
  
  ingress:
    enabled: true
    hosts:
      - host: s.yourdomain.com
        paths:
          - path: /
            pathType: Prefix

shlink:
  shortening:
    defaultShortCodeLength: 6
    multiSegmentSlugsEnabled: true
  
  tracking:
    anonymizeRemoteAddr: false
    trackOrphanVisits: true
  
  redirects:
    redirectStatusCode: 301
```

Secret content example:
```bash
kubectl create secret generic shlink-secrets \
  --from-literal=DEFAULT_DOMAIN=s.yourdomain.com \
  --from-literal=GEOLITE_LICENSE_KEY=your-maxmind-license-key \
  --from-literal=DB_PASSWORD=your-secure-password \
  --from-literal=DB_HOST=postgres.databases.svc.cluster.local \
  --from-literal=DB_USER=shlink \
  --from-literal=DB_NAME=shlink
```

## 📊 Database Setup

Shlink requires a PostgreSQL database. You can either:

1. **Use an external PostgreSQL instance** (recommended for production)
2. **Deploy PostgreSQL in the same cluster** using a separate chart

### External Database

Update the secret with database connection parameters:

```bash
kubectl create secret generic shlink-secrets \
  --from-literal=DB_HOST=your-postgres-host.com \
  --from-literal=DB_PORT=5432 \
  --from-literal=DB_NAME=shlink \
  --from-literal=DB_USER=shlink \
  --from-literal=DB_PASSWORD=your-secure-password \
  --from-literal=DEFAULT_DOMAIN=short.yourdomain.com
```

### In-Cluster PostgreSQL

You can deploy PostgreSQL using the official Bitnami chart:

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install postgres bitnami/postgresql \
  --set auth.postgresPassword=yourpassword \
  --set auth.database=shlink \
  --set auth.username=shlink \
  --set auth.password=yourpassword
```

## 🔒 Security Considerations

1. **Use secrets**: Always use Kubernetes secrets for sensitive data (database passwords, API keys)
2. **Enable HTTPS**: Always use HTTPS in production with proper TLS certificates
3. **API Keys**: Secure your API keys and rotate them regularly
4. **Network policies**: Implement network policies to restrict database access
5. **External authentication**: Consider using external authentication providers

## 🔍 Monitoring and Logs

### Viewing Logs

```bash
kubectl logs -f deployment/shlink
```

### Health Checks

Shlink provides health check endpoints:

- Health check: `http://your-domain/rest/health`
- API docs: `http://your-domain/rest/docs`

## 📈 Scaling

To scale Shlink horizontally:

```yaml
generic:
  replicaCount: 3
```

Note: Ensure your database can handle multiple connections and consider using connection pooling.

## 🔄 Upgrading

### Upgrade the chart

```bash
helm upgrade shlink damfle/shlink
```

### Database Migrations

Shlink automatically runs database migrations on startup when `shlink.database.runMigrations` is set to `true`.

## 📝 API Usage

After deployment, you can access the Shlink API:

```bash
# Get API key (check pod logs or configure in values)
kubectl logs deployment/shlink | grep "Generated API key"

# Create a short URL
curl -X POST "https://your-domain/rest/v3/short-urls" \
  -H "X-Api-Key: your-api-key" \
  -H "Content-Type: application/json" \
  -d '{"longUrl": "https://example.com"}'
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This Helm chart is licensed under the ISC License.

## 🔗 Links

- [Shlink Official Website](https://shlink.io/)
- [Shlink Documentation](https://shlink.io/documentation/)
- [Shlink GitHub Repository](https://github.com/shlinkio/shlink)
- [Chart Repository](https://github.com/damfle/helm-charts)
