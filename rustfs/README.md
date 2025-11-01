# RustFS Helm Chart

A Helm chart for deploying RustFS server - an S3-compatible HTTP-based file storage protocol. Licensed under ISC License.

This chart extends the [generic chart](../generic/README.md) to provide a ready-to-use RustFS deployment with sensible defaults.

## Features

- 🗂️ **S3-Compatible API**: Full S3 protocol compatibility for object storage
- 📦 **Official Container**: Uses the `rustfs/rustfs` container image
- 💾 **Persistent Storage**: Configurable persistent volumes for file storage (16Gi default)
- ⚙️ **Configurable**: Extensive RustFS configuration via environment variables
- 🚀 **Production Ready**: Health checks, resource limits, and security contexts
- 🌐 **Ingress Ready**: Easy external access configuration with Traefik/NGINX support
- 🔐 **S3 Authentication**: Built-in access key and secret key authentication
- 📋 **Console Interface**: Built-in web console for file management
- 🔌 **S3 Client Support**: Works with standard S3 clients (AWS CLI, boto3, MinIO client)

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
helm install rustfs damfle/rustfs

# With custom values
helm install rustfs damfle/rustfs -f values.yaml

# With inline values
helm install rustfs damfle/rustfs \
  --set generic.persistence.size=50Gi \
  --set generic.ingress.enabled=true \
  --set generic.ingress.hosts[0].host=rustfs.example.com
```

## Configuration

### Basic Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `generic.image.repository` | RustFS image repository | `rustfs/rustfs` |
| `generic.image.tag` | RustFS image tag | `1.0.0-alpha.66` |
| `generic.service.port` | Service port | `9090` |
| `generic.containerPort` | Container port | `9090` |
| `generic.persistence.enabled` | Enable persistent storage | `true` |
| `generic.persistence.size` | Storage size | `16Gi` |
| `generic.persistence.mountPath` | Mount path for data | `/data` |
| `generic.env[0].value` | RustFS listen address | `:9090` |
| `generic.env[1].value` | RustFS volumes path | `/data` |
| `generic.env[2].value` | Enable web console | `true` |

### Advanced Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `generic.replicaCount` | Number of replicas | `1` |
| `generic.ingress.enabled` | Enable ingress | `false` |
| `generic.resources.requests.memory` | Memory request | `128Mi` |
| `generic.resources.limits.memory` | Memory limit | `256Mi` |
| `generic.resources.requests.cpu` | CPU request | `100m` |
| `generic.resources.limits.cpu` | CPU limit | `200m` |
| `generic.securityContext.runAsUser` | User ID | `1000` |
| `generic.securityContext.fsGroup` | Group ID | `1000` |

## S3 Credentials Configuration

RustFS requires S3 access credentials for authentication. Configure them via environment variables using Kubernetes secrets:

### Create S3 Credentials Secret

```bash
kubectl create secret generic rustfs-s3-credentials \
  --from-literal=RUSTFS_ACCESS_KEY=rustfsadmin \
  --from-literal=RUSTFS_SECRET_KEY=rustfsadmin
```

### Configure Chart to Use Secret

```yaml
generic:
  env:
    - name: RUSTFS_ADDRESS
      value: ":9090"
    - name: RUSTFS_VOLUMES
      value: "/data"
    - name: RUSTFS_CONSOLE_ENABLE
      value: "true"
    - name: RUSTFS_ACCESS_KEY
      valueFrom:
        secretKeyRef:
          name: rustfs-s3-credentials
          key: RUSTFS_ACCESS_KEY
    - name: RUSTFS_SECRET_KEY
      valueFrom:
        secretKeyRef:
          name: rustfs-s3-credentials
          key: RUSTFS_SECRET_KEY
```

## Environment Variables

RustFS can be configured via environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `RUSTFS_ADDRESS` | Address and port to bind | `:9090` |
| `RUSTFS_VOLUMES` | Volumes to serve | `/data` |
| `RUSTFS_CONSOLE_ENABLE` | Enable web console | `true` |
| `RUSTFS_ACCESS_KEY` | S3 access key for authentication | Required |
| `RUSTFS_SECRET_KEY` | S3 secret key for authentication | Required |

## Storage Configuration

RustFS requires persistent storage for files:

```yaml
generic:
  persistence:
    enabled: true
    storageClassName: "fast-ssd"  # Optional: specify storage class
    size: 50Gi
    accessModes:
      - ReadWriteOnce
    mountPath: /data
