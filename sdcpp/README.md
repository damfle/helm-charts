# Stable Diffusion.cpp Helm Chart

A Helm chart for deploying [stable-diffusion.cpp](https://github.com/leejet/stable-diffusion.cpp) image generation server with GPU support.

This chart provides a ready-to-use stable-diffusion.cpp deployment with sensible defaults for running Stable Diffusion models on NVIDIA GPU-enabled Kubernetes clusters.

## Features

- 🎨 **Stable Diffusion.cpp Server**: Full stable-diffusion.cpp inference server
- 🖥️ **GPU Support**: Built-in NVIDIA GPU support
- 💾 **Persistent Storage**: Configurable persistent volume for models
- 🏥 **Health Checks**: Liveness and readiness probes for reliable deployment
- 📊 **Prometheus Monitoring**: ServiceMonitor for Prometheus Operator integration (optional)
- 🔑 **Flexible Configuration**: Command-line arguments for model selection and server settings

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- Persistent Volume provisioner support in the underlying infrastructure
- NVIDIA GPU operator (recommended, for GPU support)
- Prometheus Operator (optional, for monitoring)

## Installation

### Add the repository

```bash
helm repo add damfle https://damfle.github.io/helm-charts
helm repo update
```

### Install the chart

```bash
# Basic installation
helm install sdcpp damfle/sdcpp

# With custom values
helm install sdcpp damfle/sdcpp -f values.yaml

# With inline values
helm install sdcpp damfle/sdcpp \
  --set generic.persistence.size=200Gi
```

## Configuration

### Basic Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `generic.image.repository` | stable-diffusion.cpp image repository | `ghcr.io/leejet/stable-diffusion.cpp` |
| `generic.image.tag` | Image tag | `master-vulkan` |
| `generic.image.pullPolicy` | Image pull policy | `Always` |
| `generic.service.port` | Service port | `1234` |
| `generic.replicaCount` | Number of replicas | `1` |

### Server Arguments

The chart configures stable-diffusion.cpp with the following default arguments:

```yaml
generic:
  args:
    - --listen-ip
    - "0.0.0.0"
    - --listen-port
    - "1234"
    - --color
    - --offload-to-cpu
    - --qwen-image-zero-cond-t
    - --diffusion-fa
    - --flow-shift
    - "3"
    - -H
    - "1024"
    - -W
    - "1024"
    - -v
    - --sampling-method
    - euler
    - --cfg-scale
    - "2.5"
```

### Persistent Volume Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `generic.persistence.enabled` | Enable persistence | `true` |
| `generic.persistence.size` | PVC size | `30Gi` |
| `generic.persistence.mountPath` | Mount path | `/models/` |
| `generic.persistence.storageClassName` | Storage class | `local-path` |

### GPU Configuration

GPU support is enabled by default through the NVIDIA device plugin. Ensure your cluster has:
- NVIDIA GPU operator installed
- Appropriate tolerations for GPU nodes

```yaml
# Add tolerations for GPU nodes
generic:
  tolerations:
    - key: nvidia.com/gpu
      operator: Exists
      effect: NoSchedule
```

### Resource Configuration

```yaml
generic:
  resources:
    requests:
      memory: "8Gi"
      cpu: "1"
    limits:
      memory: "16Gi"
      cpu: "2"
      nvidia.com/gpu: 1
```

### Monitoring Configuration

```yaml
generic:
  serviceMonitor:
    enabled: true
    interval: 30s
    path: /metrics
```

### Ingress Configuration

```yaml
generic:
  ingress:
    enabled: true
    className: ""
    annotations: {}
    hosts:
      - host: sdcpp.local
        paths:
          - path: /
            pathType: Prefix
    tls: []
```

## Complete Example

```yaml
# values.yaml

generic:
  # Image configuration
  image:
    repository: ghcr.io/leejet/stable-diffusion.cpp
    tag: master-vulkan
    pullPolicy: Always

  # Service configuration
  service:
    type: ClusterIP
    port: 1234

  # Single replica
  replicaCount: 1

  # Server arguments
  args:
    - --listen-ip
    - "0.0.0.0"
    - --listen-port
    - "1234"
    - --color
    - --offload-to-cpu
    - --qwen-image-zero-cond-t
    - --diffusion-fa
    - --flow-shift
    - "3"
    - -H
    - "1024"
    - -W
    - "1024"
    - -v
    - --sampling-method
    - euler
    - --cfg-scale
    - "2.5"

  # Persistent storage for models
  persistence:
    enabled: true
    storageClassName: "fast-ssd"
    size: 200Gi
    accessModes:
      - ReadWriteOnce
    mountPath: /models/

  # Resource limits
  resources:
    requests:
      memory: "8Gi"
      cpu: "1"
    limits:
      memory: "16Gi"
      cpu: "2"
      nvidia.com/gpu: 1

  # Tolerations for GPU nodes
  tolerations:
    - key: nvidia.com/gpu
      operator: Exists
      effect: NoSchedule

  # Monitoring
  serviceMonitor:
    enabled: true
    interval: 30s
    path: /metrics

  # Ingress
  ingress:
    enabled: true
    className: "nginx"
    hosts:
      - host: sdcpp.example.com
        paths:
          - path: /
            pathType: Prefix
```

## Accessing Stable Diffusion.cpp

After installation, you can access the API:

```bash
# Port-forward to local machine
kubectl port-forward svc/sdcpp 1234:1234

# The server listens on port 1234 by default
```

## API Endpoints

Stable Diffusion.cpp provides a web interface and API on the configured port (default: 1234).

- **Web Interface**: Access the web UI at `http://<service-ip>:1234`
- **API**: Various endpoints for image generation (see [stable-diffusion.cpp documentation](https://github.com/leejet/stable-diffusion.cpp))

## Health Checks

The chart includes configurable health checks (disabled by default):

```yaml
generic:
  livenessProbe:
    enabled: true
    httpGet:
      path: /
      port: 1234
    initialDelaySeconds: 120
    periodSeconds: 60

  readinessProbe:
    enabled: true
    httpGet:
      path: /
      port: 1234
    initialDelaySeconds: 30
    periodSeconds: 30
```

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods -l app.kubernetes.io/name=sdcpp
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Verify Service

```bash
kubectl get svc sdcpp
kubectl port-forward svc/sdcpp 1234:1234
```

### Common Issues

1. **Pod stuck in Pending**: Check PVC and storage class availability
2. **Service not accessible**: Verify port configuration (1234)
3. **GPU not available**: Ensure NVIDIA operator is installed and tolerations are set
4. **Model paths incorrect**: Verify model files are in `/models/` in your PVC
5. **Probe failures**: Check liveness/readiness probe paths and ports

### Debug Configuration

```bash
# Check environment and arguments
kubectl exec -it <pod-name> -- env
kubectl get pod <pod-name> -o jsonpath='{.spec.containers[0].args}'

# Check mounted volumes
kubectl exec -it <pod-name> -- ls -la /models/

# Test HTTP endpoint
kubectl exec -it <pod-name> -- curl -i http://localhost:1234
```

## Model Management

Models are stored in `/models/` by default. You can:

1. **Pre-load models**: Download model files (`.safetensors`, `.ckpt`, etc.) and place them in the PVC before deployment
2. **Use hostPath**: Mount a host path with your models for development
3. **Custom paths**: Change the mount path via `generic.persistence.mountPath`

## Upgrading

```bash
# Check current version
helm list

# Upgrade to latest version
helm upgrade sdcpp damfle/sdcpp

# Upgrade with new values
helm upgrade sdcpp damfle/sdcpp -f new-values.yaml
```

## Uninstalling

```bash
helm uninstall sdcpp
```

Note: PVCs are not automatically deleted. Remove them manually if needed:

```bash
kubectl delete pvc -l app.kubernetes.io/name=sdcpp
```

## License

This chart is licensed under the ISC License. See the [LICENSE](../LICENSE) file for details.

## Support

For issues related to:
- **Chart**: Open an issue in this repository
- **Stable Diffusion.cpp Application**: Check the [stable-diffusion.cpp project](https://github.com/leejet/stable-diffusion.cpp)

## Links

- [Stable Diffusion.cpp Project](https://github.com/leejet/stable-diffusion.cpp)
- [Helm Chart Repository](https://damfle.github.io/helm-charts)
