# Llama.cpp Helm Chart

A Helm chart for deploying [llama.cpp](https://github.com/ggml-org/llama.cpp) LLM inference server with GPU support.

This chart provides a ready-to-use llama.cpp deployment with sensible defaults for running large language models on NVIDIA GPU-enabled Kubernetes clusters.

## Features

- 🦙 **Llama.cpp Server**: Full llama.cpp inference server
- 🎨 **GPU Support**: Built-in NVIDIA GPU support with runtime class and tolerations
- 💾 **Persistent Storage**: Configurable persistent volume for models and cache
- 🏥 **Health Checks**: Liveness and readiness probes for reliable deployment
- 📊 **Prometheus Monitoring**: ServiceMonitor for Prometheus Operator integration
- 🔑 **Flexible Configuration**: Environment variables for model selection and server settings

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- Persistent Volume provisioner support in the underlying infrastructure
- NVIDIA GPU operator (optional, for GPU support)
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
helm install llamacpp damfle/llamacpp

# With custom values
helm install llamacpp damfle/llamacpp -f values.yaml

# With inline values
helm install llamacpp damfle/llamacpp \
  --set persistence.workspace.size=200Gi
```

## Configuration

### Basic Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Llama.cpp image repository | `ghcr.io/ggml-org/llama.cpp` |
| `image.tag` | Llama.cpp image tag | `server-cuda` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `service.port` | Service port | `8080` |
| `nvidia.enabled` | Enable NVIDIA GPU support | `true` |
| `serviceMonitor.enabled` | Enable Prometheus ServiceMonitor | `true` |

### Environment Variables

| Parameter | Description | Default |
|-----------|-------------|---------|
| `env[0].value` | Home directory | `/workspace` |
| `env[1].value` | Cache directory | `/workspace/cache` |
| `env[2].value` | Context size | `262144` |
| `env[3].value` | HuggingFace model repo | `unsloth/Qwen3.5-9B-GGUF:UD-Q4_K_XL` |
| `env[4].value` | Host address | `0.0.0.0` |
| `env[5].value` | Server port | `8080` |
| `env[6].value` | Enable metrics endpoint | `true` |
| `env[7].value` | Models directory | `/workspace/models` |

### Model Configuration

To use a different model, update the `LLAMA_ARG_HF_REPO` environment variable:

```yaml
env:
  - name: LLAMA_ARG_HF_REPO
    value: "unsloth/Qwen3.5-9B-GGUF:UD-Q4_K_XL"
```

Or disable automatic model download and provide your own models in the workspace PVC:

```yaml
env:
  - name: LLAMA_ARG_HF_REPO
    value: ""
```

### Persistent Volume Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `persistence.workspace.size` | Workspace PVC size | `120Gi` |
| `persistence.workspace.mountPath` | Workspace mount path | `/workspace` |
| `persistence.workspace.storageClassName` | Storage class | `local-path` |

### GPU Configuration

```yaml
# Enable GPU support (default: true)
nvidia:
  enabled: true

# Tolerations for GPU nodes
tolerations:
  - key: nvidia.com/gpu
    operator: Exists
    effect: NoSchedule
```

### Monitoring Configuration

```yaml
serviceMonitor:
  enabled: true
  interval: 30s
  path: /metrics
```

### Resource Configuration

```yaml
resources:
  requests:
    memory: "4Gi"
    cpu: "500m"
  limits:
    memory: "8Gi"
    cpu: "2"
    nvidia.com/gpu: 1
```

## Complete Example

```yaml
# values.yaml

# Image configuration
image:
  repository: ghcr.io/ggml-org/llama.cpp
  tag: server-cuda
  pullPolicy: IfNotPresent

# GPU support
nvidia:
  enabled: true

# Resource limits
resources:
  requests:
    memory: "4Gi"
    cpu: "500m"
  limits:
    memory: "8Gi"
    cpu: "2"
    nvidia.com/gpu: 1

# Environment variables
env:
  - name: HOME
    value: "/workspace"
  - name: LLAMA_CPP_CACHE_DIR
    value: "/workspace/cache"
  - name: LLAMA_ARG_CTX_SIZE
    value: "262144"
  - name: LLAMA_ARG_HF_REPO
    value: "unsloth/Qwen3.5-9B-GGUF:UD-Q4_K_XL"
  - name: LLAMA_ARG_HOST
    value: "0.0.0.0"
  - name: LLAMA_ARG_PORT
    value: "8080"
  - name: LLAMA_ARG_ENDPOINT_METRICS
    value: "true"
  - name: LLAMA_ARG_MODELS_DIR
    value: "/workspace/models"

# Persistent volumes
persistence:
  workspace:
    enabled: true
    storageClassName: "fast-ssd"
    size: 200Gi
    accessModes:
      - ReadWriteOnce
    mountPath: /workspace

# Service
service:
  type: ClusterIP
  port: 8080

# ServiceMonitor for Prometheus
serviceMonitor:
  enabled: true
  interval: 30s
  path: /metrics

# Tolerations for GPU nodes
tolerations:
  - key: nvidia.com/gpu
    operator: Exists
    effect: NoSchedule
```

## Accessing Llama.cpp

After installation, you can access the API:

```bash
# Port-forward to local machine
kubectl port-forward svc/llamacpp 8080:8080

# Test the API
curl http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages": [{"role": "user", "content": "Hello!"}]}'
```

## API Endpoints

- **Health Check**: `GET /health`
- **Metrics**: `GET /metrics`
- **Chat Completions**: `POST /v1/chat/completions`
- **Completions**: `POST /v1/completions`
- **Models**: `GET /v1/models`

## Health Checks

The chart includes built-in health checks:

- **Liveness Probe**: HTTP GET on `/health` with 1800s initial delay, 30s period
- **Readiness Probe**: HTTP GET on `/metrics` with 10s initial delay, 10s period

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods -l app.kubernetes.io/name=llamacpp
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Verify Service

```bash
kubectl get svc llamacpp
kubectl port-forward svc/llamacpp 8080:8080
```

### Common Issues

1. **Pod stuck in Pending**: Check PVC and storage class availability
2. **Service not accessible**: Verify port configuration (8080)
3. **GPU not available**: Ensure NVIDIA operator is installed and tolerations are set
4. **Model download fails**: Check the HuggingFace model repo name and ensure you have network access
5. **Probe failures**: Check liveness/readiness probe paths and initial delays

### Debug Configuration

```bash
# Check environment variables
kubectl exec -it <pod-name> -- env | grep LLAMA

# Check mounted volumes
kubectl exec -it <pod-name> -- ls -la /workspace/

# Test HTTP endpoints
kubectl exec -it <pod-name> -- curl -i http://localhost:8080/health
kubectl exec -it <pod-name> -- curl -i http://localhost:8080/metrics
```

## Model Management

Models are stored in `/workspace/models` by default. You can:

1. **Auto-download from HuggingFace**: Set `LLAMA_ARG_HF_REPO` to a valid model
2. **Pre-load models**: Download GGUF files and place them in the PVC before deployment
3. **Use local models**: Mount a host path with your models

## Upgrading

```bash
# Check current version
helm list

# Upgrade to latest version
helm upgrade llamacpp damfle/llamacpp

# Upgrade with new values
helm upgrade llamacpp damfle/llamacpp -f new-values.yaml
```

## Uninstalling

```bash
helm uninstall llamacpp
```

Note: PVCs are not automatically deleted. Remove them manually if needed:

```bash
kubectl delete pvc -l app.kubernetes.io/name=llamacpp
```

## License

This chart is licensed under the ISC License. See the [LICENSE](../LICENSE) file for details.

## Support

For issues related to:
- **Chart**: Open an issue in this repository
- **Llama.cpp Application**: Check the [llama.cpp project](https://github.com/ggml-org/llama.cpp)

## Links

- [Llama.cpp Project](https://github.com/ggml-org/llama.cpp)
- [Helm Chart Repository](https://damfle.github.io/helm-charts)
- [GGML / GGUF Models](https://huggingface.co/models?library=gguf)
