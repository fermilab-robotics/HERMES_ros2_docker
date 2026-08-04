# Fermilab Robotics: Hermes ROS2 framework

This is the repository of the Fermilab-Robotics Teleoperated stack.

- Uses ROS2 control to drive motors & run odometry
- Lidar  

## Docs
Repo: https://github.com/fermilab-robotics/robotics-documentation
Website: https://fermilab-robotics.github.io/robotics-documentation

![Alt](doc/images/visual_abstract.png)

The software stack is grouped in the following packages:

- `hermes_description`
    - `drive.launch.py`: Used to boot up the drive system

- `motor_driver_py`
    - Obsolete package used to drive motors before ROS2 control.

- `my_bringup` - Contains individual 



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



# Time issues

sudo apt update && sudo apt install chrony -y


Go to sudo nano /etc/chrony/chrony.conf and add
allow 10.42.0.0/24 (or whatever the IP subnet is)
local stratum 10

and replace pool line with:
server 10.42.0.1  iburst
Adding an RTC clock