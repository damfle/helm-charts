# Helm Charts Repository

This repository contains multiple Helm charts for Kubernetes deployments, managed with automated CI/CD pipelines for continuous testing, building, and deployment.

## Repository Structure

```
├── .github/
│   ├── workflows/
│   │   ├── ci.yml             # Continuous Integration
│   │   └── cd.yml             # Continuous Deployment
│   ├── ct.yaml                # Chart testing configuration
│   └── linters/
│       └── lintconf.yaml      # YAML linting rules
├── generic/                   # Generic application chart (base)
│   ├── Chart.yaml
│   ├── values.yaml
│   ├── templates/
│   └── README.md
├── loki/                      # Grafana Loki log aggregation
│   ├── Chart.yaml
│   ├── values.yaml
│   ├── templates/
│   └── README.md
├── webdav/                    # WebDAV file sharing server
│   ├── Chart.yaml
│   ├── values.yaml
│   ├── templates/
│   └── README.md
├── ittools/                   # IT Tools developer utilities
│   ├── Chart.yaml
│   ├── values.yaml
│   ├── templates/
│   └── README.md
├── homebox/                   # Homebox inventory management
│   ├── Chart.yaml
│   ├── values.yaml
│   ├── templates/
│   └── README.md
├── ollama/                    # Ollama local LLM inference
│   ├── Chart.yaml
│   ├── values.yaml
│   ├── templates/
│   └── README.md
├── scripts/
│   └── test-charts.sh         # Local testing helper script
├── LICENSE                    # ISC License
└── README.md                  # This file
```

## Available Charts

| Chart | Description |
|-------|-------------|
| [**generic**](./generic/) | A flexible chart for deploying applications with monitoring, persistence, and secrets support |
| [**loki**](./loki/) | Grafana Loki log aggregation system |
| [**webdav**](./webdav/) | WebDAV server for HTTP-based file sharing and collaboration |
| [**ittools**](./ittools/) | IT Tools - Collection of handy online tools for developers |
| [**homebox**](./homebox/) | Homebox inventory and organization system for the home |
| [**ollama**](./ollama/) | Ollama local large language model inference engine |

