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

# Restart docker daemon
systemctl restart docker.service
```

#### Pull the rce-engine image

```bash
docker pull toolkithub/rce-engine:edge
```

#### Pull rce-images for the languages you want

```bash
docker pull toolkithub/python:edge
docker pull toolkithub/rust:edge
# ...
```

#### Start the rce-engine container

```bash
docker run --detach --restart=always --publish 50051:50051 --volume /var/run/docker.sock:/var/run/docker.sock --env "API_ACCESS_TOKEN=my-token" toolkithub/rce-engine:edge
```

#### Check that everything is working

```bash
# Print rce-engine version
curl http://localhost:50051

# Print docker version, etc
curl --header 'X-Access-Token: my-token' http://localhost:50051/version

# Run python code
curl --request POST --header 'X-Access-Token: my-token' --header 'Content-type: application/json' --data '{"image": "rce-images-python:edge", "payload": {"language": "python", "files": [{"name": "main.py", "content": "print(42)"}]}}' http://localhost:50051/run
```
