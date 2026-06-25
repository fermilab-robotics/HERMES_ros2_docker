to start on pi:
docker compose -f compose.arm64.yml up -d

-f : file
-d : Detached mode

Give pi permission

sudo usermod -aG docker $USER
newgrp docker


Now, run the command:
docker compose -f compose.arm64.yml up -d

-d: Detached mode

Now, exceute commands using:
docker compose exec ros2 bash