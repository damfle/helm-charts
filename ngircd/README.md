# ngIRCd irc server Helm Chart

A Helm chart for deploying ngIRCd irc server on Kubernetes

## Description

[ngIRCd](https://ngircd.barton.de/) is a self-hosted irc server that provides advanced features.


## 📋 Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+


## 🔧 Installation

### Add the Helm repository

```bash
helm repo add damfle https://damfle.github.io/helm-charts
helm repo update
```

### Install the chart

```bash
helm install ngircd damfle/ngircd
```

### Install with custom values

```bash
helm install ngircd damfle/ngircd -f values.yaml
```

## ⚙️ Configuration

The following table lists the configurable parameters and their default values.

### Generic Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `generic.image.repository` | ngIRCd image repository | `ghcr.io/ngircdio/ngircd` |
| `generic.image.tag` | ngIRCd image tag | Uses `appVersion` from Chart.yaml |
| `generic.image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `generic.replicaCount` | Number of replicas | `1` |
| `generic.service.type` | Service type | `ClusterIP` |
| `generic.service.port` | Service port | `80` |
| `generic.service.targetPort` | Container port | `8080` |

### Environment Variables

Environment variables are typically provided via Kubernetes secrets using `envFrom`:

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
| `generic.ingress.hosts[0].host` | Ingress hostname | `ngircd.example.com` |

### ngIRCd-Specific Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ngircd.database.createSchema` | Create database schema | `true` |
| `ngircd.database.runMigrations` | Run database migrations | `true` |
| `ngircd.shortening.defaultShortCodeLength` | Default short code length | `5` |
| `ngircd.api.enabled` | Enable REST API | `true` |
| `ngircd.tracking.anonymizeRemoteAddr` | Anonymize visitor IP addresses | `true` |
| `ngircd.redirects.redirectStatusCode` | HTTP status code for redirects | `302` |

## 🛠️ Examples

### Basic Installation with External PostgreSQL

```yaml
# values.yaml
generic:
  envFrom:
    - secretRef:
        name: ngircd-secrets  # Contains DB credentials and configuration
  
  ingress:
    enabled: true
    hosts:
      - host: short.yourdomain.com
        paths:
          - path: /
            pathType: Prefix
```



### Installation with Custom Configuration

```yaml
# values.yaml
generic:
  replicaCount: 2
  
  envFrom:
    - secretRef:
        name: ngircd-secrets  # Contains all environment variables
  
  ingress:
    enabled: true
    hosts:
      - host: s.yourdomain.com
        paths:
          - path: /
            pathType: Prefix

ngircd:
  shortening:
    defaultShortCodeLength: 6
    multiSegmentSlugsEnabled: true
  
  tracking:
    anonymizeRemoteAddr: false
    trackOrphanVisits: true
  
  redirects:
    redirectStatusCode: 301
```

## 🔍 Monitoring and Logs

### Viewing Logs

```bash
kubectl logs -f deployment/ngircd
```

## 📈 Scaling

To scale ngIRCd horizontally:

```yaml
generic:
  replicaCount: 3
```


## 🔄 Upgrading

### Upgrade the chart

```bash
helm upgrade ngircd damfle/ngircd
```


## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This Helm chart is licensed under the ISC License.

## 🔗 Links

- [ngIRCd Official Website](https://ngircd.barton.de/)
- [ngIRCd Documentation](https://ngircd.barton.de/documentation.php.en)
- [ngIRCd GitHub Repository](https://github.com/ngircd/ngircd)
- [Chart Repository](https://github.com/damfle/helm-charts)
