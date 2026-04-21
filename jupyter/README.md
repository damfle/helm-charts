# Jupyter Helm Chart

A Helm chart for deploying Jupyter Notebook/Lab server with GPU support.

This chart provides a ready-to-use Jupyter deployment with sensible defaults for data science and machine learning workloads.

## Features

- 📓 **Jupyter Notebook/Lab**: Full Jupyter environment with Lab interface
- 🎨 **Custom Docker Image**: Uses a pre-configured Jupyter image with data science libraries
- 💾 **Persistent Storage**: Configurable persistent volumes for notebooks, settings, and shared data
- 🎯 **GPU Support**: Built-in NVIDIA GPU support with runtime class and tolerations
- 🔑 **Secrets Management**: Environment secrets via SealedSecret or regular Kubernetes secrets
- 🌐 **Ingress Ready**: Easy external access configuration with Traefik/NGINX support
- 🏥 **Health Checks**: Liveness and readiness probes for reliable deployment
- 📊 **MLFlow Integration**: Pre-configured MLFlow tracking URI

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- Persistent Volume provisioner support in the underlying infrastructure
- NVIDIA GPU operator (optional, for GPU support)
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
helm install jupyter damfle/jupyter

# With custom values
helm install jupyter damfle/jupyter -f values.yaml

# With inline values
helm install jupyter damfle/jupyter \
  --set persistence.workspace.size=100Gi
```

## Configuration

### Basic Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Jupyter image repository | `git.flety.net/damien/docker-jupyter` |
| `image.tag` | Jupyter image tag | `0.1.2` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `service.port` | Service port | `8888` |
| `nvidia.enabled` | Enable NVIDIA GPU support | `true` |

### Environment Variables

| Parameter | Description | Default |
|-----------|-------------|---------|
| `env[0].value` | Enable Jupyter Lab | `yes` |
| `env[1].value` | MLFlow tracking URI | `http://mlflow.mlflow.svc.cluster.local` |
| `env[2].value` | PyTorch CUDA config | `expandable_segments:True` |
| `env[3].value` | Tokenizers parallelism | `false` |
| `env[4].value` | HuggingFace cache path | `/tmp/hf_cache` |

### Persistent Volume Configuration

The chart creates 3 separate PVCs:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `persistence.workspace.size` | Workspace PVC size for notebooks | `120Gi` |
| `persistence.workspace.mountPath` | Workspace mount path | `/home/jupyter/notebooks` |
| `persistence.settings.size` | Settings PVC size for jupyter config | `1Gi` |
| `persistence.settings.mountPath` | Settings mount path | `/home/jupyter/.jupyter` |
| `persistence.share.size` | Share PVC size for shared data | `1Gi` |
| `persistence.share.mountPath` | Share mount path | `/home/jupyter/.local/share/jupyter/` |

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

```yaml
ingress:
  enabled: true
  className: "nginx"
  annotations:
    nginx.ingress.kubernetes.io/proxy-body-size: "0"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
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

The chart expects a secret named `jupyter-env-secrets` containing environment variables like:
- `HF_TOKEN` - HuggingFace API token
- `MISTRAL_API_KEY` - Mistral API key
- `OPENAI_API_KEY` - OpenAI API key

You can create this using SealedSecrets or regular Kubernetes secrets:

```bash
# Using kubeseal (SealedSecrets)
kubeseal --format yaml < jupyter-env-secrets.sealed.yaml > jupyter-env-secrets.yaml
kubectl apply -f jupyter-env-secrets.yaml

# Or using regular Kubernetes secrets
kubectl create secret generic jupyter-env-secrets \
  --from-literal=HF_TOKEN=your_hf_token \
  --from-literal=MISTRAL_API_KEY=your_mistral_key \
  --from-literal=OPENAI_API_KEY=your_openai_key
```

## Complete Example

```yaml
# values.yaml

# Image configuration
image:
  repository: git.flety.net/damien/docker-jupyter
  tag: 0.1.2
  pullPolicy: IfNotPresent

