to start on pi:
docker compose -f compose.arm64.yml up -d

-f : file
-d : Detached mode

Give pi permission

sudo usermod -aG docker $USER
newgrp docker

