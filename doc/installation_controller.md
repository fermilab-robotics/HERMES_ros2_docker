
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```
Give necessary permissions:
```bash
sudo usermod -aG docker $USER
newgrp docker
```