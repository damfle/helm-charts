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

- **generic** v0.1.18
- **generic** v0.1.19
- **loki** v0.1.21
- **loki** v0.1.23
- **loki** v0.1.24

Generated on: 2025-10-02 08:31:05 UTC
Repository tag: b5
Total chart packages: 5
