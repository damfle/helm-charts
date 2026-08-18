# mcp-sdcpp

Vibe coded MCP (Model Context Protocol) adapter for the native [stable-diffusion.cpp](https://github.com/leejet/stable-diffusion.cpp) sdcpp API.

This adapter provides a simple bridge between MCP-compatible clients and the sdcpp API, enabling image generation and editing through Stable Diffusion using the native async job-based API.

## Features

- **Image Generation** (txt2img) with prompt and negative prompt
- **Image Editing** (img2img) with init image as reference
- **LoRA Support** for both generation and editing
- **Job Management** (status checking, cancellation)
- **Async Polling** with automatic result retrieval
- **List available LoRAs**

## Installation

```bash
pip install mcp-sdcpp
```

Or from source:

```bash
# Clone the repository
git clone https://github.com/yourusername/mcp-sdcpp.git
cd mcp-sdcpp

# Install in development mode
pip install -e ".[dev]"
```

## Configuration

The adapter connects to the sdcpp server by default at `http://localhost:8080`. Override via environment variable:

```bash
export SDCPP_URL=http://your-server:8080
```

The MCP server listens on port `8080` by default. Configure via:

```bash
export MCP_PORT=8080
```

### Kubernetes Health Checks

The server exposes HTTP endpoints for Kubernetes health checks:

- **Liveness Probe**: `GET /healthz` (port `8081` by default)
  - Always returns `200 OK` if the server is running
  - Response: `{"status": "ok"}`

- **Readiness Probe**: `GET /readyz` (port `8081` by default)
  - Returns `200 OK` only after successful connection to the sdcpp server
  - Returns `503 Service Unavailable` if connection to sdcpp server fails
  - Response: `{"status": "ready"}` or `{"status": "not ready"}`

Configure the health check port via environment variable:

```bash
export HEALTH_CHECK_PORT=8081
```

Kubernetes deployment example:

```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: 8081
  initialDelaySeconds: 5
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /readyz
    port: 8081
  initialDelaySeconds: 5
  periodSeconds: 10
```

## Usage

### Available Tools

| Tool | Description |
|------|-------------|
| `list_loras` | List all available LoRA models |
| `generate_image` | Generate image from prompt and negative prompt (with optional LoRAs) |
| `edit_image` | Edit existing image from prompt and negative prompt (with optional LoRAs) |
| `get_job_status` | Check job status |
| `cancel_job` | Cancel a running job |
| `poll_job_until_complete` | Poll job until completion, return images |

### Generate an Image

```json
{
  "name": "generate_image",
  "arguments": {
    "prompt": "a beautiful sunset over mountains, ultra realistic, 4k",
    "negative_prompt": "blurry, low quality, deformed",
    "width": 1024,
    "height": 1024,
    "batch_count": 1,
    "lora": [{"path": "loras/epi_noiseoffset2.safetensors", "multiplier": 1.0}]
  }
}
```

### Edit an Image

```json
{
  "name": "edit_image",
  "arguments": {
    "prompt": "add a beautiful sunset background",
    "negative_prompt": "blurry, low quality",
    "init_image": "data:image/png;base64,iVBORw0KGgoAAA...",
    "width": 1024,
    "height": 1024,
    "lora": [{"path": "loras/detail.safetensors", "multiplier": 0.8}]
  }
}
```

### List LoRAs

```json
{
  "name": "list_loras"
}
```

### Poll for Results

```json
{
  "name": "poll_job_until_complete",
  "arguments": {
    "job_id": "job_abc123",
    "timeout": 600,
    "poll_interval": 2.0
  }
}
```

Returns generated images as base64-encoded content.

## Development

```bash
# Create virtual environment
python -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -e ".[dev]"

# Run the server
python -m mcp_sdcpp.main

# Run tests
pytest

# Lint
ruff check .

# Format
black .

# Type check
mypy src
```

## API Reference

Implements the native [sdcpp API](https://github.com/leejet/stable-diffusion.cpp/blob/master/examples/server/api.md):

- `GET /sdcpp/v1/capabilities`
- `POST /sdcpp/v1/img_gen`
- `GET /sdcpp/v1/jobs/{id}`
- `POST /sdcpp/v1/jobs/{id}/cancel`

## License

ISC
