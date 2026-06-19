# MlFlow To Prow Helm Chart

A Helm chart for deploying MlFlow To Prow on Kubernetes

## Description

[MlFlow To Prow](https://git.flety.net/vibe/mlflowtoprom) is a simple bridge that emulates mlflow api and exposes it via Prometheus.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+

## Installation

### Add the Helm repository

```bash
helm repo add damfle https://damfle.github.io/helm-charts
helm repo update
```

### Install the chart

```bash
helm install mlflowtoprom damfle/mlflowtoprom 
```

### Install with custom values

```bash
helm install mlflowtoprom damfle/mlflowtoprom -f values.yaml
```

## Configuration

The following table lists the configurable parameters and their default values.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This Helm chart is licensed under the ISC License.

## Links

- [MlFlow To Prow Repository](https://git.flety.net/vibe/mlflowtoprom)
- [Chart Repository](https://github.com/damfle/helm-charts)
