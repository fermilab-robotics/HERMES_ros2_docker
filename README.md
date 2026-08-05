# MARF — Modular Accelerator Robotics Framework

MARF is a robotics framework powered by ROS2 and Docker, for deploying onto Fermilab's accelerator robotics fleet.

This code loads on Raspberry Pi's on the controller, laptop, and robot.

Its control system is currently configured to run a robot in differential drive—treads, wheels, etc. 

Though it is called "HERMES" framework, in principle, it is capable of running on RVR as well. [See more](https://fermilab-robotics.github.io/robotics-documentation/getting-started/int-rover.html)

Additionally, though it was configured to run on Raspberry Pi's, it can also be configured to run on any single-board computer such as the Nvidia Jetson.


## Description


### Background
Previously, the code for Fermilab's accelerator robotics fleet was scattered across multiple repositories and branches:

1. [RVR_DEV](https://github.com/fermilab-robotics/RVR_DEV) - Python scripts for RVR robot.

2. [HERMES_DEV](https://github.com/fermilab-robotics/HERMES_DEV) - Python Scripts for HERMES robot.

This project aims to unify the codebase into one repository by utilizing ROS2 and Docker.

### Files & Folders
```
/MARF
├── /.devcontainer             # For VSCode's DevContainers extension
├── /.github/workflows         # Tests Docker builds on github push
├── /config                    # Currently unused
├── /source                    # ROS2 packages
│   ├── /hermes_description    # URDF files, Gazebo Simulation
│   ├── /hermes_hardware       # Hardware Interfaces for Pico
│   ├── /my_bringup            # Launch files for robot components bringup
│   ├── /my_diagnostics        # Heartbeat diagnostic testing
├── cyclonedds.xml             # DDS configuration file for communication
├── docker-compose.yml         # Configures launch of Docker container Stages
├── Dockerfile                 # Installs ROS2 and ROS2 packages
├── entrypoint.sh              # Sources ROS2 installation
├── hardware.repos             # External libraries (e.g. camera, LiDAR)
└── README.md
```

For more information on individual packages, navigate to their folders and view the individual README's

### Features


#### Drive System

The `skid_steer` plugin of the `ros2_control` library

#### Heartbeat

`my_diagnostics` contains a Heartbeat node, however currently, this is purely for diagnostics purposes.

The main heartbeat however, comes from the Pico Motor Driver, shutting off the motors.
The `cmd_vel` drive commands act as a heartbeat, if they stop coming, it means the connection is lost.

### Camera
`my_bringup` launches the realsense camera node through the [`realsense_ros`](https://github.com/realsenseai/realsense-ros) library.


### LiDAR
`my_bringup` launches the LiDAR node using the [`ldrobot-lidar-ros2`](https://github.com/Myzhar/ldrobot-lidar-ros2/tree/main) library.


## Demonstration Video

[TODO: Create short YouTube video of operation and features, or a GIF of operation]

## Installation

[View Installation Instructions](https://fermilab-robotics.github.io/robotics-documentation/getting-started/index.html)


## Usage

### In DEV
- Running the LiDAR
- Running the Camera
- Running the Drive System

### In PROD
- [Production Deployment](https://fermilab-robotics.github.io/robotics-documentation/getting-started/quickstart.html)

## Troubleshooting

[Troubleshooting flowchart](https://fermilab-robotics.github.io/robotics-documentation/troubleshooting/index.html)

## Support & Documentation

- [Documentation Repository](https://github.com/fermilab-robotics/robotics-documentation)
- [Documentation Website](https://fermilab-robotics.github.io/robotics-documentation)
- [Project Poster](https://drive.google.com/file/d/1OugprOLZB8CTi0hlsNoh3qZSDyITT_qX/view?usp=sharing)
- [Project Report](https://drive.google.com/file/d/1oy-FN0BILNm-ECqbWsjc-oOhNJrBVMwY/view?usp=sharing)
- [Mid-Internship New Perspectives 2026 Presentation](https://indico.fnal.gov/event/73553/contributions/344399/)

## Roadmap
[Future work](https://fermilab-robotics.github.io/robotics-documentation/future_work/index.html)



## Authors and acknowledgement

### Contact Details:
*Created by Rayyan Khan*

[Linkedin](https://www.linkedin.com/in/muhammed-rayyan-khan/) |
[Github Profile](https://github.com/Rayyan06) |
Email: rayyanmhkhan@gmail.com | Phone: (838)-245-9705

A huge thanks to my supervisor, Megan Galante for your support throughout this project, checking in frequently and ensuring there were no blockers.

Thank you to Adam Watts for your frequent meetings and mentorship over this summer!

Thank you—Jeremy Arnold, Chris Olson,  Suzanna Stevenson, Jennifer Case, Keith Engell.

Thank you Donovan Tooke for being my mentor and checking in on my project progress.

Thank you to everyone in industrial controls for always being there to help me!