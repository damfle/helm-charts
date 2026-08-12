# MLflow Prometheus Exporter Helm Chart

A Helm chart for deploying MLflow Prometheus Exporter on Kubernetes

## Description

[MLflow Prometheus Exporter](https://git.flety.net/damien/mlflow_prometheus_exporter) is a simple bridge that emulates the MLflow API and exposes metrics via Prometheus.

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
helm install mlflow_prometheus_exporter damfle/mlflow_prometheus_exporter
```

### Install with custom values

```bash
helm install mlflow_prometheus_exporter damfle/mlflow_prometheus_exporter -f values.yaml
```

## Configuration

The following table lists the configurable parameters and their default values.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This Helm chart is licensed under the ISC License.

## Links

- [MLflow Prometheus Exporter Repository](https://git.flety.net/damien/mlflow_prometheus_exporter)
- [Chart Repository](https://github.com/damfle/helm-charts)
