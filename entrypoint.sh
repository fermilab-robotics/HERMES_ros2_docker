#!/bin/bash

# Enable error signals
set -e

source /opt/ros/lyrical/setup.bash

echo "Provided arguments: $@"

exec "$@"