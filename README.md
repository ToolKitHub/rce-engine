# rce-engine

[![Main Test](https://github.com/ToolKitHub/rce-engine/actions/workflows/test.yml/badge.svg)](https://github.com/ToolKitHub/rce-engine/actions/workflows/test.yml)

Docker-based engine for executing untrusted code in isolated containers.

## Core Features

- HTTP API for code execution in disposable containers
- JSON-based stdin/stdout communication
- Per-container resource isolation and limits
- Optional gVisor runtime support

## API Endpoints

| Method | Route    | Auth Required | Purpose      |
| ------ | -------- | ------------- | ------------ |
| GET    | /        | No            | Service info |
| GET    | /version | Yes           | Docker info  |
| POST   | /run     | Yes           | Execute code |

## Performance Benchmarks (Hello World)

Standard Runtime:

```
Python:   250-350ms
C:        330-430ms
Haskell:  500-700ms
Java:     2000-2200ms
```

With gVisor:

```
Python:   450-570ms
C:        1300-1500ms
Haskell:  1760-2060ms
Java:     4570-4800ms
```

## Security Controls

- Process limits (fork bomb protection)
- Execution timeouts
- Output size caps
- Memory limits
- Network isolation (optional)
- Capability dropping
- gVisor runtime (optional)

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/toolkithub/rce-engine/main/scripts/install.sh -o install.sh
sudo bash ./install.sh
```

## Configuration

Required Environment Variables:

```
SERVER_*              - HTTP server settings
API_ACCESS_TOKEN      - Authentication
DOCKER_*             - Container config
RUN_MAX_*            - Execution limits
```

Optional:

```
DOCKER_CONTAINER_READONLY_ROOTFS   - Read-only root
DOCKER_CONTAINER_TMP_DIR_*        - Temp directory settings
DOCKER_CONTAINER_WORK_DIR_*       - Work directory config
DEBUG_KEEP_CONTAINER             - Debug mode
```

## Security Notes

- Store sensitive data on separate machines
- Docker containers have lower isolation than VMs
- Use provided security controls based on threat model
- Consider network isolation and capability dropping

## FAQ

Q: How are fork bombs handled?  
A: `DOCKER_CONTAINER_ULIMIT_NPROC_HARD` limits process creation

Q: How are infinite loops handled?  
A: `RUN_MAX_EXECUTION_TIME` enforces execution timeout

Q: How is large output handled?  
A: `RUN_MAX_OUTPUT_SIZE` caps output size

Q: How is high memory usage handled?  
A: `DOCKER_CONTAINER_MEMORY` sets memory limits

## Installation Options

- Systemd service (recommended)
- Docker container
- With gVisor runtime

Docs: See `/docs/install/` for detailed setup guides
