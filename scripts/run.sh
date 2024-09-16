#!/usr/bin/env bash

export SERVER_LISTEN_ADDR="127.0.0.1"
export SERVER_LISTEN_PORT="50051"
export SERVER_WORKER_THREADS="10"

export API_ACCESS_TOKEN="infernal-craftsman-validate-trove"

export DOCKER_UNIX_SOCKET_PATH="/var/run/docker.sock"
export DOCKER_UNIX_SOCKET_READ_TIMEOUT="3"
export DOCKER_UNIX_SOCKET_WRITE_TIMEOUT="3"

export DOCKER_CONTAINER_HOSTNAME="rce"
export DOCKER_CONTAINER_USER="rce"
export DOCKER_CONTAINER_MEMORY="1000000000"
export DOCKER_CONTAINER_NETWORK_DISABLED="true"
export DOCKER_CONTAINER_ULIMIT_NOFILE_SOFT="90"
export DOCKER_CONTAINER_ULIMIT_NOFILE_HARD="100"
export DOCKER_CONTAINER_ULIMIT_NPROC_SOFT="90"
export DOCKER_CONTAINER_ULIMIT_NPROC_HARD="100"
export DOCKER_CONTAINER_CAP_DROP="MKNOD NET_RAW NET_BIND_SERVICE"
export DOCKER_CONTAINER_READONLY_ROOTFS="true"
export DOCKER_CONTAINER_TMP_DIR_PATH="/tmp"
export DOCKER_CONTAINER_TMP_DIR_OPTIONS="rw,noexec,nosuid,size=65536k"
export DOCKER_CONTAINER_WORK_DIR_PATH="/home/rce"
export DOCKER_CONTAINER_WORK_DIR_OPTIONS="rw,exec,nosuid,size=131072k"

export RUN_MAX_EXECUTION_TIME="10"
export RUN_MAX_OUTPUT_SIZE="100000"

export DEBUG_KEEP_CONTAINER="false"

export RUST_LOG=debug

cargo run