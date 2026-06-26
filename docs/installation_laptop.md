1. Install the docker engine on Windows/Linux/Mac:
https://docs.docker.com/engine/install/

(Note: Docker Desktop is the closed-source tool that requires licensing, but Docker Engine (Docker CE) is open source and free)

On LInux, we may use the convenience script again:


```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```
Give necessary permissions:
```bash
sudo usermod -aG docker $USER
newgrp docker
```
2. Enable GUI tools for docker
`xhost +`
Test the GUI tool:
`rviz2`


Setup the laptop with a access point (hotspot) and connect all devices to it for setup.

run hostname -I on these devices to view Ip for SSH