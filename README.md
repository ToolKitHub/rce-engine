# rce-engine

[![Version](https://img.shields.io/badge/version-1.2.6-blue.svg)](https://github.com/toolkithub/rce-engine/releases)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
![Ubuntu](https://img.shields.io/badge/ubuntu-22.04+-orange.svg)

## Table of Contents

- [What is rce-engine?](#what-is-rce-engine)
- [Features](#features)
- [Requirements](#requirements)
- [Quick Start](#quick-start)
- [API Reference](#api)
- [Performance](#performance)
- [Security](#security)
- [Configuration](#environment-variables)

## What is rce-engine?

rce-engine is a service that provides a HTTP API for running untrusted code inside isolated Docker containers. Each code execution happens in a fresh container that is destroyed after completion, ensuring security and isolation.

## Features

- [x] Secure code execution in isolated containers
- [x] Support for 41 programming languages
- [x] Fast container startup and execution
- [x] Built-in security with gVisor
- [x] Simple HTTP API interface
- [x] Resource usage controls

## Requirements

- Ubuntu 22.04 or newer
- Sudo privileges
- 2GB RAM minimum
- 20GB free disk space
- Internet connection
- Port 8080 (configurable)

## Quick Start

Install rce-engine

```bash
curl -fsSLO --tlsv1.2 https://raw.githubusercontent.com/toolkithub/rce-engine/main/scripts/installer.sh && bash installer.sh
```

Need more control? Check our [detailed installation guides](#installation-instructions).

## Api

| Action                      | Method | Route    | Requires token |
| :-------------------------- | :----- | :------- | :------------- |
| Get service info            | GET    | /        | No             |
| Get docker info             | GET    | /version | Yes            |
| [Run code](docs/api/run.md) | POST   | /run     | Yes            |

## Docker images

When a run request is posted to rce-engine it will create a new temporary container.
The container is required to listen for a json payload on stdin and must write the
run result to stdout as a json object containing the properties: stdout, stderr and error.
The docker images used [here](https://hub.docker.com/u/toolkithub).

## Performance

The following numbers were obtained using [rce-images](https://github.com/toolkithub/rce-images)
on a 5$ linode vm running 'Hello World' with [httpstat](https://github.com/reorx/httpstat)
multiple times locally on the same host and reading the numbers manually.
Not scientific numbers, but it will give an indication of the overhead involved.

| Language | Min     | Max     |
| :------- | :------ | :------ |
| Python   | 250 ms  | 350 ms  |
| C        | 330 ms  | 430 ms  |
| Haskell  | 500 ms  | 700 ms  |
| Java     | 2000 ms | 2200 ms |

### With [gVisor](https://gvisor.dev/) (optional)

| Language | Min     | Max     |
| :------- | :------ | :------ |
| Python   | 450 ms  | 570 ms  |
| C        | 1300 ms | 1500 ms |
| Haskell  | 1760 ms | 2060 ms |
| Java     | 4570 ms | 4800 ms |

## Security

Docker containers are not as secure as a vm and there has been weaknesses in the past
where people have been able to escape a container in specific scenarios.
The recommended setup is to store any database / user data / secrets on a separate machine then the one that runs docker + rce-engine,
so that if anyone is able to escape the container it will limit what they get access to.

Depending on your use-case you should also consider to:

- Disable network access using `DOCKER_CONTAINER_NETWORK_DISABLED`
- Drop [capabilities](https://man7.org/linux/man-pages/man7/capabilities.7.html) using `DOCKER_CONTAINER_CAP_DROP`
- Use the [gVisor](https://gvisor.dev/) runtime

## Installation instructions

- [Run rce-engine with systemd](docs/install/ubuntu-22.04.md) (recommended)
- [gVisor](docs/install/ubuntu-22.04-gvisor.md)

## FAQ

**Q:** How is fork bombs handled?

**A:** The number of processes a container can create can be set with the `DOCKER_CONTAINER_ULIMIT_NPROC_HARD` variable.

##

**Q:** How is infinite loops handled?

**A:** The container will be killed when the `RUN_MAX_EXECUTION_TIME` value is reached.

---

**Q:** How is large output handled?

**A:** rce-engine will stop reading the output from the container when it has read the number of bytes defined in `RUN_MAX_OUTPUT_SIZE`.

---

**Q:** How is high memory usage handled?

**A:** The max memory for a container can be set with the `DOCKER_CONTAINER_MEMORY` variable.

## Environment variables

### Required

| Variable name                       | Type                         | Description                                                                 |
| :---------------------------------- | :--------------------------- | :-------------------------------------------------------------------------- |
| SERVER_LISTEN_ADDR                  | &lt;ipv4 address&gt;         | Listen ip                                                                   |
| SERVER_LISTEN_PORT                  | 1-65535                      | Listen port                                                                 |
| SERVER_WORKER_THREADS               | &lt;integer&gt;              | How many simultaneous requests that should be processed                     |
| API_ACCESS_TOKEN                    | &lt;string&gt;               | Access token is required in the request to run code                         |
| DOCKER_UNIX_SOCKET_PATH             | &lt;filepath&gt;             | Path to docker unix socket                                                  |
| DOCKER_UNIX_SOCKET_READ_TIMEOUT     | &lt;seconds&gt;              | Read timeout                                                                |
| DOCKER_UNIX_SOCKET_WRITE_TIMEOUT    | &lt;seconds&gt;              | Write timeout                                                               |
| DOCKER_CONTAINER_HOSTNAME           | &lt;string&gt;               | Hostname inside container                                                   |
| DOCKER_CONTAINER_USER               | &lt;string&gt;               | User that will execute the command inside the container                     |
| DOCKER_CONTAINER_MEMORY             | &lt;bytes&gt;                | Max memory the container is allowed to use                                  |
| DOCKER_CONTAINER_NETWORK_DISABLED   | &lt;bool&gt;                 | Enable or disable network access from the container                         |
| DOCKER_CONTAINER_ULIMIT_NOFILE_SOFT | &lt;integer&gt;              | Soft limit for the number of files that can be opened by the container      |
| DOCKER_CONTAINER_ULIMIT_NOFILE_HARD | &lt;integer&gt;              | Hard limit for the number of files that can be opened by the container      |
| DOCKER_CONTAINER_ULIMIT_NPROC_SOFT  | &lt;integer&gt;              | Soft limit for the number of processes that can be started by the container |
| DOCKER_CONTAINER_ULIMIT_NPROC_HARD  | &lt;integer&gt;              | Hard limit for the number of processes that can be started by the container |
| DOCKER_CONTAINER_CAP_DROP           | &lt;space separated list&gt; | List of capabilies to drop                                                  |
| RUN_MAX_EXECUTION_TIME              | &lt;seconds&gt;              | Maximum number of seconds a container is allowed to run                     |
| RUN_MAX_OUTPUT_SIZE                 | &lt;bytes&gt;                | Maximum number of bytes allowed from the output of a run                    |

#### Optional

| Variable name                     | Type             | Description                                                           |
| :-------------------------------- | :--------------- | :-------------------------------------------------------------------- |
| DOCKER_CONTAINER_READONLY_ROOTFS  | &lt;bool&gt;     | Mount root as read-only (recommended)                                 |
| DOCKER_CONTAINER_TMP_DIR_PATH     | &lt;filepath&gt; | Will add a writeable tmpfs mount at the given path                    |
| DOCKER_CONTAINER_TMP_DIR_OPTIONS  | &lt;string&gt;   | Mount options for the tmp dir (default: rw,noexec,nosuid,size=65536k) |
| DOCKER_CONTAINER_WORK_DIR_PATH    | &lt;filepath&gt; | Will add a writeable tmpfs mount at the given path                    |
| DOCKER_CONTAINER_WORK_DIR_OPTIONS | &lt;string&gt;   | Mount options for the work dir (default: rw,exec,nosuid,size=131072k) |
| DEBUG_KEEP_CONTAINER              | &lt;bool&gt;     | Don't remove the container after run is completed (for debugging)     |
