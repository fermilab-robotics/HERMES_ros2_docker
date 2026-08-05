# MARF
MARF(Modular Accelerator Robotics Framework) is a ROS2-based robotics framework for deploying and operating Fermilab's accelerator robotics fleet.

This code loads on Raspberry Pi's on the controller, laptop, and robot.

The drive system uses the `ros2_control` library.

Though it was originally tested on the HERMES robot, in principle, it is capable of running on RVR as well. [RVR Migration Guide](https://fermilab-robotics.github.io/robotics-documentation/getting-started/setting-up-RVR.html)

Additionally, though it was tested  on Raspberry Pi's, it can also be configured to run on any single-board computer such as the Nvidia Jetson by adding more Docker Stages.


## Quickstart

- Flash a Pico with the motor driver code
- Clone this repository onto the robot
- `cd` into the folder and run `docker compose build <image_name>`
- Run: `docker compose up <image_name> -d` to startup
- For development images:
    - Run `docker compose exec <image_name> bash`
    - Build the source packages: `colcon build`
    - Source the installation: `source install/setup.bash`
    - Launch the launch files: `ros2 launch my_bringup hermes.launch.py`

### Images
<img width="674" height="491" alt="Docker Multi_Stage Build Tree" src="https://github.com/user-attachments/assets/f46553bf-1d44-4287-8064-43a8e47302ba" />

- `robot_prod` for the robot in production
- `controller_prod` for the controller in production
- `robot_dev` for the robot in development
- `controller_dev` for the controller in development
- `laptop_dev` for the laptop to visualize output

#### Production vs. Development
- In production, you cannot edit the source ROS packages after building the Docker File. 
- Production containers auto-start on boot, the only way to shut them off is to run `docker compose down`.
- To view output in production, use `docker compose logs -f <image_name>`


## Description
<img width="998" height="568" alt="System_Architecture" src="https://github.com/user-attachments/assets/1e6c458f-faa4-498c-8a47-38de20742a62" />

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
<img width="864" height="462" alt="ROS2 Node Diagram" src="https://github.com/user-attachments/assets/1da78a1b-84da-45c7-85fd-01d3443cde33" />


#### Drive System

The `skid_steer` plugin of the `ros2_control` library was used to drive the robot, located within `hermes_description/

#### Heartbeat

`my_diagnostics` contains a Heartbeat node, however currently, this is purely for diagnostics purposes.

The main heartbeat however, comes from the Pico Motor Driver, shutting off the motors.
The `cmd_vel` drive commands act as a heartbeat, if they stop coming, it means the connection is lost.

#### Camera
`my_bringup` launches the realsense camera node through the [`realsense_ros`](https://github.com/realsenseai/realsense-ros) library.


#### LiDAR
`my_bringup` launches the LiDAR node using the [`ldrobot-lidar-ros2`](https://github.com/Myzhar/ldrobot-lidar-ros2/tree/main) library.


#### Development Features
Github should send an email to the author who pushed a commit if the Docker builds listed in the `test-docker.yml` matrix workflow failed.

## Demonstration Video

[TODO: Create short (8~10 mins) YouTube video of operation and features]

## Installation

[View Installation Instructions](https://fermilab-robotics.github.io/robotics-documentation/getting-started/index.html)


## Usage
In development images, you can startup each subsystem

### On the Robot
- Running the LiDAR: `ros2 launch my_bringup lidar.launch.py`
- Running the Camera: `ros2 launch my_bringup camera.launch.py`
- Running the Drive Control System: `ros2 launch hermes_description drive.launch.py`

### On the Controller
- Running the joystick: `ros2 launch my_bringup joystick.launch.py`
- Running the camera view: `ros2 run rqt_image_view rqt_image_view`
    - Select various feeds (e.g. Depth Camera, Color Raw, Compressed)

Refer to [quickstart](#quickstart) for production deployment.

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

Thank you—Zachary Wilson, Ryan, Jeremy Arnold, Chris Olson,  Suzanna Stevenson, Jennifer Case, Keith Engell.

Thank you Donovan Tooke for being my mentor and checking in on my project progress.

Thank you to everyone in industrial controls for always being there to help me!

## License

This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <https://unlicense.org/>
