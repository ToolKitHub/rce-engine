let
  nixpkgs =
    builtins.fetchGit {
      url = "https://github.com/NixOS/nixpkgs";
      ref = "refs/heads/release-24.05";
      rev = "abd29679271a9fbcffe1dd640fc6c2a77957f5ed";
    };

  pkgs =
    import nixpkgs { };

  rce-engine =
    import ./default.nix { pkgs = pkgs; };
in
pkgs.dockerTools.buildImage {
  name = "toolkithub/rce-engine";
  tag = "1.2.4";
  created = "now";

  config = {
    Env = [
      "LANG=C.UTF-8"
      "SERVER_LISTEN_ADDR=0.0.0.0"
      "SERVER_LISTEN_PORT=50051"
      "SERVER_WORKER_THREADS=10"
      "API_ACCESS_TOKEN=some-secret-token"
      "DOCKER_UNIX_SOCKET_PATH=/var/run/docker.sock"
      "DOCKER_UNIX_SOCKET_READ_TIMEOUT=3"
      "DOCKER_UNIX_SOCKET_WRITE_TIMEOUT=3"
      "DOCKER_CONTAINER_HOSTNAME=rce"
      "DOCKER_CONTAINER_USER=rce"
      "DOCKER_CONTAINER_MEMORY=1000000000"
      "DOCKER_CONTAINER_NETWORK_DISABLED=true"
      "DOCKER_CONTAINER_ULIMIT_NOFILE_SOFT=90"
      "DOCKER_CONTAINER_ULIMIT_NOFILE_HARD=100"
      "DOCKER_CONTAINER_ULIMIT_NPROC_SOFT=90"
      "DOCKER_CONTAINER_ULIMIT_NPROC_HARD=100"
      "DOCKER_CONTAINER_CAP_DROP=MKNOD NET_RAW NET_BIND_SERVICE"
      "DOCKER_CONTAINER_READONLY_ROOTFS=true"
      "DOCKER_CONTAINER_TMP_DIR_PATH=/tmp"
      "DOCKER_CONTAINER_TMP_DIR_OPTIONS=rw,noexec,nosuid,size=65536k"
      "DOCKER_CONTAINER_WORK_DIR_PATH=/home/rce"
      "DOCKER_CONTAINER_WORK_DIR_OPTIONS=rw,exec,nosuid,size=131072k"
      "RUN_MAX_EXECUTION_TIME=15"
      "RUN_MAX_OUTPUT_SIZE=100000"
      "RUST_LOG=debug"
    ];

    Cmd = [ "${rce-engine}/bin/rce-engine" ];

    Labels = {
      "org.opencontainers.image.authors" = "Success Kingsley <hello@xosnrdev.tech>";
      "org.opencontainers.image.source" = "https://github.com/toolkithub/rce-engine";
      "org.opencontainers.image.version" = "1.2.4";
      "org.opencontainers.image.description" = "Docker-based engine for executing untrusted code in isolated containers.";
    };
  };
}
