#!/bin/bash

# Enable error signals
set -e

source /opt/ros/lyrical/setup.bash

# Change ownership of the workspace to the ros user, if it exists
sudo chown -R ros:ros /home/ros/ws 2>/dev/null || true
echo "Provided arguments: $@"

exec "$@"