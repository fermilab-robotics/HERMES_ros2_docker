Detailed instructions for installation of ROS2 environment on controller:
Prerequisites:
- Raspberry Pi OS Lite (64-bit) or other Linux Image (e.g. Ubuntu, Debian)
- Docker
- Docker Compose


## Install Docker

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```
Give necessary permissions:
```bash
sudo usermod -aG docker $USER
newgrp docker
```

## Install Docker Compose
```bash
sudo apt-get update
sudo apt-get install docker-compose-plugin
docker compose version
```

Follow the [repository cloning steps]() to clone the repo onto the controller.

Success! Now go to [build controller](./build_controller.md) to build the project!