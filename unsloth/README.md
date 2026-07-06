# Unsloth Helm Chart

A Helm chart for deploying Unsloth AI inference server with Jupyter support and GPU acceleration.

This chart provides a ready-to-use Unsloth deployment with sensible defaults for AI inference and machine learning workloads, including both the Unsloth AI server (port 8000) and Jupyter Lab (port 8888).

## Features

- 🤖 **Unsloth AI Inference**: Full Unsloth environment for running LLMs efficiently
- 📓 **Jupyter Lab**: Integrated Jupyter Lab for interactive development
- 🎨 **Official Docker Image**: Uses the official `unsloth/unsloth` image from Docker Hub
- 💾 **Persistent Storage**: Configurable persistent volumes for model cache and data
- 🎯 **GPU Support**: Built-in NVIDIA GPU support with runtime class and tolerations
- 🔑 **Secrets Management**: Environment secrets via Kubernetes secrets
- 🌐 **Ingress Ready**: Easy external access configuration with Traefik/NGINX support for both services
- 🏥 **Health Checks**: Liveness and readiness probes for reliable deployment

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- Persistent Volume provisioner support in the underlying infrastructure
- NVIDIA GPU operator (recommended, for GPU support)
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
helm install unsloth damfle/unsloth

# With custom values
helm install unsloth damfle/unsloth -f values.yaml

# With inline values
helm install unsloth damfle/unsloth \
  --set persistence.size=50Gi
```

## Configuration

### Basic Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Unsloth image repository | `unsloth/unsloth` |
| `image.tag` | Unsloth image tag | `latest` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `service.unsloth.port` | Unsloth service port | `8000` |
| `service.jupyter.port` | Jupyter service port | `8888` |
| `nvidia.enabled` | Enable NVIDIA GPU support | `true` |

### Environment Variables

| Parameter | Description | Default |
|-----------|-------------|---------|
| `env[0].value` | Timezone | `Europe/Paris` |
| `env[1].value` | Unsloth max memory | `auto` |
| `env[2].value` | PyTorch CUDA config | `expandable_segments:True` |
| `env[3].value` | HuggingFace datasets cache path | `/tmp/hf_cache` |
| `env[4].value` | HuggingFace home directory | `/tmp/hf_home` |

### Environment from Secrets

The chart supports loading environment variables from existing Kubernetes secrets:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `envFrom` | List of secret/configmap references | `[]` |
| `jupyter.extraEnvFrom` | Additional secrets specific to Jupyter | `[]` |

### Health Checks Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `livenessProbe.enabled` | Enable liveness probe | `true` |
| `readinessProbe.enabled` | Enable readiness probe | `true` |

### Jupyter Configuration

The chart includes JupyterLab environment variables:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `jupyter.env[0].name` | Enable Jupyter Lab | `JUPYTER_ENABLE_LAB=yes` |
| `jupyter.env[1].name` | Jupyter token | `JUPYTER_TOKEN=` (empty) |

## Services

The chart creates two separate services:

1. **Unsloth AI Service** (`<release-name>-unsloth`): Port 8000 for AI inference
2. **Jupyter Service** (`<release-name>-jupyter`): Port 8888 for Jupyter Lab interface

Both services are ClusterIP by default but can be configured as NodePort or LoadBalancer.

### Persistent Volume Configuration

The chart creates a persistent volume for model cache and data:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `persistence.size` | PVC size for model cache and data | `20Gi` |
| `persistence.mountPath` | Mount path | `/data` |
| `persistence.storageClassName` | Storage class | `local-path` |

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

### External Access via Ingress

The chart supports separate ingress configurations for both services:

```yaml
# Ingress for Unsloth AI server
ingress:
  unsloth:
    enabled: true
    className: "nginx"
    annotations:
      nginx.ingress.kubernetes.io/proxy-body-size: "0"
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
      cert-manager.io/cluster-issuer: "letsencrypt-prod"
    hosts:
      - host: unsloth.example.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: unsloth-tls
        hosts:
          - unsloth.example.com

  # Ingress for Jupyter Lab
  jupyter:
    enabled: true
    className: "nginx"
    annotations:
      nginx.ingress.kubernetes.io/proxy-body-size: "0"
    hosts:
      - host: jupyter.example.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: jupyter-tls
        hosts:
          - jupyter.example.com
```

### Secrets Configuration

The chart supports loading environment variables from existing Kubernetes secrets using the `envFrom` configuration. This allows you to use the same secret for both Unsloth and Jupyter containers.

**Supported secret references:**
- `envFrom` - Main environment variables from secrets (shared by both containers and Jupyter)

Example of creating a secret and referencing it:

```bash
# Create a secret with your API tokens
kubectl create secret generic unsloth-env-secrets \
  --from-literal=HF_TOKEN=your_hf_token \
  --from-literal=MISTRAL_API_KEY=your_mistral_key \
  --from-literal=OPENAI_API_KEY=your_openai_key \
  --from-literal=ANTHROPIC_API_KEY=your_anthropic_key
```

Then reference it in your values:

```yaml
envFrom:
  - secretRef:
      name: unsloth-env-secrets
```

You can also reference ConfigMaps:

```yaml
envFrom:
  - configMapRef:
      name: unsloth-config
```

To use multiple secrets or configmaps:

```yaml
envFrom:
  - secretRef:
      name: unsloth-env-secrets
  - configMapRef:
      name: unsloth-config
```

## Complete Example

```yaml
# values.yaml

# Image configuration
image:
  repository: unsloth/unsloth
  tag: latest
  pullPolicy: IfNotPresent

