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

- **generic** v0.1.14
- **loki** v0.1.15

Generated on: 2025-10-01 09:04:40 UTC
Repository tag: v0.0.3