> **Note**: Chart versions are automatically managed by CI/CD pipelines. See the [Helm repository](https://damfle.github.io/helm-charts) for current versions.

## Quick Start

### Add the Helm Repository

```bash
helm repo add damfle https://damfle.github.io/helm-charts
helm repo update
```

### Install a Chart

```bash
# List available charts and versions
helm search repo damfle

# Install with default values
helm install my-release damfle/loki

# Install with custom values file
helm install my-release damfle/loki -f values.yaml

# Install with inline configuration
helm install loki damfle/loki \
  --set generic.persistence.size=20Gi \
  --set generic.ingress.enabled=true \
  --set generic.ingress.hosts[0].host=loki.example.com
```

### Example Deployments

```bash
# Loki for log aggregation
helm install loki damfle/loki \
  --set generic.persistence.size=50Gi

# IT Tools for development utilities
helm install devtools damfle/ittools \
  --set generic.ingress.enabled=true \
  --set generic.ingress.hosts[0].host=tools.company.com

# WebDAV for file sharing
helm install files damfle/webdav \
  --set generic.persistence.size=100Gi \
  --set generic.env[0].value=admin \
  --set generic.env[1].value=secure-password

# Ollama for local AI inference
helm install ollama damfle/ollama \
  --set generic.persistence.size=50Gi \
  --set generic.resources.limits.memory=8Gi
```

## Chart Architecture

### Generic Base Chart

The [`generic`](./generic/) chart serves as the foundation for all application-specific charts:

- **🏗️ Flexible templating** for common Kubernetes resources (Deployment, Service, Ingress, PVC)
- **🔧 Optional features** including ServiceMonitor, persistence, environment variables
- **🔒 Security defaults** with non-root users, read-only filesystems, security contexts
- **📊 Production-ready** health checks, resource limits, and proper labeling
- **🔍 Monitoring support** with Prometheus ServiceMonitor integration

### Application Charts

All application-specific charts use the generic chart as a dependency:

```yaml
# Example dependency structure
dependencies:
  - name: generic
    version: 0.1.18+
    repository: https://damfle.github.io/helm-charts
```

**Benefits:**
- **🔄 Consistent deployment patterns** across all applications
- **📦 Minimal duplication** through inheritance
- **🛠️ Application-specific** configurations and defaults
- **🏷️ Uniform** naming and labeling conventions
- **🔧 Easy maintenance** and updates through base chart

### Chart Types Overview

| Chart | Type | Port | Storage | Use Case |
|-------|------|------|---------|----------|
| **generic** | Base chart | Configurable | Optional | Foundation for other charts |
| **loki** | Log aggregation | 3100 | 8Gi | Centralized logging with Grafana |
| **webdav** | File sharing | 6065 | 128Gi | HTTP-based file server and sharing |
| **ittools** | Developer tools | 80 | None | Web-based utilities for developers |
| **homebox** | Inventory | 7745 | 1Gi | Home inventory management system |
| **ollama** | AI inference | 11434 | 16Gi | Local LLM model serving |

## CI/CD Pipeline

The repository uses GitHub Actions for automated testing, building, and deployment.

### Continuous Integration (ci.yml)

**Triggers:** Pull requests and pushes to main branch

**Pipeline Steps:**
1. **🔍 Change Detection** - Identify which charts have been modified
2. **✅ Linting** - Validate chart syntax and best practices with helm lint
3. **🧪 Testing** - Install charts in Kind cluster for functional verification
4. **📈 Versioning** - Automatically increment chart versions (main branch only)
5. **🏷️ Tagging** - Create repository tags for releases (main branch only)

### Continuous Deployment (cd.yml)

**Triggers:** Tag creation on main branch

**Pipeline Steps:**
1. **📦 Packaging** - Create `.tgz` packages for all charts
2. **🚀 Release** - Create GitHub release with chart packages as assets
3. **🌐 Publishing** - Deploy Helm repository index to GitHub Pages

### Workflow Behavior

| Event | Lint | Test | Version | Tag | Package | Deploy |
|-------|------|------|---------|-----|---------|--------|
| **Pull Request** | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Push to main** | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| **Tag creation** | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ |

### Automated Versioning

- **📊 Semantic Versioning** - Repository uses `vX.Y.Z` format
- **🔄 Chart Versions** - Automatically incremented when charts are modified
- **📝 Commit Integration** - Version changes committed before repository tagging
- **🚫 No Manual Intervention** - Developers focus on chart development

## Development Guide

### Contributing Changes

1. **🍴 Fork** the repository
2. **🌟 Create** a feature branch from `main`
3. **✏️ Modify** charts as needed
4. **🧪 Test** locally using helm commands
5. **📤 Create** a pull request
6. **🤖 Automated Testing** - CI validates changes
7. **✅ Review & Merge** - Maintainer approval
8. **🚀 Automatic Release** - CI handles versioning and deployment

### Local Development

```bash
# Lint a specific chart
helm lint ./loki

# Test template rendering
helm template test-release ./loki

# Test with custom values
helm template test-release ./loki -f ./loki/examples/production.yaml

# Dry-run installation
helm install test-release ./loki --dry-run --debug

# Use the provided test script
./scripts/test-charts.sh lint    # Lint all charts
./scripts/test-charts.sh test    # Test all templates
./scripts/test-charts.sh all     # Run complete test suite
```

### Development Guidelines

- ✅ **DO** test charts locally before creating PRs
- ✅ **DO** include comprehensive documentation
- ✅ **DO** follow Kubernetes security best practices
- ✅ **DO** provide sensible default values
- ❌ **DO NOT** manually update chart versions in `Chart.yaml`
- ❌ **DO NOT** commit without testing
- ❌ **DO NOT** skip documentation updates

### Adding New Charts

1. **📁 Create** new directory: `my-app/`
2. **🏗️ Initialize** with generic dependency:
   ```yaml
   # Chart.yaml
   dependencies:
     - name: generic
       version: 0.1.18
       repository: https://damfle.github.io/helm-charts
   ```
3. **⚙️ Configure** `values.yaml` with app-specific settings
4. **📚 Document** with comprehensive README
5. **🧪 Test** locally and create PR

## Testing Strategy

### Automated Testing

The repository uses [chart-testing](https://github.com/helm/chart-testing) for comprehensive validation:

- **📝 YAML Linting** - Syntax and formatting validation
- **📊 Chart Structure** - Helm chart best practices verification
- **🔧 Template Rendering** - Kubernetes manifest validation
- **🚀 Installation Testing** - Actual deployment in Kind cluster
- **📈 Version Validation** - Proper version increment verification

### Test Configuration

```yaml
# .github/ct.yaml
target-branch: main
chart-dirs: ["."]
helm-extra-args: --timeout 600s
check-version-increment: true
validate-maintainers: false
```

### Quality Assurance

- **🔍 Pre-commit validation** on all chart changes
- **🌐 Multi-environment testing** (Kind cluster simulation)
- **📊 Resource validation** and security scanning
- **🔄 Dependency verification** and compatibility checks

## Usage Examples

### Basic Application Deployment

```yaml
# Production Loki deployment
generic:
  persistence:
    enabled: true
    size: 100Gi
    storageClassName: "fast-ssd"
  
  resources:
    requests:
      memory: "512Mi"
      cpu: "200m"
    limits:
      memory: "2Gi"
      cpu: "1000m"
  
  ingress:
    enabled: true
    className: "nginx"
    hosts:
      - host: loki.company.com
        paths:
          - path: /
            pathType: Prefix
```

### Multi-Application Setup

```bash
# Deploy complete monitoring stack
helm install loki damfle/loki \
  --set generic.persistence.size=50Gi

# Deploy development tools
helm install devtools damfle/ittools \
  --set generic.ingress.enabled=true

# Deploy file sharing
helm install files damfle/webdav \
  --set generic.persistence.size=200Gi
```

### Resource Optimization

```yaml
# Development environment (minimal resources)
generic:
  resources:
    requests:
      memory: "64Mi"
      cpu: "50m"
    limits:
      memory: "128Mi"
      cpu: "100m"

# Production environment (optimized resources)
generic:
  resources:
    requests:
      memory: "512Mi"
      cpu: "200m"
    limits:
      memory: "2Gi"
      cpu: "1000m"
  
  replicaCount: 3
  
  affinity:
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: app.kubernetes.io/name
              operator: In
              values:
              - myapp
          topologyKey: kubernetes.io/hostname
```

## Best Practices

### Chart Development

1. **📋 Documentation** - Include comprehensive README with examples
2. **🔧 Values** - Provide sensible defaults with clear descriptions
3. **🏷️ Labels** - Use consistent labeling with helper templates
4. **🔒 Security** - Implement proper security contexts and limits
5. **🧪 Testing** - Include example configurations that work

### Production Deployment

1. **📊 Resource Planning** - Set appropriate requests and limits
2. **💾 Storage** - Use appropriate storage classes and sizes
3. **🌐 Networking** - Configure ingress with TLS termination
4. **🔍 Monitoring** - Enable ServiceMonitor for Prometheus
5. **🔄 Backup** - Implement backup strategies for persistent data

### Security Considerations

1. **👤 Non-root Users** - Run containers as non-root
2. **📁 Read-only Filesystems** - Mount root filesystem as read-only
3. **🔒 Security Contexts** - Implement proper security contexts
4. **🌐 Network Policies** - Restrict network access in production
5. **🔐 Secrets Management** - Use Kubernetes secrets for sensitive data

## Troubleshooting

### Common Issues

#### Chart Installation Failures
```bash
# Validate chart syntax
helm lint ./chart-name

# Test template rendering
helm template test-release ./chart-name --debug

# Check for resource conflicts
kubectl get all -l app.kubernetes.io/name=chart-name
```

#### Repository Access Issues
```bash
# Update repository cache
helm repo update damfle

# Verify repository configuration
helm repo list | grep damfle

# Check available charts
helm search repo damfle --versions
```

#### CI/CD Pipeline Issues
- **Lint failures** → Check YAML syntax and chart structure
- **Test failures** → Verify charts install successfully
- **Version conflicts** → Ensure proper chart version increments

### Getting Help

- **📚 Chart Documentation** - Check individual chart README files
- **🐛 Bug Reports** - Create GitHub issues with detailed information
- **💬 Questions** - Use GitHub Discussions for general questions
- **🔧 Development** - Consult the development guide above

## Repository Information

### URLs
- **🌐 Helm Repository**: https://damfle.github.io/helm-charts
- **📦 Source Code**: https://github.com/damfle/helm-charts
- **🚀 Releases**: https://github.com/damfle/helm-charts/releases
- **📊 GitHub Pages**: https://damfle.github.io/helm-charts

### Release Management

**Automatic Process:**
1. Developer creates PR with chart changes
2. CI runs comprehensive testing
3. PR merged to main after review
4. CI increments versions and creates tag
5. CD packages charts and publishes release
6. Helm repository updated on GitHub Pages

**Manual Releases:**
```bash
# Maintainers can trigger releases manually
git tag v1.0.0
git push origin v1.0.0
```

### Versioning Strategy

- **Repository Tags** - Semantic versioning: `v1.2.3`
- **Chart Versions** - Automatically incremented on changes
- **Compatibility** - Generic chart maintains backward compatibility
- **Dependencies** - Application charts specify minimum generic version

## License

This project is licensed under the **ISC License**. See the [LICENSE](LICENSE) file for details.

The ISC License is a permissive free software license that is functionally equivalent to the MIT License but with simplified language.

## Maintainers

- **Damien** ([@damfle](https://github.com/damfle)) - Primary maintainer

### Contributing

We welcome contributions! Please:

1. **📖 Read** the development guide above
2. **🧪 Test** your changes locally
3. **📝 Document** new features or changes
4. **📤 Submit** pull requests for review
5. **🤝 Collaborate** with the maintainer team

---

*This repository provides production-ready Helm charts with automated CI/CD for reliable Kubernetes deployments.*