# GPU support
nvidia:
  enabled: true

# Resource limits for AI inference
resources:
  requests:
    memory: "4Gi"
    cpu: "1"
  limits:
    memory: "8Gi"
    cpu: "2"

# Environment variables
env:
  - name: TZ
    value: "Europe/Paris"
  - name: UNSLOTH_MAX_MEMORY
    value: "auto"
  - name: PYTORCH_CUDA_ALLOC_CONF
    value: "expandable_segments:True"
  - name: HF_DATASETS_CACHE
    value: "/tmp/hf_cache"
  - name: HF_HOME
    value: "/tmp/hf_home"

# Jupyter configuration
jupyter:
  env:
    - name: JUPYTER_ENABLE_LAB
      value: "yes"
    - name: JUPYTER_TOKEN
      value: "your-secure-token"
  extraEnvFrom:
    - secretRef:
        name: jupyter-extra-secrets

# Secrets from existing Kubernetes secrets
envFrom:
  - secretRef:
      name: unsloth-env-secrets

# Persistent volume for model cache and data
persistence:
  enabled: true
  storageClassName: "fast-ssd"
  size: 50Gi
  accessModes:
    - ReadWriteOnce
  mountPath: /data

# Services configuration
service:
  unsloth:
    type: ClusterIP
    port: 8000
  jupyter:
    type: ClusterIP
    port: 8888

# Ingress configuration
ingress:
  unsloth:
    enabled: true
    className: "nginx"
    hosts:
      - host: unsloth.example.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: unsloth-tls
        hosts:
          - unsloth.example.com

  jupyter:
    enabled: true
    className: "nginx"
    hosts:
      - host: jupyter.example.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: jupyter-tls
        hosts:
          - jupyter.example.com

# Tolerations for GPU nodes
tolerations:
  - key: nvidia.com/gpu
    operator: Exists
    effect: NoSchedule

# Health check probes configuration
livenessProbe:
  enabled: true
  httpGet:
    path: /api/health
    port: unsloth
  initialDelaySeconds: 60
  periodSeconds: 15

readinessProbe:
  enabled: true
  httpGet:
    path: /api/health
    port: unsloth
  initialDelaySeconds: 30
  periodSeconds: 10
```

## Accessing Services

After installation, you can access the services via:

```bash
# Unsloth AI inference server
kubectl port-forward svc/unsloth-unsloth 8000:8000
# Then access via http://localhost:8000

# Jupyter Lab interface
kubectl port-forward svc/unsloth-jupyter 8888:8888
# Then open http://localhost:8888 in your browser

# If using NodePort services
kubectl get svc unsloth-unsloth
kubectl get svc unsloth-jupyter
# Use the NodePorts to access the services

# If using Ingress
# Access via the configured hostnames (e.g., http://unsloth.example.com, http://jupyter.example.com)
```

## Health Checks

The chart includes built-in health checks for the Unsloth service:

- **Liveness Probe**: HTTP GET on `/health` with 60s initial delay, 15s period
- **Readiness Probe**: HTTP GET on `/health` with 30s initial delay, 10s period

Both probes can be disabled independently by setting their `enabled` flag to `false`:

```yaml
# Disable liveness probe
livenessProbe:
  enabled: false

# Disable readiness probe  
readinessProbe:
  enabled: false
```

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods -l app.kubernetes.io/name=unsloth
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Verify Services

```bash
kubectl get svc unsloth-unsloth
kubectl get svc unsloth-jupyter
kubectl port-forward svc/unsloth-unsloth 8000:8000
kubectl port-forward svc/unsloth-jupyter 8888:8888
```

### Common Issues

1. **Pod stuck in Pending**: Check PVC and storage class availability
2. **Service not accessible**: Verify port configuration (8000 for Unsloth, 8888 for Jupyter)
3. **GPU not available**: Ensure NVIDIA operator is installed and tolerations are set
4. **Secrets not loaded**: Verify the `unsloth-env-secrets` secret exists
5. **Probe failures**: Check liveness/readiness probe paths
6. **Memory issues**: Unsloth AI inference requires significant GPU memory

### Debug Configuration

```bash
# Check environment variables (secrets will be masked)
kubectl exec -it <pod-name> -- env | grep UNSLOTH

# Check mounted volumes
kubectl exec -it <pod-name> -- ls -la /data/

# Test Unsloth HTTP endpoints
kubectl exec -it <pod-name> -- curl -i http://localhost:8000/health

# Check Jupyter Lab
kubectl exec -it <pod-name> -- curl -i http://localhost:8888/

# Check GPU memory usage
kubectl exec -it <pod-name> -- nvidia-smi
```

## Upgrading

```bash
# Check current version
helm list

# Upgrade to latest version
helm upgrade unsloth damfle/unsloth

# Upgrade with new values
helm upgrade unsloth damfle/unsloth -f new-values.yaml
```

## Uninstalling

```bash
helm uninstall unsloth
```

Note: PVCs are not automatically deleted. Remove them manually if needed:

```bash
kubectl delete pvc -l app.kubernetes.io/name=unsloth
```

## License

This chart is licensed under the ISC License. See the [LICENSE](../LICENSE) file for details.

## Support

For issues related to:
- **Chart**: Open an issue in this repository
- **Unsloth Application**: Check the [Unsloth GitHub](https://github.com/unslothai/unsloth)

## Links

- [Unsloth AI](https://github.com/unslothai/unsloth)
- [Unsloth Docker Hub](https://hub.docker.com/r/unsloth/unsloth)
- [Helm Chart Repository](https://damfle.github.io/helm-charts)