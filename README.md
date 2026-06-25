## Laptop Setup

Enable GUI programs outsied container:
xhost +

Use Dev Container extension in VSCODE

OR:
use: 
docker compose up -d 
docker



## Raspberry Pi Setup

Build the environment:
`docker compose -f compose.arm64.yml up -d`

-f : file
-d : Detached mode

Give Pi necessary permissions

sudo usermod -aG docker $USER
newgrp docker



Now, run the command:
docker compose -f compose.arm64.yml up -d

-d: Detached mode

Now, exceute commands using:
docker compose exec ros2 bash

### Troubleshooting

Run `docker builder prune -a -f` on the pi to clear the disk  from time-to-time