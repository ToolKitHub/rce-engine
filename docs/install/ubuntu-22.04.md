# Installation instructions for ubuntu 22.04

#### Install and configure docker

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

#### Create user for rce-engine

```bash
useradd -m rce
usermod -aG docker rce
```

#### Install rce-engine binary

```bash
mkdir /home/rce/bin
cd /home/rce/bin
wget https://github.com/toolkithub/rce-engine/releases/download/v.1.2.3/rce-engine_linux-x64.tar.gz
tar -zxf rce-engine_linux-x64.tar.gz
rm rce-engine_linux-x64.tar.gz
chown -R rce:rce /home/rce/bin
```

#### Add and configure systemd service

Most of the configuration from the example file is ok but the `API_ACCESS_TOKEN` should be changed

```bash
curl https://raw.githubusercontent.com/toolkithub/rce-engine/main/systemd/rce-engine.service > /etc/systemd/system/rce-engine.service

# Edit rce-engine.service in your favorite editor

systemctl enable rce-engine.service
systemctl start rce-engine.service
```

#### Pull rce-images

```bash
docker pull ghcr.io/toolkithub/rce-images-python:edge
docker pull ghcr.io/toolkithub/rce-images-rust:edge
# ...
```

#### Check that everything is working

```bash
# Print rce-engine version
curl http://localhost:50051

# Print docker version, etc
curl --header 'X-Access-Token: access-token-from-systemd-service' http://localhost:50051/version

# Run python code
curl --request POST --header 'X-Access-Token: access-token-from-systemd-service' --header 'Content-type: application/json' --data '{"image": "ghcr.io/toolkithub/rce-images-python:edge", "payload": {"language": "python", "files": [{"name": "main.py", "content": "print(42)"}]}}' http://localhost:50051/run
```
