# Fermilab Robotics: Hermes ROS2 framework

This is the repository of the Fermilab-Robotics Teleoperated stack. This stack is ROS2-based and tested on Ubuntu 26.04 LTS with ROS2 Lyrical.

![Alt](doc/images/visual_abstract.png)

The software stack is grouped in the following packages:

A video showcasing the software on Hermes and RVR will be available soon.

## System Architecture

The system architecture is depicted in the following graphic:

## Getting started

[Getting Started](doc/getting_started.md)
Information about the docker workspace:

## Laptop Setup

Install Docker Engine:

If Linux:
Enable GUI programs outsied container:
xhost +

Remember to change display output to whatever works

Use Dev Container extension in VSCODE:
-> Select: existing dockerfile exists

OR:
use:
docker compose up -d
docker

## Troubleshooting

### Connection issues

Diagnosing the issue:

Check if the laptop can contact the Pi:
`ping -c 3 [pi's ip address]`

View what interface the messages are being sent to:

### Device issues in Docker Container:

xhost +
-> check priviliged status of docker container

(TODO: CycloneDDS config)

### SD Card Space issues:

Run `docker builder prune -a -f` on the pi to clear the disk from time-to-time

## Adding a new feature

## TODO: Add to docs - about CI/CD multiple targets

# Running on laptop (windows)

1. Set DISPLAY variable to host.docker.internal:0.0
2. Unset CYCLONEDDS_URI

# Switching back:

1. Set Display variable back to ${DISPLAY:-:0}


# Time issues

sudo apt update && sudo apt install chrony -y


Go to sudo nano /etc/chrony/chrony.conf and add
allow 10.42.0.0/24 (or whatever the IP subnet is)
local stratum 10

and replace pool line with:
server 10.42.0.1  iburst
Adding an RTC clock