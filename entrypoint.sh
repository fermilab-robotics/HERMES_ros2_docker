#!/bin/bash

# Enable error signals
set -e

# Source ROS 2 environment
source /opt/ros/$ROS_DISTRO/setup.bash

# Source the underlay workspace (External repos)

# IF the string UNDERLAY_WS is NOT empty (e.g. we are in the robot_dev stage AND if the local_setup.bash file exists, then source it )
if [ -n "${UNDERLAY_WS}" ] && [ -f "${UNDERLAY_WS}/install/local_setup.bash" ]; then
  source "${UNDERLAY_WS}/install/local_setup.bash"
fi

# Source the base workspace environment, if built
if [ -f /home/ros/ws/install/setup.bash ]; then
  source /home/ros/ws/install/setup.bash
fi

# Change ownership of the workspace to the ros user, if it exists
sudo chown -R ros:ros /home/ros/ws 2>/dev/null || true
echo "Provided arguments: $@"

# Excecute the command passed to this entrypoint
exec "$@" 