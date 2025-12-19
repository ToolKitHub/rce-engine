# rce-engine

A secure service for running untrusted code inside isolated Docker containers via a simple HTTP API. 

See [supported programming languages](https://github.com/ToolKitHub/rce-runner).

## Features

- **Security First**: Run untrusted code safely in isolated containers
- **Language Support**: Execute code in multiple programming languages
- **Simple API**: Easy integration with a straightforward REST API
- **Fast Execution**: Optimized container startup (250-2200ms)
- **Resource Control**: Configure memory, CPU, and execution time limits

## Quick Start

**System Requirements**:

- Ubuntu 22.04+
- Docker installed

### Installation

For installation instructions, see:

- [Standard Installation Guide](docs/install/ubuntu-22.04.md)
- [Enhanced Security Installation with gVisor](docs/install/ubuntu-22.04-gvisor.md)

### Basic Usage

Run a Python program:

```bash
curl --request POST \
     --header 'X-Access-Token: your-token-here' \
     --header 'Content-Type: application/json' \
     --data '{
       "image": "toolkithub/python:latest",
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

## Documentation

- [Full documentation](DOCUMENTATION.md)
- [API Reference](docs/api/run.md)
- [Installation guides](docs/install/)

## License

This project is licensed under the [MIT License](./LICENSE)
