# Helm Charts Repository

This repository contains multiple Helm charts for Kubernetes deployments.

## Repository Structure

```
├── .github/
│   ├── workflows/
│   │   └── ci-cd.yml          # Main CI/CD pipeline
│   ├── ct.yaml                # Chart testing configuration
│   └── linters/
│       └── lintconf.yaml      # YAML linting rules
├── generic/                   # Generic application chart
│   ├── Chart.yaml
│   ├── values.yaml
│   ├── templates/
│   └── examples/
└── README.md                  # This file
```

## Available Charts

| Chart | Version | Description |
|-------|---------|-------------|
| [generic](./generic/) | 0.4.0 | A flexible chart for deploying applications with monitoring, persistence, and secrets support |

## CI/CD Pipeline

The repository uses GitHub Actions with two main workflows:

### 1. CI/CD Pipeline (`ci.yml`)
Triggered on pull requests and pushes to main:

1. **Detect Changes**: Identify which charts have been modified
2. **Lint**: Validate chart syntax and best practices
3. **Test**: Install charts in a Kind cluster to verify functionality
4. **Build & Tag**: Increment chart versions, commit changes, and create repository tag

### 2. Continuous Deployment Pipeline (`cd.yml`)
Triggered on tag creation (only for tags on main branch):

1. **Verify Tag**: Ensure tag is created on main branch
2. **Package Charts**: Create `.tgz` packages for all charts
3. **Create Release**: GitHub release with packaged charts as assets
4. **Publish to Pages**: Deploy Helm repository to GitHub Pages

### Workflow Triggers

- **Pull Requests**: Runs lint and test jobs only
- **Push to main**: Runs full CI pipeline including build and tagging
- **Tag creation**: Runs deployment pipeline (only for tags on main branch) with GitHub Pages deployment

### Versioning

- Repository uses semantic versioning (`vX.Y.Z`)
- Patch version automatically increments on each release
- Individual charts have their versions automatically incremented when changed
- Chart version changes are committed before creating the repository tag

## Using the Helm Repository

Add this repository to your Helm client:

```bash
helm repo add damfle https://damfle.github.io/helm-charts
helm repo update
```

Install charts:

```bash
# List available charts
helm search repo damfle

# Install a chart
helm install my-release damfle/generic

# Install with custom values
helm install my-release damfle/generic --values my-values.yaml
```

Repository URL: `https://damfle.github.io/helm-charts`

## Development Workflow

### Adding a New Chart

1. Create a new directory with your chart name
2. Initialize with `helm create <chart-name>` or copy from existing chart
3. Update `Chart.yaml` with appropriate metadata
4. Test locally with `helm lint` and `helm template`
5. Create PR - CI will automatically test the new chart

### Modifying Existing Charts

1. Make your changes to the chart
2. **DO NOT** manually update the chart version in `Chart.yaml` (automated)
3. Test locally
4. Create PR - CI will detect changes and run tests
5. Merge to main - CI will automatically increment chart version, commit changes, and create repository tag

### Local Testing

```bash
# Lint a specific chart
helm lint ./generic

# Test template rendering
helm template test-release ./generic

# Install locally (with values)
helm install test-release ./generic -f ./generic/examples/monitoring-and-persistence.yaml

# Test with chart-testing
ct lint --charts generic/
```

## Chart Testing Configuration

The repository uses [chart-testing](https://github.com/helm/chart-testing) for automated testing:

- **Linting**: YAML syntax, chart structure, best practices
- **Installation**: Charts are installed in a Kind cluster
- **Version checking**: Ensures chart versions are incremented
- **Template validation**: Verifies Kubernetes manifests are valid

## Release Process

### Automatic Process:
1. **Development**: Make changes to charts and create PR
2. **CI**: PR triggers lint and test workflows
3. **Merge**: Merge to main triggers CI pipeline
4. **Tagging**: CI automatically increments chart versions and creates repository tag
5. **Deployment**: Tag creation (on main) triggers CD pipeline
6. **Distribution**: Charts are packaged, released, and published to GitHub Pages

### Manual Process:
Repository maintainers can create tags manually to trigger releases:

```bash
git tag v1.0.0
git push origin v1.0.0
```

Each release includes:
- Repository version tag (e.g., `v1.2.3`)
- Automatic chart version increments
- Commit with updated Chart.yaml files
- GitHub release with packaged chart files
- Updated Helm repository on GitHub Pages

## Chart Guidelines

### Chart Structure
```
chart-name/
├── Chart.yaml              # Chart metadata
├── values.yaml             # Default configuration
├── README.md               # Chart documentation
├── templates/              # Kubernetes manifests
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ...
├── examples/               # Example configurations
│   ├── basic.yaml
│   └── advanced.yaml
└── tests/                  # Chart tests (optional)
    └── test-connection.yaml
```

### Best Practices

1. **Versioning**: Always increment chart version for changes
2. **Documentation**: Include comprehensive README and examples
3. **Values**: Provide sensible defaults and clear documentation
4. **Labels**: Use consistent labeling with helpers
5. **Testing**: Include example configurations that work
6. **Security**: Follow Kubernetes security best practices

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally
5. Create a pull request
6. CI will automatically test your changes

## License

This project is licensed under the ISC License - see the [LICENSE](LICENSE) file for details.

## Repository Maintainers

- Damien (@damfle)
