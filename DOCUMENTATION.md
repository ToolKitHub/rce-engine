# rce-engine Documentation

This document provides comprehensive information about rce-engine, its architecture, API, configuration options, and best practices.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [API Reference](#api-reference)
- [Docker Images](#docker-images)
- [Performance](#performance)
- [Security Considerations](#security-considerations)
- [Installation](#installation)
- [Configuration](#configuration)
- [FAQ](#faq)
- [Troubleshooting](#troubleshooting)

## Overview

rce-engine is a service that provides a secure HTTP API for running untrusted code inside isolated Docker containers. It's designed for educational platforms, online coding environments, technical interviews, and any application that requires secure code execution.

Each code execution happens in a fresh container that is destroyed after completion, ensuring security and isolation.

## Architecture

rce-engine communicates with the Docker daemon through a Unix socket to:
1. Create a container based on the specified language image
2. Mount necessary volumes and apply security constraints
3. Execute the user's code within the container
4. Capture stdout, stderr, and execution status
5. Destroy the container after execution

The service is built in Rust for high performance and safety.

## API Reference

### Endpoints

| Action           | Method | Route    | Requires token |
|------------------|--------|----------|---------------|
| Get service info | GET    | /        | No            |
| Get docker info  | GET    | /version | Yes           |
| Run code         | POST   | /run     | Yes           |

### Run Code API

**Endpoint**: `POST /run`

**Headers**:
- `X-Access-Token`: Your API token
- `Content-Type`: application/json

**Request Body**:
```json
{
  "image": "toolkithub/<language>:latest",
  "payload": {
    "language": "<language>",
    "files": [
      {
        "name": "main.<ext>",
        "content": "Your code here"
      }
    ]
  }
}
```

**Response**:
```json
{
  "stdout": "Standard output from your code",
  "stderr": "Standard error output (if any)",
  "error": "Error message (if any)"
}
```

For more detailed API examples, see [run.md](docs/api/run.md).

## Docker Images

rce-engine uses Docker images from the `toolkithub` repository. Each image:

- Listens for JSON payload on stdin
- Executes the provided code
- Returns a JSON response on stdout with stdout, stderr, and error properties

Available images can be found at [Docker Hub](https://hub.docker.com/u/toolkithub).

## Performance

Performance metrics running "Hello World" on a 5$ Linode VM:

| Language | Min     | Max     |
|----------|---------|---------|
| Python   | 250 ms  | 350 ms  |
| C        | 330 ms  | 430 ms  |
| Haskell  | 500 ms  | 700 ms  |
| Java     | 2000 ms | 2200 ms |

### With gVisor Runtime

| Language | Min     | Max     |
|----------|---------|---------|
| Python   | 450 ms  | 570 ms  |
| C        | 1300 ms | 1500 ms |
| Haskell  | 1760 ms | 2060 ms |
| Java     | 4570 ms | 4800 ms |

## Security Considerations

Docker containers provide isolation but have known security limitations. For maximum security:

1. **Isolate Your Environment**:
   - Run rce-engine on a dedicated machine
   - Store sensitive data on separate systems

2. **Container Security**:
   - Disable network access using `DOCKER_CONTAINER_NETWORK_DISABLED`
   - Drop capabilities using `DOCKER_CONTAINER_CAP_DROP`
   - Use read-only root filesystem with `DOCKER_CONTAINER_READONLY_ROOTFS`
   - Consider using [gVisor](https://gvisor.dev/) runtime

3. **Resource Protection**:
   - Set appropriate memory limits
   - Configure process count limits to prevent fork bombs
   - Set execution time limits to prevent infinite loops
   - Restrict output size to prevent memory exhaustion

## Installation

rce-engine can be installed on Ubuntu 22.04 or newer servers. For detailed installation instructions, see:

- [Standard Installation Guide](docs/install/ubuntu-22.04.md) (recommended)
- [Enhanced Security Installation with gVisor](docs/install/ubuntu-22.04-gvisor.md)

These guides cover all aspects of installation including:
- Setting up Docker
- Creating the service user
- Installing the binary
- Configuring the systemd service
- Setting up security measures

## Configuration

rce-engine is configured via environment variables in the systemd service file at `/etc/systemd/system/rce-engine.service`. As shown in the installation guide, you can edit this file directly to change configuration settings.

Alternatively, for a more upgrade-friendly approach, you can create an override file at `/etc/systemd/system/rce-engine.service.d/override.conf`.

### Required Environment Variables

| Variable name                       | Type                         | Description                                                   |
|------------------------------------|------------------------------|---------------------------------------------------------------|
| SERVER_LISTEN_ADDR                  | \<ipv4 address>              | Listen IP address                                             |
| SERVER_LISTEN_PORT                  | 1-65535                      | Listen port                                                   |
| SERVER_WORKER_THREADS               | \<integer>                   | Number of simultaneous requests to process                    |
| API_ACCESS_TOKEN                    | \<string>                    | Access token required for API requests                        |
| DOCKER_UNIX_SOCKET_PATH             | \<filepath>                  | Path to Docker unix socket                                    |
| DOCKER_UNIX_SOCKET_READ_TIMEOUT     | \<seconds>                   | Read timeout                                                  |
| DOCKER_UNIX_SOCKET_WRITE_TIMEOUT    | \<seconds>                   | Write timeout                                                 |
| DOCKER_CONTAINER_HOSTNAME           | \<string>                    | Hostname inside container                                     |
| DOCKER_CONTAINER_USER               | \<string>                    | User executing commands inside container                      |
| DOCKER_CONTAINER_MEMORY             | \<bytes>                     | Max memory allowed for container                              |
| DOCKER_CONTAINER_NETWORK_DISABLED   | \<bool>                      | Enable/disable network access                                 |
| DOCKER_CONTAINER_ULIMIT_NOFILE_SOFT | \<integer>                   | Soft limit for open files                                     |
| DOCKER_CONTAINER_ULIMIT_NOFILE_HARD | \<integer>                   | Hard limit for open files                                     |
| DOCKER_CONTAINER_ULIMIT_NPROC_SOFT  | \<integer>                   | Soft limit for processes                                      |
| DOCKER_CONTAINER_ULIMIT_NPROC_HARD  | \<integer>                   | Hard limit for processes                                      |
| DOCKER_CONTAINER_CAP_DROP           | \<space separated list>      | List of capabilities to drop                                  |
| RUN_MAX_EXECUTION_TIME              | \<seconds>                   | Maximum execution time allowed                                |
| RUN_MAX_OUTPUT_SIZE                 | \<bytes>                     | Maximum allowed output size                                   |

### Optional Environment Variables

| Variable name                     | Type             | Description                                                  |
|----------------------------------|------------------|--------------------------------------------------------------|
| DOCKER_CONTAINER_READONLY_ROOTFS  | \<bool>          | Mount root as read-only (recommended)                        |
| DOCKER_CONTAINER_TMP_DIR_PATH     | \<filepath>      | Path for writable tmpfs mount                                |
| DOCKER_CONTAINER_TMP_DIR_OPTIONS  | \<string>        | Mount options for tmp dir                                    |
| DOCKER_CONTAINER_WORK_DIR_PATH    | \<filepath>      | Path for writable work dir mount                             |
| DOCKER_CONTAINER_WORK_DIR_OPTIONS | \<string>        | Mount options for work dir                                   |
| DEBUG_KEEP_CONTAINER              | \<bool>          | Keep containers after execution for debugging                |

## FAQ

**Q: How are fork bombs handled?**  
A: The number of processes a container can create is limited by the `DOCKER_CONTAINER_ULIMIT_NPROC_HARD` variable.

**Q: How are infinite loops handled?**  
A: The container is killed when the `RUN_MAX_EXECUTION_TIME` value is reached.

**Q: How is large output handled?**  
A: rce-engine stops reading output when it reaches the byte count defined in `RUN_MAX_OUTPUT_SIZE`.

**Q: How is high memory usage handled?**  
A: Container memory usage is limited by the `DOCKER_CONTAINER_MEMORY` variable.

**Q: Is network access allowed in containers?**  
A: Network access can be disabled using `DOCKER_CONTAINER_NETWORK_DISABLED=true` (recommended).

**Q: How secure is rce-engine?**  
A: rce-engine provides multiple security layers but should be run on dedicated machines with no sensitive data.

## Troubleshooting

### Common Issues

1. **Docker socket permission denied**
   - Ensure the rce-engine user has access to the Docker socket
   - Add the user to the docker group: `usermod -aG docker rce`

2. **Container startup failures**
   - Check Docker service is running: `systemctl status docker`
   - Verify Docker images are available: `docker images | grep toolkithub`

3. **API timeout errors**
   - Increase `DOCKER_UNIX_SOCKET_READ_TIMEOUT` and `DOCKER_UNIX_SOCKET_WRITE_TIMEOUT`
   - Check system resources (CPU, memory, disk)

For more support, check the logs: `journalctl -u rce-engine.service -f`
