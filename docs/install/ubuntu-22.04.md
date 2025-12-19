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
sudo -u rce curl --proto '=https' --tlsv1.2 -LsSf https://github.com/ToolKitHub/rce-engine/releases/download/v1.2.71/rce-engine-installer.sh | sh

# Set execute permissions
sudo chmod +rx /home/rce/bin/rce-engine
```

### Add and configure systemd service

Most of the configuration from the example file is ok but you should at least change the `API_ACCESS_TOKEN` to a secure value.

```bash
# Download the service file
curl https://raw.githubusercontent.com/toolkithub/rce-engine/main/systemd/rce-engine.service > /etc/systemd/system/rce-engine.service

# Edit rce-engine.service in your favorite editor to change settings
nano /etc/systemd/system/rce-engine.service

# Enable and start the service
systemctl enable rce-engine.service
systemctl start rce-engine.service
```

#### Advanced: Using systemd overrides (optional)

For a more upgrade-friendly approach, instead of directly editing the service file, you can create an override:

```bash
# Create the override directory
mkdir -p /etc/systemd/system/rce-engine.service.d/

# Create and edit the override file
cat > /etc/systemd/system/rce-engine.service.d/override.conf << EOF
[Service]
Environment="API_ACCESS_TOKEN=your-secure-token-here"
# Add any other settings you want to override
EOF

# Reload systemd configuration
systemctl daemon-reload

# Start the service
systemctl start rce-engine.service
```

#### Pull rce-images

```bash
docker pull toolkithub/python:latest
docker pull toolkithub/rust:latest
# ...
```

#### Check that everything is working

```bash
# Print rce-engine version
curl http://localhost:8080

# Print docker version, etc
curl --header 'X-Access-Token: access-token-from-systemd-service' http://localhost:8080/version

# Run python code
curl --request POST --header 'X-Access-Token: access-token-from-systemd-service' --header 'Content-type: application/json' --data '{"image": "toolkithub/python:latest", "payload": {"language": "python", "files": [{"name": "main.py", "content": "print(42)"}]}}' http://localhost:8080/run
```
