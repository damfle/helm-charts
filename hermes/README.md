# hermes

A Helm chart for deploying [Hermes Agent](https://github.com/nousresearch/hermes-agent) by Nous Research - a conversational AI agent that grows with you.

## Prerequisites

- Kubernetes 1.20+
- Helm 3.0+

## Installation

### Add the Helm repository

```bash
helm repo add damfle https://damfle.github.io/helm-charts
helm repo update
```

### Install the chart

```bash
helm install hermes damfle/hermes -n hermes --create-namespace
```

### Install with custom values

```bash
helm install hermes damfle/hermes -n hermes --create-namespace -f values.yaml
```

## Configuration

The following table lists the configurable parameters of the Hermes Agent chart and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `generic.image.repository` | Container image repository | `nousresearch/hermes-agent` |
| `generic.image.tag` | Container image tag | `latest` |
| `generic.image.pullPolicy` | Image pull policy | `Always` |
| `generic.replicaCount` | Number of replicas | `1` |
| `generic.service.type` | Service type | `ClusterIP` |
| `generic.service.port` | Service port (Dashboard) | `9119` |
| `generic.service.targetPort` | Service target port (Dashboard) | `9119` |
| `generic.additionalPorts[0].containerPort` | API port | `8642` |
| `generic.livenessProbe.enabled` | Enable liveness probe | `true` |
| `generic.livenessProbe.httpGet.path` | Liveness probe path | `/` |
| `generic.livenessProbe.httpGet.port` | Liveness probe port | `8642` |
| `generic.readinessProbe.enabled` | Enable readiness probe | `true` |
| `generic.readinessProbe.httpGet.path` | Readiness probe path | `/` |
| `generic.readinessProbe.httpGet.port` | Readiness probe port | `8642` |
| `generic.resources.limits.cpu` | CPU limit | `100m` |
| `generic.resources.limits.memory` | Memory limit | `256Mi` |
| `generic.resources.requests.cpu` | CPU request | `10m` |
| `generic.resources.requests.memory` | Memory request | `64Mi` |
| `generic.ingress.enabled` | Enable ingress | `false` |
| `generic.ingress.hosts[0].host` | Ingress host | `hermes.example.com` |
| `generic.persistence.enabled` | Enable persistence | `true` |
| `generic.persistence.size` | Persistence volume size | `1Gi` |
| `generic.persistence.mountPath` | Persistence mount path | `/opt/data` |

## Ingress Configuration

To enable ingress, set the following in your values:

```yaml
generic:
  ingress:
    enabled: true
    className: ""
    annotations: {}
    hosts:
      - host: hermes.yourdomain.com
        paths:
          - path: /
            pathType: Prefix
    tls: []
```

## Examples

### Minimal installation

```bash
helm install hermes damfle/hermes -n hermes --create-namespace
```

### Production installation with ingress and TLS

```yaml
# values-prod.yaml
generic:
  replicaCount: 2
  
  resources:
    limits:
      cpu: 500m
      memory: 1Gi
    requests:
      cpu: 100m
      memory: 256Mi
  
  ingress:
    enabled: true
    className: "nginx"
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-prod
    hosts:
      - host: hermes.example.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: hermes-tls
        hosts:
          - hermes.example.com
```

```bash
helm install hermes damfle/hermes -n hermes --create-namespace -f values-prod.yaml
```

## Uninstalling

```bash
helm uninstall hermes -n hermes
```

## Values Reference

For the complete list of configurable values, please refer to the [values.yaml](values.yaml) file.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request on the [GitHub repository](https://github.com/damfle/helm-charts).

## License

ISC
