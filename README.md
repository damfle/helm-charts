# Helm Charts Repository

This is the Helm charts repository for damfle.

## Usage

Add this repository to your Helm client:

\`\`\`bash
helm repo add damfle https://damfle.github.io/helm-charts
helm repo update
\`\`\`

## Available Charts

\`\`\`bash
helm search repo damfle
\`\`\`

## Install a Chart

\`\`\`bash
# Install the generic chart
helm install my-release damfle/generic

# Install with custom values
helm install my-release damfle/generic --values my-values.yaml
\`\`\`

## Repository Information

- **Repository URL**: https://damfle.github.io/helm-charts
- **Index File**: https://damfle.github.io/helm-charts/index.yaml
- **Source Code**: https://github.com/damfle/helm-charts

## Charts

📦 Current repository contents:

- **generic** v1.0.4
- **generic** v1.0.5
- **generic** v1.0.6
- **homebox** v0.1.5
- **homebox** v0.1.6
- **homebox** v0.1.7
- **ittools** v0.1.4
- **ittools** v0.1.5
- **jupyter** v0.1.1
- **jupyter** v0.1.2
- **llamacpp** v0.1.1
- **llamacpp** v0.1.2
- **llamacpp** v0.1.3
- **loki** v0.1.26
- **loki** v0.1.27
- **loki** v0.1.28
- **ollama** v0.1.10
- **ollama** v0.1.11
- **ollama** v0.1.9
- **pterodactyl** v0.1.1
- **pterodactyl** v0.1.2
- **pterodactyl** v0.1.3
- **pterodactyl** v0.1.4
- **rustfs** v0.1.6
- **rustfs** v0.1.7
- **shlink** v0.1.7
- **shlink** v0.1.8
- **shlink-ui** v0.1.12
- **shlink-ui** v0.1.13
- **shlink-ui** v0.1.14

Generated on: 2026-04-21 11:44:00 UTC
Repository tag: r42
Total chart packages: 30
