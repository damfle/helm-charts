# Ollama Helm Chart

A Helm chart for deploying [Ollama](https://github.com/ollama/ollama) - a tool to run large language models locally on Kubernetes.

This chart extends the [generic chart](../generic/README.md) to provide a ready-to-use Ollama deployment with sensible defaults for AI workloads.

## Features

- 🤖 **Local LLM Inference**: Run large language models locally without external dependencies
- 🚀 **High Performance**: Optimized for CPU and memory-intensive AI workloads
- 💾 **Persistent Model Storage**: 80GB storage for downloading and storing models
- 🔧 **Easy Model Management**: Simple API for downloading and managing models
- 📊 **Resource Optimized**: Configured with appropriate CPU/memory limits for AI inference
- 🔒 **Secure**: Production-ready configuration with security contexts
- 📈 **Scalable**: Support for horizontal scaling (though typically run as single instance)

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- Persistent Volume provisioner support (80GB+ recommended)
- Sufficient cluster resources (2+ CPU cores, 4GB+ RAM recommended)
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
helm install ollama damfle/ollama

# With custom values
helm install ollama damfle/ollama -f values.yaml

# With inline configuration
helm install ollama damfle/ollama \
  --set generic.persistence.size=100Gi \
  --set generic.resources.limits.memory=8Gi \
  --set generic.ingress.enabled=true \
  --set generic.ingress.hosts[0].host=ollama.example.com
```

## Configuration

### Basic Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `generic.image.repository` | Ollama image repository | `ollama/ollama` |
| `generic.image.tag` | Ollama image tag | `0.12.3` |
| `generic.service.port` | Service and container port | `11434` |
| `generic.persistence.enabled` | Enable persistent storage | `true` |
| `generic.persistence.size` | Storage size for models | `16Gi` |
| `generic.persistence.storageClassName` | Storage class | `local-path` |
| `generic.persistence.mountPath` | Mount path for models | `/root/.ollama` |

### Resource Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `generic.resources.requests.cpu` | CPU request | `1000m` |
| `generic.resources.requests.memory` | Memory request | `2Gi` |
| `generic.resources.limits.cpu` | CPU limit | `2000m` |
| `generic.resources.limits.memory` | Memory limit | `4Gi` |

### Health Check Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `generic.livenessProbe.initialDelaySeconds` | Liveness probe initial delay | `60` |
| `generic.livenessProbe.periodSeconds` | Liveness probe period | `30` |
| `generic.readinessProbe.initialDelaySeconds` | Readiness probe initial delay | `30` |
| `generic.readinessProbe.periodSeconds` | Readiness probe period | `10` |

## Storage Configuration

Ollama requires persistent storage to store downloaded models:

```yaml
generic:
  persistence:
    enabled: true
    storageClassName: "fast-ssd"  # Use fast storage for better performance
    size: 100Gi                   # Increase for multiple large models
    accessModes:
      - ReadWriteOnce
    mountPath: /root/.ollama
```

### Storage Requirements by Model Size

| Model Type | Recommended Storage |
|------------|-------------------|
| Small models (7B parameters) | 40-80GB |
| Medium models (13B parameters) | 80-120GB |
| Large models (30B+ parameters) | 120GB+ |
| Multiple models | 200GB+ |

## Network Access

### ClusterIP (Default)

Access Ollama within the cluster:

```bash
kubectl port-forward svc/ollama 11434:11434
# Access via http://localhost:11434
```

### Ingress (Recommended for external access)

Enable external access via ingress:

```yaml
generic:
  ingress:
    enabled: true
    className: "nginx"
    annotations:
      nginx.ingress.kubernetes.io/proxy-body-size: "0"
      nginx.ingress.kubernetes.io/proxy-read-timeout: "600"
      nginx.ingress.kubernetes.io/proxy-send-timeout: "600"
    hosts:
      - host: ollama.example.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: ollama-tls
        hosts:
          - ollama.example.com
```

### Traefik Configuration

For Traefik ingress:

```yaml
generic:
  ingress:
    enabled: true
    annotations:
      traefik.ingress.kubernetes.io/router.entrypoints: web,websecure
      traefik.ingress.kubernetes.io/router.middlewares: default-auth@kubernetescrd
    hosts:
      - host: ollama.example.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - hosts:
        - ollama.example.com
```

## Usage Examples

### Basic Production Setup

```yaml
generic:
  # Resource allocation for production
  resources:
    requests:
      memory: "4Gi"
      cpu: "2000m"
    limits:
      memory: "8Gi"
      cpu: "4000m"

  # Large storage for multiple models
  persistence:
    enabled: true
    size: 200Gi
    storageClassName: "fast-ssd"

  # External access
  ingress:
    enabled: true
    className: "nginx"
    annotations:
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
      nginx.ingress.kubernetes.io/proxy-body-size: "0"
      cert-manager.io/cluster-issuer: "letsencrypt-prod"
    hosts:
      - host: ollama.company.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: ollama-tls
        hosts:
          - ollama.company.com
```

### Development Setup

```yaml
generic:
  # Smaller resources for development
  resources:
    requests:
      memory: "1Gi"
      cpu: "500m"
    limits:
      memory: "2Gi"
      cpu: "1000m"

  # Smaller storage for dev
  persistence:
    size: 40Gi

  # No ingress for local development
  ingress:
    enabled: false
```

### High-Performance Setup (GPU nodes)

```yaml
generic:
  # Higher resource allocation
  resources:
    requests:
      memory: "8Gi"
      cpu: "4000m"
    limits:
      memory: "16Gi"
      cpu: "8000m"

  # Node selector for GPU nodes
  nodeSelector:
    nvidia.com/gpu: "true"

  # Tolerate GPU node taints
  tolerations:
    - key: nvidia.com/gpu
      operator: Exists
      effect: NoSchedule
```

## Model Management

### Downloading Models

Once Ollama is running, you can download models using the API:

```bash
# Download a model
curl -X POST http://ollama.example.com/api/pull -d '{"name": "llama2"}'

# List available models
curl http://ollama.example.com/api/tags

# Run inference
curl -X POST http://ollama.example.com/api/generate -d '{
  "model": "llama2",
  "prompt": "Why is the sky blue?"
}'
```

### Pre-downloading Models (Future Feature)

The chart includes support for pre-downloading models during startup:

```yaml
ollama:
  modelManagement:
    enabled: true
  models:
    - llama2
    - codellama
    - mistral
