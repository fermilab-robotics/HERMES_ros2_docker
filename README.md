## Laptop Setup
Install Docker Engine:



If Linux:
Enable GUI programs outsied container:
xhost +

Use Dev Container extension in VSCODE:
-> Select: existing dockerfile exists

OR:
use: 
docker compose up -d 
docker


## Up-and-Running
The steps to get the project up-and-running are:

### Laptop:
1. [Setup the controller device](/docs/installation_master.md)
### Pi
1. [Setup the Pi](/docs/installation_slave.md)
2. [Build the project on the Pi](/docs/build_pi.md)




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
Run `docker builder prune -a -f` on the pi to clear the disk  from time-to-time



## Adding a new feature




## Immediate upgrades:

- Do not install all the `realsense_ros` packages, only the ones needed for image transport (dockerfile for arm64 takes eons to build right now)
- realsense_ros should get 720p and 30fps across
- Unify dockerfile into one file, having two compose's but only one dockerfile (look at althacks structure)
    - Figure out how to only install what's needed in each dockerfile
- Add camera to launch script
- Fix permission issues when running `colcon build`
- Add these issues to github issues so I can triage them
- Cleanup documentation with AI tool