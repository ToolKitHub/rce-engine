{
  description =
    "Docker-based engine for executing untrusted code in isolated containers.";
  inputs = {
    nixpkgs.url =
      "github:NixOS/nixpkgs?rev=a47b881e04af1dd6d414618846407b2d6c759380";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        manifest = pkgs.lib.importTOML ./Cargo.toml;
        package = manifest.package;

        rustApp = pkgs.rustPlatform.buildRustPackage {
          pname = package.name;
          version = package.version;
          src = pkgs.lib.cleanSource ./.;
          cargoLock.lockFile = ./Cargo.lock;
          meta = with pkgs.lib; {
            inherit (package) description homepage repository;
            license = licenses.mit;
            maintainers = [ maintainers.xosnrdev ];
          };
        };

        # Image author
        author = "toolkithub";

        # Conditionally build Docker image only on Linux
        # (dockerTools can break on macOS, or cause flake check issues).
        dockerImage = if pkgs.stdenv.isLinux then
          pkgs.dockerTools.buildImage {
            name = "${author}/${rustApp.pname}";
            tag = rustApp.version;
            created = "now";

            config = {
              Env = [
                "LANG=C.UTF-8"
                "SERVER_LISTEN_ADDR=0.0.0.0"
                "SERVER_LISTEN_PORT=8080"
                "SERVER_WORKER_THREADS=10"
                "API_ACCESS_TOKEN=baYUiOe8sjdWkRahkvsFBQ=="
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
              ];
              Cmd = [ "${rustApp}/bin/${rustApp.pname}" ];
              Labels = {
                "org.opencontainers.image.title" = rustApp.pname;
                "org.opencontainers.image.version" = rustApp.version;
                "org.opencontainers.image.description" =
                  rustApp.meta.description;
                "org.opencontainers.image.documentation" =
                  rustApp.meta.homepage;
                "org.opencontainers.image.authors" = author;
                "org.opencontainers.image.source" = rustApp.meta.repository;
                "org.opencontainers.image.licenses" = "MIT";
              };
            };
          }
        else
        # If not Linux, set this to null so we can skip it.
          null;

        devShell = pkgs.mkShell {
          buildInputs = [
            pkgs.docker
            pkgs.cargo-watch
            pkgs.cargo-release
            pkgs.cargo-sort
            pkgs.cargo-edit
            pkgs.cargo-audit
            pkgs.git
          ];

          shellHook = ''
            export RUST_BACKTRACE=1
            export RUST_LOG=debug

            export SERVER_LISTEN_ADDR="127.0.0.1"
            export SERVER_LISTEN_PORT="50051"
            export SERVER_WORKER_THREADS="10"

            export API_ACCESS_TOKEN=$(openssl rand -base64 32)

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
          '';
        };

      in {
        packages = if dockerImage == null then {
          default = rustApp;
        } else {
          default = rustApp;
          docker = dockerImage;
        };

        formatter = pkgs.nixfmt-classic;

        devShells.default = devShell;
      });
}
