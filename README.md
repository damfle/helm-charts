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

- **agentwhisker** v0.0.5
- **forgejo-runner** v0.7.6
- **generic** v1.0.8
- **generic** v1.0.9
- **homebox** v0.1.10
- **homebox** v0.1.9
- **ittools** v0.1.6
- **ittools** v0.1.7
- **jupyter** v0.1.6
- **llamacpp** v0.1.14
- **loki** v0.1.29
- **mcp-luanti** v0.1.2
- **mlflowtoprom** v0.0.4
- **ngircd** v0.1.10
- **ngircd** v0.1.9
- **ollama** v0.1.12
- **pterodactyl** v0.1.13
- **rustfs** v0.1.8
- **sdcpp** v0.1.4
- **shlink** v0.1.10
- **shlink** v0.1.11
- **shlink-ui** v0.1.16
- **unsloth** v0.1.9

Generated on: 2026-07-14 11:49:09 UTC
Repository tag: r115
Total chart packages: 23