```

## Network Access

### ClusterIP (Default)

Access RustFS within the cluster:

```bash
kubectl port-forward svc/rustfs 8080:9090
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
      - host: rustfs.example.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: rustfs-tls
        hosts:
          - rustfs.example.com
```

## Usage Examples

### Basic File Operations

Once deployed, you can access RustFS via:

**Web Console:**
- Navigate to `http://rustfs.example.com`
- Use the built-in web interface for file management

**S3 API (AWS CLI):**
```bash
# Configure AWS CLI with RustFS credentials
aws configure set aws_access_key_id rustfsadmin
aws configure set aws_secret_access_key rustfsadmin
aws configure set default.region us-east-1

# List buckets (volumes)
aws --endpoint-url http://rustfs.example.com s3 ls

# List objects in bucket
aws --endpoint-url http://rustfs.example.com s3 ls s3://data/

# Upload file
aws --endpoint-url http://rustfs.example.com s3 cp localfile.txt s3://data/

# Download file
aws --endpoint-url http://rustfs.example.com s3 cp s3://data/filename.txt ./

# Create bucket/directory
aws --endpoint-url http://rustfs.example.com s3 mb s3://newbucket
```

**S3 SDK (Python/boto3):**
```python
import boto3

# Initialize S3 client
s3 = boto3.client(
    's3',
    endpoint_url='http://rustfs.example.com',
    aws_access_key_id='rustfsadmin',
    aws_secret_access_key='rustfsadmin'
)

# List buckets
response = s3.list_buckets()
print(response['Buckets'])

# Upload file
s3.upload_file('localfile.txt', 'data', 'remotefile.txt')
```

### Advanced Configuration Example

```yaml
# values.yaml
generic:
  # S3 credentials from secret
  env:
    - name: RUSTFS_ADDRESS
      value: ":9090"
    - name: RUSTFS_VOLUMES
      value: "/data"
    - name: RUSTFS_CONSOLE_ENABLE
      value: "true"
    - name: RUSTFS_ACCESS_KEY
      valueFrom:
        secretKeyRef:
          name: rustfs-s3-credentials
          key: RUSTFS_ACCESS_KEY
    - name: RUSTFS_SECRET_KEY
      valueFrom:
        secretKeyRef:
          name: rustfs-s3-credentials
          key: RUSTFS_SECRET_KEY

  # External access with authentication
  ingress:
    enabled: true
    annotations:
      traefik.ingress.kubernetes.io/router.entrypoints: web,websecure
      traefik.ingress.kubernetes.io/router.middlewares: authentik-ak-outpost-authentik-embedded-outpost@kubernetescrd
    hosts:
      - host: rustfs.yourdomain.com
        paths:
          - path: /
            pathType: Prefix
  
  # Larger storage for file sharing
  persistence:
    enabled: true
    storageClassName: "local-path"
    size: 100Gi

  # Resource optimization
  resources:
    requests:
      memory: "256Mi"
      cpu: "200m"
    limits:
      memory: "512Mi"
      cpu: "500m"
```

### Production Deployment Example

```yaml
# production-values.yaml
generic:
  # High availability setup (not recommended for RustFS due to file locking)
  replicaCount: 1

  # Environment configuration with S3 credentials
  env:
    - name: RUSTFS_ADDRESS
      value: ":9090"
    - name: RUSTFS_VOLUMES
      value: "/data"
    - name: RUSTFS_CONSOLE_ENABLE
      value: "true"
    - name: RUSTFS_ACCESS_KEY
      valueFrom:
        secretKeyRef:
          name: rustfs-s3-credentials
          key: RUSTFS_ACCESS_KEY
    - name: RUSTFS_SECRET_KEY
      valueFrom:
        secretKeyRef:
          name: rustfs-s3-credentials
          key: RUSTFS_SECRET_KEY

  # Large storage for production use
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
      - secretName: rustfs-tls
        hosts:
          - files.company.com

  # Production resource limits
  resources:
    requests:
      memory: "512Mi"
      cpu: "250m"
    limits:
      memory: "1Gi"
      cpu: "1000m"

  # Security hardening
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 1000
    allowPrivilegeEscalation: false
    readOnlyRootFilesystem: false
```

## Security Considerations

