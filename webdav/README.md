# WebDAV Helm Chart

## ⚠️ Deprecation Notice

**This helm chart is deprecated and is no longer actively maintained.**

A Helm chart for deploying a WebDAV server - an HTTP-based file sharing protocol that allows remote editing and management of files on web servers.

This chart extends the [generic chart](../generic/README.md) to provide a ready-to-use WebDAV deployment with sensible defaults.

## Features

- 🗂️ **HTTP File Access**: Web-based file management and sharing
- 📦 **Official Container**: Uses the `ghcr.io/hacdias/webdav` container image
- 💾 **Persistent Storage**: Configurable persistent volumes for file storage (128Gi default)
- � **Configurable**: Extensive WebDAV configuration via ConfigMap
- 🚀 **Production Ready**: Health checks, resource limits, and security contexts
- 🌐 **Ingress Ready**: Easy external access configuration with Traefik/NGINX support
- � **Authentication**: Support for external authentication (e.g., Authentik)
- 📋 **CORS Support**: Built-in CORS configuration for web clients

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
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
# Basic installation
helm install webdav damfle/webdav

# With custom values
helm install webdav damfle/webdav -f values.yaml

# With inline values
helm install webdav damfle/webdav \
  --set generic.persistence.size=20Gi \
  --set generic.ingress.enabled=true \
  --set generic.ingress.hosts[0].host=webdav.example.com
```

## Configuration

### Basic Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `generic.image.repository` | WebDAV image repository | `ghcr.io/hacdias/webdav` |
| `generic.image.tag` | WebDAV image tag | Uses `appVersion` from Chart.yaml |
| `generic.service.port` | Service port | `6065` |
| `generic.persistence.enabled` | Enable persistent storage | `true` |
| `generic.persistence.size` | Storage size | `128Gi` |
| `generic.env[0].value` | Authentication type | `none` |
| `generic.env[1].value` | WebDAV scope directory | `/data` |
| `config.enabled` | Enable ConfigMap | `true` |

### Advanced Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `config.data.config.yaml` | WebDAV server configuration | See values.yaml |
| `generic.ingress.enabled` | Enable ingress | `false` |
| `generic.resources.requests.memory` | Memory request | `128Mi` |
| `generic.resources.limits.memory` | Memory limit | `256Mi` |
| `generic.securityContext.runAsUser` | User ID | `1000` |
| `generic.securityContext.fsGroup` | Group ID | `1000` |

## Authentication Configuration

WebDAV requires authentication. Configure credentials via environment variables:

```yaml
generic:
  env:
    - name: USERNAME
      value: "admin"
    - name: PASSWORD
      value: "secure-password"
    # Optional: Use existing secret
    # - name: PASSWORD
    #   valueFrom:
    #     secretKeyRef:
    #       name: webdav-credentials
    #       key: password
```

## Storage Configuration

WebDAV requires persistent storage for files:

```yaml
generic:
  persistence:
    enabled: true
    storageClassName: "fast-ssd"  # Optional: specify storage class
    size: 100Gi
    accessModes:
      - ReadWriteOnce
    mountPath: /var/webdav
```

## Network Access

### ClusterIP (Default)

Access WebDAV within the cluster:

```bash
kubectl port-forward svc/webdav 8080:6065
# Access via http://localhost:8080
```

### Ingress (Recommended)

Enable external access via ingress:

```yaml
generic:
  ingress:
    enabled: true
    className: "nginx"
    annotations:
      nginx.ingress.kubernetes.io/proxy-body-size: "0"
      nginx.ingress.kubernetes.io/proxy-request-buffering: "off"
    hosts:
      - host: webdav.example.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: webdav-tls
        hosts:
          - webdav.example.com
```

## Usage Examples

### Basic File Operations

Once deployed, you can access WebDAV via:

**Web Browser:**
- Navigate to `http://webdav.example.com`
- Login with configured username/password

**Command Line (curl):**
```bash
# List files
curl -u username:password -X PROPFIND http://webdav.example.com/

# Upload file
curl -u username:password -T localfile.txt http://webdav.example.com/remotefile.txt

# Download file
curl -u username:password -O http://webdav.example.com/remotefile.txt

# Create directory
curl -u username:password -X MKCOL http://webdav.example.com/newfolder/
```

