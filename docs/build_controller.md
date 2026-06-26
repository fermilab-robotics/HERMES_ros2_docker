docker run -it --network=host --env DISPLAY=$DISPLAY --volume /tmp/.X11-unix:/tmp/.X11-unix:rw ros:lyrical-ros-base bash
apt-get update
apt-get install -y ros-lyrical-image-view ros-lyrical-rmw-cyclonedds-cpp
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
source /opt/ros/lyrical/setup.bash
ros2 run image_view image_view --ros-args -p image:=/camera/camera/color/image_raw
