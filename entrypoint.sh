#!/bin/bash

# Enable error signals
set -e

source /opt/ros/$ROS_DISTRO/setup.bash

# Source the workspace environment
if [ -f /home/ros/ws/install/setup.bash ]; then
  source /home/ros/ws/install/setup.bash
fi

# Change ownership of the workspace to the ros user, if it exists
sudo chown -R ros:ros /home/ros/ws 2>/dev/null || true
echo "Provided arguments: $@"

exec "$@"