```

*Note: This feature is planned but not yet implemented.*

## API Usage

### Basic Chat Completion

```bash
curl -X POST http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama2",
    "prompt": "Explain quantum computing in simple terms",
    "stream": false
  }'
```

### Streaming Response

```bash
curl -X POST http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama2",
    "prompt": "Write a short story",
    "stream": true
  }'
```

### Model Information

```bash
# Get model info
curl http://localhost:11434/api/show -d '{"name": "llama2"}'

# List all models
curl http://localhost:11434/api/tags
```

## Performance Tuning

### Resource Optimization

```yaml
# For small models (7B parameters)
generic:
  resources:
    requests:
      memory: "2Gi"
      cpu: "1000m"
    limits:
      memory: "4Gi"
      cpu: "2000m"

# For large models (30B+ parameters)
generic:
  resources:
    requests:
      memory: "8Gi"
      cpu: "4000m"
    limits:
      memory: "16Gi"
      cpu: "8000m"
```

### Storage Performance

- Use SSD storage for better model loading performance
- Consider local storage for highest performance
- Monitor I/O metrics during model downloads

### CPU vs GPU

- CPU-only deployment (default): Good for smaller models and development
- GPU acceleration: Requires GPU nodes and additional configuration
- Consider memory bandwidth and CPU cache size for optimal performance

## Monitoring

### Health Checks

The chart includes comprehensive health checks:

```yaml
generic:
  livenessProbe:
    httpGet:
      path: /
      port: http
    initialDelaySeconds: 60  # Allow time for model loading
    periodSeconds: 30
    timeoutSeconds: 10

  readinessProbe:
    httpGet:
      path: /
      port: http
    initialDelaySeconds: 30
    periodSeconds: 10
    timeoutSeconds: 5
```

### Prometheus Monitoring

Enable service monitor for Prometheus:

```yaml
generic:
  serviceMonitor:
    enabled: true
    interval: 30s
    path: /metrics
    labels:
      app: ollama
```

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods -l app.kubernetes.io/name=ollama
kubectl describe pod <ollama-pod>
kubectl logs <ollama-pod>
```

### Common Issues

1. **Pod startup timeout**: Increase resource limits or initial delay
2. **Model download failures**: Check storage space and network connectivity
3. **Performance issues**: Verify CPU/memory allocation and storage performance
4. **Out of memory**: Increase memory limits or use smaller models

### Model Storage Issues

```bash
# Check storage usage
kubectl exec -it <ollama-pod> -- df -h /root/.ollama

# List downloaded models
kubectl exec -it <ollama-pod> -- ls -la /root/.ollama/models
```

### Performance Debugging

```bash
# Monitor resource usage
kubectl top pod <ollama-pod>

# Check model loading times in logs
kubectl logs <ollama-pod> | grep -i "loading\|loaded"
```

## Security Considerations

- **Network Access**: Restrict ingress access to authorized users
- **Resource Limits**: Set appropriate CPU/memory limits to prevent resource exhaustion
- **Model Security**: Be cautious about downloading untrusted models
- **Data Privacy**: Consider data privacy implications of local LLM inference
- **API Security**: Implement authentication for production deployments

## Scaling

### Horizontal Scaling

While Ollama can be scaled horizontally, consider:

```yaml
generic:
  replicaCount: 3
```

**Note**: Each replica needs its own model storage, significantly increasing storage requirements.

### Vertical Scaling

Preferred approach for most use cases:

```yaml
generic:
  resources:
    requests:
      memory: "16Gi"
      cpu: "8000m"
    limits:
      memory: "32Gi"
      cpu: "16000m"
```

## Upgrading

```bash
# Check current version
helm list

# Upgrade to latest version
helm upgrade ollama damfle/ollama

# Upgrade with new values
helm upgrade ollama damfle/ollama -f new-values.yaml
```

**Note**: Model storage is preserved during upgrades.

## Uninstalling

```bash
helm uninstall ollama
```

**Important**: This will not delete the PVC automatically. Remove it manually if needed:

```bash
kubectl delete pvc -l app.kubernetes.io/name=ollama
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

- [Ollama Repository](https://github.com/ollama/ollama)
- [Ollama Documentation](https://ollama.ai/)
- [Ollama API Documentation](https://github.com/ollama/ollama/blob/main/docs/api.md)
- [Generic Chart Documentation](../generic/README.md)

## Available Models

Popular models you can download with Ollama:

| Model | Size | Description |
|-------|------|-------------|
| llama2 | ~3.8GB | Meta's Llama 2 model |
| codellama | ~3.8GB | Code-focused variant of Llama 2 |
| mistral | ~4.1GB | Mistral 7B model |
| neural-chat | ~4.1GB | Intel's neural chat model |
| starling-lm | ~4.1GB | Starling language model |
| orca-mini | ~1.9GB | Smaller model, good for testing |

Visit [Ollama Models](https://ollama.ai/library) for the complete list.
