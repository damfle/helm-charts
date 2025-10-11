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

- **generic** v1.0.2
- **generic** v1.0.3
- **generic** v1.0.4
- **homebox** v0.1.5
- **ittools** v0.1.4
- **loki** v0.1.26
- **ollama** v0.1.4
- **shlink** v0.1.7
- **shlink-ui** v0.1.9
- **webdav** v0.1.3

Generated on: 2025-10-11 09:13:29 UTC
Repository tag: r4
Total chart packages: 10
