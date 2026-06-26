
Build the environment:
`docker compose -f compose.arm64.yml up -d`

-f : file
-d : Detached mode

- The dockerfile automatically handles the ROS2 installation
- The build step may take a while

Execute commands in the environment using:
`docker compose exec ros2 bash`


### Colcon
Now, build the packages:
`colcon build`

Note: if you get permission issues, run from outside the container:
`sudo chown -R $USER:$USER ~/HERMES_ros2_docker`

Run from inside the container:
`sudo chown -R ros:ros .`

To build particular packages and avoid having to build every package, run:
`colcon build --packages-select [package_name]`

Note: Use --symlink to avoid having to repeatedly rebuild the ROS2 packages

Source the installation files:
`source install/setup.bash`

Now run the launch script:
`ros2 launch my_bringup server_launch.py`

To launch camera:
`ros2 run realsense2_camera realsense2_camera_node`