- **S3 Credentials**: Always use strong, unique access keys and secret keys
- **Secrets Management**: Store S3 credentials in Kubernetes secrets, never in plain text
- **Network Security**: Use HTTPS for external access to protect S3 API traffic
- **Authentication**: S3 API provides built-in authentication via access/secret keys
- **Network Policies**: Consider restricting network access to necessary services
- **File Permissions**: Configure appropriate UID/GID for file access
- **Storage Security**: Use encrypted storage classes when possible
- **Resource Limits**: Set appropriate CPU and memory limits
- **Key Rotation**: Regularly rotate S3 access keys for enhanced security

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods -l app.kubernetes.io/name=rustfs
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Verify Service

```bash
kubectl get svc rustfs
kubectl port-forward svc/rustfs 8080:9090
curl http://localhost:8080/
```

### Common Issues

1. **Pod stuck in Pending**: Check PVC and storage class availability
2. **Service not accessible**: Verify port configuration (9090)
3. **S3 Authentication failures**: Verify RUSTFS_ACCESS_KEY and RUSTFS_SECRET_KEY are set correctly
4. **File permission errors**: Check UID/GID settings and storage permissions
5. **Upload failures**: Verify ingress proxy-body-size annotations
6. **Console not loading**: Check RUSTFS_CONSOLE_ENABLE environment variable
7. **S3 client connection issues**: Verify endpoint URL and credentials configuration

### Debug Configuration

```bash
# Check environment variables (credentials will be masked)
kubectl exec -it <pod-name> -- env | grep RUSTFS

# Check mounted volumes
kubectl exec -it <pod-name> -- ls -la /data

# Test HTTP endpoints
kubectl exec -it <pod-name> -- curl -i http://localhost:9090/

# Test S3 API endpoint
kubectl exec -it <pod-name> -- curl -i http://localhost:9090/
```

## Health Checks

The chart includes built-in health checks:

- **Liveness Probe**: HTTP GET on `/` with 30s initial delay
- **Readiness Probe**: HTTP GET on `/` with 5s initial delay

## Monitoring

While ServiceMonitor is disabled by default, you can enable Prometheus monitoring:

```yaml
generic:
  serviceMonitor:
    enabled: true
    path: /metrics  # If RustFS provides metrics endpoint
    interval: 30s
```

## Upgrading

```bash
# Check current version
helm list

# Upgrade to latest version
helm upgrade rustfs damfle/rustfs

# Upgrade with new values
helm upgrade rustfs damfle/rustfs -f new-values.yaml
```

## Uninstalling

```bash
helm uninstall rustfs
```

Note: PVCs are not automatically deleted. Remove them manually if needed:

```bash
kubectl delete pvc -l app.kubernetes.io/name=rustfs
```

## Migration

### From other S3-compatible storage

When migrating from other S3-compatible systems (MinIO, AWS S3, etc.):

1. **Data Migration**: Use S3 sync tools to migrate existing buckets/objects
2. **Credentials**: Update S3 credentials to use RustFS access/secret keys
3. **Client Configuration**: Update S3 client endpoint URLs to point to RustFS
4. **Bucket Structure**: RustFS uses volume-based storage, map buckets to volumes appropriately

### Migration Commands

```bash
# Migrate from MinIO to RustFS using AWS CLI
aws --endpoint-url http://old-minio.example.com s3 sync s3://source-bucket/ ./temp-migration/
aws --endpoint-url http://rustfs.example.com s3 sync ./temp-migration/ s3://data/

# Direct S3-to-S3 migration
aws s3 sync s3://source-bucket/ s3://destination-bucket/ \
  --source-region us-east-1 \
  --region us-east-1 \
  --endpoint-url http://rustfs.example.com
```

## Performance Tuning

- **Storage**: Use high-performance storage classes (SSD) for better I/O
- **Resources**: Adjust CPU/memory based on file size and concurrent users
- **Network**: Consider ingress controller optimization for large file transfers

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the chart thoroughly
5. Submit a pull request

Please ensure all changes maintain compatibility with the generic base chart.

## License

This chart is licensed under the ISC License. See the [LICENSE](../LICENSE) file for details.

## Links

- [RustFS Project](https://github.com/rustfs/rustfs)
- [RustFS Docker Image](https://hub.docker.com/r/rustfs/rustfs)
- [Generic Chart Documentation](../generic/README.md)
- [Helm Chart Repository](https://damfle.github.io/helm-charts)

## Support

For issues related to:
- **Chart**: Open an issue in this repository
- **RustFS Application**: Check the [RustFS project](https://github.com/rustfs/rustfs)
- **Generic Chart**: See [generic chart documentation](../generic/README.md)