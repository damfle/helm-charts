# mcp-luanti

A Helm chart for deploying the [mcp-luanti gateway](https://git.flety.net/damien/mcp-luanti). This gateway enables control of a running [Luanti](https://github.com/luanti-org/luanti) server from an MCP client without implementing the Luanti network protocol.

## Introduction

This chart deploys the **mcp-luanti gateway** as a Kubernetes application. The gateway is a standalone HTTP server that acts as the stable network endpoint between:

- **Luanti mod (`sapi/`)** – polls the gateway for commands
- **MCP server (`mcp_sapi/`)** – pushes commands to the gateway via HTTP

The gateway decouples the lifecycles of the Luanti mod (which runs within the Luanti server) and the MCP server (which is started/stopped by the MCP client over stdio).

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+

## Installing the Chart

Add the Helm repository:

```bash
helm repo add damfle https://damfle.github.io/helm-charts
helm repo update
```

Install the chart:

```bash
helm install mcp-luanti damfle/mcp-luanti -f values.yaml
```

Or with custom values:

```bash
helm install mcp-luanti damfle/mcp-luanti \
  --set generic.image.repository=git.flety.net/damien/mcp-luanti/gateway \
  --set generic.image.tag=latest \
  --set generic.ingress.hosts[0].host=mcp-luanti.yourdomain.com
```

## Uninstalling the Chart

```bash
helm uninstall mcp-luanti
```

## Configuration

The following table lists the configurable parameters of the mcp-luanti chart and their default values.

### Gateway Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `generic.image.repository` | Gateway container image repository | `git.flety.net/damien/mcp-luanti/gateway` |
| `generic.image.tag` | Gateway container image tag | `latest` |
| `generic.image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `generic.replicaCount` | Number of gateway replicas | `1` |

### Service Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `generic.service.type` | Kubernetes service type | `ClusterIP` |
| `generic.service.port` | Service port | `8765` |
| `generic.service.targetPort` | Target port on the pod | `8765` |

### Ingress Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `generic.ingress.enabled` | Enable ingress | `true` |
| `generic.ingress.className` | Ingress class name | `""` |
| `generic.ingress.annotations` | Ingress annotations | `{}` |
| `generic.ingress.hosts` | Ingress host configuration | See values.yaml |
| `generic.ingress.tls` | TLS configuration | `[]` |

### Health Checks

| Parameter | Description | Default |
|-----------|-------------|---------|
| `generic.livenessProbe.enabled` | Enable liveness probe | `true` |
| `generic.livenessProbe.httpGet.path` | Liveness probe path | `/health` |
| `generic.livenessProbe.httpGet.port` | Liveness probe port | `8765` |
| `generic.readinessProbe.enabled` | Enable readiness probe | `true` |
| `generic.readinessProbe.httpGet.path` | Readiness probe path | `/health` |
| `generic.readinessProbe.httpGet.port` | Readiness probe port | `8765` |

### Resources

| Parameter | Description | Default |
|-----------|-------------|---------|
| `generic.resources.limits.cpu` | CPU limit | `100m` |
| `generic.resources.limits.memory` | Memory limit | `256Mi` |
| `generic.resources.requests.cpu` | CPU request | `10m` |
| `generic.resources.requests.memory` | Memory request | `64Mi` |

### Security

| Parameter | Description | Default |
|-----------|-------------|---------|
| `generic.securityContext.runAsNonRoot` | Run as non-root | `true` |
| `generic.securityContext.runAsUser` | User ID | `1000` |
| `generic.securityContext.runAsGroup` | Group ID | `1000` |
| `generic.securityContext.fsGroup` | FS Group ID | `1000` |

### Persistence

| Parameter | Description | Default |
|-----------|-------------|---------|
| `generic.persistence.enabled` | Enable persistence | `false` |

## Complete Setup with Luanti

This Helm chart deploys only the **gateway** component. To use it with Luanti:

1. **Deploy the gateway** using this Helm chart
2. **Install the mod** – Copy or symlink the `sapi/` directory into your world's `worldmods/` directory and enable it
3. **Configure Luanti** (`minetest.conf`) – Add the gateway URL:

```ini
secure.http_mods = sapi
server_api_url = http://mcp-luanti.yourdomain.com
# Optional tuning:
# server_api_poll_interval = 0.2
# server_api_poll_timeout = 35
```

4. **Configure the MCP client** – Point your MCP server to the gateway:

```json
{
  "mcpServers": {
    "luanti-sapi": {
      "command": "python",
      "args": ["-m", "mcp_sapi", "--gateway-url", "http://mcp-luanti.yourdomain.com"]
    }
  }
}
```

## Architecture

```
sapi (Lua mod)  --poll-->  gateway  <--command--  mcp_sapi  <--stdio-->  MCP client
                (HTTP)     (HTTP)
```

The gateway is the central component that:
- Receives commands from the MCP server
- Makes them available to the Luanti mod via polling
- Returns results from the mod back to the MCP client

## Values

Default values are defined in `values.yaml`. To override them, create a custom values file or use `--set` flags during installation.

## Dependencies

This chart depends on the [generic](https://damfle.github.io/helm-charts) chart (version 1.0.9+) which provides common Kubernetes resource templates.

## License

This Helm chart is provided under the same license as the mcp-luanti project. See the [upstream project](https://git.flety.net/damien/mcp-luanti) for license details.

## Maintainers

| Name | Email |
|------|-------|
| Damien FLETY | damfle+github@proton.me |

## Source Code

- Helm chart: https://github.com/damfle/helm-charts
- mcp-luanti gateway: https://git.flety.net/damien/mcp-luanti
- Luanti engine: https://github.com/luanti-org/luanti

## Notes

- The gateway defaults to port 8765 and binds to 0.0.0.0 in the container
- Debug mode is enabled by default via the `--debug` argument
- Adjust resource limits and replica count based on your expected load
- For production use, configure TLS in the ingress and set appropriate resource limits
- The gateway is stateless, so multiple replicas can be deployed for high availability
- Each MCP client instance connects to the gateway, which then communicates with the Luanti server via its installed mod

For more information about the mcp-luanti gateway architecture, available tools, and bot management, see the [upstream README](https://git.flety.net/damien/mcp-luanti).

---

*This README is for the Helm chart only. For detailed information about the mcp-luanti gateway, mod, and MCP server, refer to the [mcp-luanti project documentation](https://git.flety.net/damien/mcp-luanti).*