**Desktop Integration:**
- **Windows**: Map network drive to `http://webdav.example.com`
- **macOS**: Finder → Go → Connect to Server → `http://webdav.example.com`
- **Linux**: Most file managers support WebDAV (davfs2)

### Advanced Configuration Example

```yaml
# values.yaml
config:
  enabled: true
  data:
    config.yaml: |
      address: 0.0.0.0
      port: 6065
      tls: false
      prefix: /
      debug: false
      behindProxy: true
      directory: /data
      permissions: R
      
      cors:
        enabled: true
        credentials: true
      
      users: []  # Empty for external authentication

generic:
  ingress:
    enabled: true
    annotations:
      traefik.ingress.kubernetes.io/router.entrypoints: web,websecure
      traefik.ingress.kubernetes.io/router.middlewares: authentik-ak-outpost-authentik-embedded-outpost@kubernetescrd
    hosts:
      - host: webdav.yourdomain.com
        paths:
          - path: /
            pathType: Prefix
  
  persistence:
    enabled: true
    storageClassName: "local-path"
    size: 128Gi
```
      value: "admin"
    - name: PASSWORD
      valueFrom:
        secretKeyRef:
          name: webdav-secret
          key: password
    - name: UID
      value: "1000"
    - name: GID
      value: "1000"

  # Large storage for file sharing
  persistence:
    enabled: true
    size: 500Gi
    storageClassName: "fast-ssd"

  # External access with SSL
  ingress:
    enabled: true
    className: "nginx"
    annotations:
      nginx.ingress.kubernetes.io/proxy-body-size: "0"
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
      cert-manager.io/cluster-issuer: "letsencrypt-prod"
    hosts:
      - host: files.company.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: webdav-tls
        hosts:
          - files.company.com

  # Resource limits for production
  resources:
    requests:
      memory: "256Mi"
      cpu: "100m"
    limits:
      memory: "512Mi"
      cpu: "500m"
```

## Security Considerations

- **Authentication**: Always change default username/password
- **HTTPS**: Use TLS/SSL for external access
- **Network Policies**: Consider restricting network access
- **File Permissions**: Configure appropriate UID/GID for file access
- **Storage Security**: Use encrypted storage classes when possible

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods -l app.kubernetes.io/name=webdav
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Verify Service

```bash
kubectl get svc webdav
kubectl port-forward svc/webdav 8080:6065
curl -u username:password http://localhost:8080/
```

### Common Issues

1. **Pod stuck in Pending**: Check PVC and storage class
2. **Authentication failures**: Verify USERNAME/PASSWORD environment variables
3. **File permission errors**: Check UID/GID settings and storage permissions
4. **Upload failures**: Verify ingress proxy-body-size annotations

## Client Configuration

### Windows

1. Open File Explorer
2. Right-click "This PC" → "Map network drive"
3. Enter: `http://webdav.example.com`
4. Provide credentials when prompted

### macOS

1. Open Finder
2. Press Cmd+K or Go → "Connect to Server"
3. Enter: `http://webdav.example.com`
4. Provide credentials when prompted

### Linux (davfs2)

```bash
# Install davfs2
sudo apt-get install davfs2  # Ubuntu/Debian
sudo yum install davfs2      # CentOS/RHEL

# Mount WebDAV
sudo mkdir /mnt/webdav
sudo mount -t davfs http://webdav.example.com /mnt/webdav
```

## Upgrading

```bash
# Check current version
helm list

# Upgrade to latest version
helm upgrade webdav damfle/webdav

# Upgrade with new values
helm upgrade webdav damfle/webdav -f new-values.yaml
```

## Uninstalling

```bash
helm uninstall webdav
```

Note: PVCs are not automatically deleted. Remove them manually if needed:

```bash
kubectl delete pvc -l app.kubernetes.io/name=webdav
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

- [WebDAV Protocol Documentation](https://tools.ietf.org/html/rfc4918)
- [ugeek/webdav Docker Image](https://hub.docker.com/r/ugeek/webdav)
- [Generic Chart Documentation](../generic/README.md)
