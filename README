# rce-engine

**rce-engine** is a secure service for running untrusted code inside isolated Docker containers via a simple HTTP API. Execute code in 41 different programming languages with strong security guarantees.

[View full documentation](DOCUMENTATION.md)

## Why Use rce-engine?

- **Security First**: Run untrusted code safely in isolated containers
- **Language Support**: Execute code in 41 programming languages
- **Simple API**: Easy integration with a straightforward REST API
- **Fast Execution**: Optimized container startup (250-2200ms)
- **Resource Control**: Configure memory, CPU, and execution time limits

## Quick Start

**Requirements**:
- Ubuntu 22.04+
- Docker installed

### Installation

**Quick Binary Install** (installs only the binary to ~/.cargo/bin by default):
```bash
curl --proto '=https' --tlsv1.2 -LsSf https://github.com/ToolKitHub/rce-engine/releases/download/v1.2.6/rce-engine-installer.sh | sh
```

**Note:** The installer only provides the executable binary. You'll still need to:
- Configure the systemd service
- Set up proper permissions
- Configure Docker security options

For complete installation with proper service setup:
- [Ubuntu 22.04 with systemd](docs/install/ubuntu-22.04.md) (recommended)
- [Ubuntu 22.04 with gVisor](docs/install/ubuntu-22.04-gvisor.md) (enhanced security)

### Basic Usage

Run a Python program:

```bash
curl --request POST \
     --header 'X-Access-Token: your-token-here' \
     --header 'Content-Type: application/json' \
     --data '{
       "image": "toolkithub/python:edge", 
       "payload": {
         "language": "python", 
         "files": [{"name": "main.py", "content": "print(\"Hello world!\")"}]
       }
     }' \
     --url 'http://localhost:8080/run'
```

Response:
```json
{
  "stdout": "Hello world!\n",
  "stderr": "",
  "error": ""
}
```

## Supported Languages

Python, JavaScript, TypeScript, Ruby, Java, C, C++, Go, Rust, PHP, and 31 others.

## Documentation

- [Full documentation](DOCUMENTATION.md)
- [API Reference](docs/api/run.md)
- [Installation guides](docs/install/)

## Security

rce-engine is designed with security in mind:
- Fresh container for each execution
- Container destroyed after completion
- Resource limits to prevent abuse
- Optional gVisor runtime for enhanced isolation

## License

[See License](./LICENSE)