# GPU support
nvidia:
  enabled: true

# Resource limits
resources:
  requests:
    memory: "2Gi"
    cpu: "500m"
  limits:
    memory: "4Gi"
    cpu: "2"

# Environment variables
env:
  - name: JUPYTER_ENABLE_LAB
    value: "yes"
  - name: MLFLOW_TRACKING_URI
    value: "http://mlflow.mlflow.svc.cluster.local"
  - name: PYTORCH_CUDA_ALLOC_CONF
    value: "expandable_segments:True"
  - name: TOKENIZERS_PARALLELISM
    value: "false"
  - name: HF_DATASETS_CACHE
    value: "/tmp/hf_cache"

# Secrets
envFrom:
  - secretRef:
      name: jupyter-env-secrets

# Persistent volumes
persistence:
  workspace:
    enabled: true
    storageClassName: "fast-ssd"
    size: 200Gi
    accessModes:
      - ReadWriteOnce
    mountPath: /home/jupyter/notebooks

  settings:
    enabled: true
    storageClassName: "fast-ssd"
    size: 1Gi
    accessModes:
      - ReadWriteOnce
    mountPath: /home/jupyter/.jupyter

  share:
    enabled: true
    storageClassName: "fast-ssd"
    size: 1Gi
    accessModes:
      - ReadWriteOnce
    mountPath: /home/jupyter/.local/share/jupyter/

# Ingress
ingress:
  enabled: true
  className: "nginx"
  hosts:
    - host: notebooks.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: jupyter-tls
      hosts:
        - notebooks.example.com

# Tolerations for GPU nodes
tolerations:
  - key: nvidia.com/gpu
    operator: Exists
    effect: NoSchedule
```

## Accessing Jupyter

After installation, you can access Jupyter via:

```bash
# If using ClusterIP service
kubectl port-forward svc/jupyter 8888:8888
# Then open http://localhost:8888 in your browser

# If using NodePort service
kubectl get svc jupyter
# Use the NodePort to access the service

# If using Ingress
# Access via the configured hostname (e.g., http://jupyter.example.com)
```

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods -l app.kubernetes.io/name=jupyter
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Verify Service

```bash
kubectl get svc jupyter
kubectl port-forward svc/jupyter 8888:8888
```

### Common Issues

1. **Pod stuck in Pending**: Check PVC and storage class availability
2. **Service not accessible**: Verify port configuration (8888)
3. **GPU not available**: Ensure NVIDIA operator is installed and tolerations are set
4. **Secrets not loaded**: Verify the `jupyter-env-secrets` secret exists
5. **Probe failures**: Check liveness/readiness probe paths

### Debug Configuration

```bash
# Check environment variables (secrets will be masked)
kubectl exec -it <pod-name> -- env | grep JUPYTER

# Check mounted volumes
kubectl exec -it <pod-name> -- ls -la /home/jupyter/

# Test HTTP endpoints
kubectl exec -it <pod-name> -- curl -i http://localhost:8888/
```

## Health Checks

The chart includes built-in health checks:

- **Liveness Probe**: HTTP GET on `/api` with 30s initial delay, 30s period
- **Readiness Probe**: HTTP GET on `/api` with 10s initial delay, 10s period

## Upgrading

```bash
# Check current version
helm list

# Upgrade to latest version
helm upgrade jupyter damfle/jupyter

# Upgrade with new values
helm upgrade jupyter damfle/jupyter -f new-values.yaml
```

## Uninstalling

```bash
helm uninstall jupyter
```

Note: PVCs are not automatically deleted. Remove them manually if needed:

```bash
kubectl delete pvc -l app.kubernetes.io/name=jupyter
```

## License

This chart is licensed under the ISC License. See the [LICENSE](../LICENSE) file for details.

## Support

For issues related to:
- **Chart**: Open an issue in this repository
- **Jupyter Application**: Check the [Jupyter project](https://jupyter.org/)

## Links

- [Jupyter Project](https://jupyter.org/)
- [Helm Chart Repository](https://damfle.github.io/helm-charts)
