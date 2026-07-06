#!/bin/bash

# Enable error signals
set -e

# Source ROS 2
source /opt/ros/$ROS_DISTRO/setup.bash

# Source the underlay workspace (External repos)
source ${UNDERLAY_WS}/install/local_setup.bash

# Source the base workspace environment, if built
if [ -f /home/ros/ws/install/setup.bash ]; then
  source /home/ros/ws/install/setup.bash
fi

# Change ownership of the workspace to the ros user, if it exists
sudo chown -R ros:ros /home/ros/ws 2>/dev/null || true
echo "Provided arguments: $@"

# Excecute the command passed to this entrypoint
exec "$@"