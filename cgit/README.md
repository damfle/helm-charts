# MiniGit Helm Chart

A Helm chart for deploying MiniGit - a lightweight Alpine container for git hosting with nginx+cgit that provides HTTP-only git access.

This chart extends the [generic chart](../generic/README.md) to provide a ready-to-use MiniGit deployment with sensible defaults.

## Features

- 🐙 **Git Hosting**: Complete HTTP-based Git server with cgit web interface
- 🌐 **Web Interface**: Browse repositories via cgit web UI
- 📦 **Official Container**: Uses the `ghcr.io/damfle/minigit` container image
- 💾 **Persistent Storage**: Configurable persistent volumes for Git repositories (1Gi default)
- 🔒 **Rootless**: Runs as non-root user for enhanced security
- 🚀 **Production Ready**: Health checks, resource limits, and security contexts
- ⚡ **Lightweight**: Alpine-based container with minimal footprint

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
helm install minigit damfle/minigit

# With custom values
helm install minigit damfle/minigit -f values.yaml

# With inline values
helm install minigit damfle/minigit \
  --set generic.persistence.size=20Gi
```

## Configuration

### Basic Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `generic.image.repository` | MiniGit image repository | `ghcr.io/damfle/minigit` |
| `generic.image.tag` | MiniGit image tag | `v0.1.1` |
| `generic.service.port` | Service port | `8080` |
| `generic.persistence.enabled` | Enable persistent storage | `true` |
| `generic.persistence.size` | Storage size | `1Gi` |
| `generic.persistence.mountPath` | Git repositories path | `/data` |
| `generic.replicaCount` | Number of replicas | `1` |

### Advanced Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `generic.ingress.enabled` | Enable ingress | `false` |
| `generic.resources.requests.memory` | Memory request | `128Mi` |
| `generic.resources.limits.memory` | Memory limit | `256Mi` |
| `generic.resources.requests.cpu` | CPU request | `100m` |
| `generic.resources.limits.cpu` | CPU limit | `200m` |
| `generic.securityContext.runAsUser` | User ID | `1000` |
| `generic.securityContext.fsGroup` | Group ID | `1000` |

## Storage Configuration

MiniGit requires persistent storage for Git repositories:

```yaml
generic:
  persistence:
    enabled: true
    storageClassName: "fast-ssd"  # Optional: specify storage class
    size: 10Gi
    accessModes:
      - ReadWriteOnce
    mountPath: /data
```

## Network Access

### ClusterIP (Default)

Access MiniGit within the cluster:

```bash
kubectl port-forward svc/minigit 8080:8080
# Web interface: http://localhost:8080
# Git clone: git clone http://localhost:8080/repo.git
```

## Usage Examples

### Git Operations

Once deployed, you can perform standard Git operations:

First port-forward the service:

```bash
kubectl port-forward service/minigit 8080:8080
```

**Create Repository:**
```bash
kubectl exec -it deployment/minigit -- sh
cd /srv/git
git init --bare myproject.git
chown -R gituser:gituser myproject.git
touch myproject.git/git-daemon-export-ok  # Enable HTTP access
```

**Clone Repository:**
```bash
git clone http://127.0.0.1:8080/myproject.git
```

**Add Remote:**
```bash
git remote add origin http://127.0.0.1:8080/myproject.git
```

**Push Changes:**
```bash
git push origin main
```

**Pull Changes:**
```bash
git pull origin main
```

### Web Interface

Access the cgit web interface by navigating to your configured hostname in a browser:
- Run `kubectl port-forward service/minigit 8080:8080`
- `http://localhost:8080` - Browse repositories, view commits, files, and diffs

### Repository Management

Create new repositories by executing commands in the container:

```bash
# Get shell access to the container
kubectl exec -it deployment/minigit -- sh

# Create a new bare repository
cd /data
git init --bare myproject.git
chown -R gituser:gituser myproject.git
touch myproject.git/git-daemon-export-ok  # Enable HTTP access
```

### Production Configuration Example

```yaml
# values.yaml
generic:
  # Use larger storage for multiple repositories
  persistence:
    enabled: true
    size: 50Gi
    storageClassName: "fast-ssd"

  # Resource limits for production
  resources:
    requests:
      memory: "256Mi"
      cpu: "200m"
    limits:
      memory: "512Mi"
      cpu: "500m"
```

## Security Considerations

- **Rootless Operation**: MiniGit runs as non-root user (gituser) for enhanced security
- **HTTPS**: Use TLS/SSL for external access to protect credentials and data
- **Network Policies**: Consider restricting network access as needed
- **File Permissions**: Repositories are owned by gituser:gituser (UID/GID 1000)
- **Repository Access**: Use `git-daemon-export-ok` files to control repository visibility

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods -l app.kubernetes.io/name=minigit
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Verify Service

```bash
kubectl get svc minigit
kubectl port-forward svc/minigit 8080:8080
curl http://localhost:8080/
```

### Common Issues

1. **Pod stuck in Pending**: Check PVC and storage class configuration
2. **Repository not accessible**: Ensure `git-daemon-export-ok` file exists in repository
3. **Permission errors**: Verify UID/GID settings and storage permissions
4. **Clone/push failures**: Check ingress proxy-body-size annotations for large repositories

### Repository Access Issues

If repositories are not visible via HTTP:

```bash
# Execute in the container
kubectl exec -it deployment/minigit -- sh

# Enable HTTP access for a repository
touch /data/myproject.git/git-daemon-export-ok
chown gituser:gituser /data/myproject.git/git-daemon-export-ok
```

## Client Configuration

### Standard Git Operations

MiniGit works with standard Git clients:

```bash
# Clone
git clone http://git.example.com/project.git

# Add remote
git remote add origin http://git.example.com/project.git

# Push
git push origin main

# Pull
git pull origin main
```

## Upgrading

```bash
# Check current version
helm list

# Upgrade to latest version
helm upgrade minigit damfle/minigit

# Upgrade with new values
helm upgrade minigit damfle/minigit -f new-values.yaml
```

## Uninstalling

```bash
helm uninstall minigit
```

Note: PVCs are not automatically deleted. Remove them manually if needed:

```bash
kubectl delete pvc -l app.kubernetes.io/name=minigit
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

- [MiniGit Source Code](https://github.com/damfle/minigit)
- [cgit Documentation](https://git.zx2c4.com/cgit/)
- [Git HTTP Protocol](https://git-scm.com/docs/http-protocol)
- [Generic Chart Documentation](../generic/README.md)
