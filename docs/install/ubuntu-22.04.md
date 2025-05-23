# Installation instructions for ubuntu 22.04

## Install and configure docker

```bash
apt install docker.io

# Disable docker networking (optional)
echo '{
    "ip-forward": false,
    "iptables": false,
    "ipv6": false,
    "ip-masq": false
}' > /etc/docker/daemon.json

systemctl restart docker.service
```

## Create user for rce-engine

```bash
useradd -m rce
usermod -aG docker rce
```

## Install rce-engine binary

Since rce-engine will run as a service under the `rce` user, install it directly to that user's directory:

```bash
# Create directory for the binary
sudo mkdir -p /home/rce/bin

# Install directly to the service user's directory
sudo -u rce RCE_ENGINE_INSTALL_DIR=/home/rce/bin curl --proto '=https' --tlsv1.2 -LsSf https://github.com/ToolKitHub/rce-engine/releases/download/v1.2.6/rce-engine-installer.sh | sh

# Ensure correct permissions
sudo chmod +rx /home/rce/bin/rce-engine
```

### Add and configure systemd service

Most of the configuration from the example file is ok but the `API_ACCESS_TOKEN` should be changed

```bash
curl https://raw.githubusercontent.com/toolkithub/rce-engine/main/systemd/rce-engine.service > /etc/systemd/system/rce-engine.service

# Edit rce-engine.service in your favorite editor

systemctl enable rce-engine.service
systemctl start rce-engine.service
```

#### Pull rce-images

```bash
docker pull toolkithub/python:edge
docker pull toolkithub/rust:edge
# ...
```

#### Check that everything is working

```bash
# Print rce-engine version
curl http://localhost:8080

# Print docker version, etc
curl --header 'X-Access-Token: access-token-from-systemd-service' http://localhost:8080/version

# Run python code
curl --request POST --header 'X-Access-Token: access-token-from-systemd-service' --header 'Content-type: application/json' --data '{"image": "toolkithub/python:edge", "payload": {"language": "python", "files": [{"name": "main.py", "content": "print(42)"}]}}' http://localhost:8080/run
```
