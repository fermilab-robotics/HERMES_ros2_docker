###########################################
#--------------base--Base-----------------#
###########################################

# Based on some other ROS2 dockerfiles:
# 1. Technical University of Munich: teleoperated_driving
# -> Notable for excellent organization of multi-stage builds, for example:
    # Inspired controller, laptop, and robot stages.
    # Link:  https://github.com/TUMFTM/teleoperated_driving/blob/ros2/docker/dockerfile
# 2. Althack's ROS2 Dockerfiles
    # Inspired the rm -rf /var/lib/apt/lists/* cleanup after apt-get install.
    # Link: https://github.com/althack/dockerfiles/blob/main/ros2/lyrical.Dockerfile

# The version of ROS2 to use.
ARG ROS_DISTRO=jazzy


FROM ros:${ROS_DISTRO}-ros-base AS base

# Set environment variables AFTER FROM commoand

ENV ROS_DISTRO=${ROS_DISTRO}

# Create a non-root dev user. Note that the username is different from host!
ARG USERNAME=ros
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Delete user if it exists in container (e.g Ubuntu Noble: ubuntu)
RUN if id -u $USER_UID ; then userdel `id -un $USER_UID` ; fi

# Create a new user (ros) and add to a linux user group.
RUN groupadd --gid $USER_GID $USERNAME \
    # -s specifies the default login shell for the user
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    # Create a home directory and config directory for the user (some programs want that)
    && mkdir /home/$USERNAME/.config \
    # Change ownership of the directory to the new user and group
    && chown $USER_UID:$USER_GID /home/$USERNAME/.config

# Add sudo support.
RUN apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && rm -rf /var/lib/apt/lists/*

# Install basic apt packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    nano \
    python3-vcstool \
    && rm -rf /var/lib/apt/lists/*

# Install ROS packages
RUN apt-get update && apt-get install -y \
    ros-${ROS_DISTRO}-rmw-cyclonedds-cpp \
    && rm -rf /var/lib/apt/lists/*

# Initialize rosdep (for installing dependencies) if not already there
RUN rosdep init || true \
    && rosdep update

# Configurations (some packages might want this)
COPY config/ /site_config/

# DDS config
COPY cyclonedds.xml /cyclonedds.xml
ENV CYCLONEDDS_URI="file:///cyclonedds.xml"

# Set environment variables
# Tell ROS 2 to use Cyclone as the default middleware
ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp

# Source the ROS2 environment 
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /home/${USERNAME}/.bashrc

# Setup ROS2 workspace
WORKDIR /home/${USERNAME}/ws

# Pre-create workspace dirs and give ownership to the non-root user.
# This is critical: if these dirs are root-owned at runtime, colcon build
# fails unless you sudo chown manually.
RUN mkdir -p build install log \
    && chown -R ${USER_UID}:${USER_GID} /home/${USERNAME}/ws

COPY entrypoint.sh /entrypoint.sh
RUN ["chmod", "+x", "/entrypoint.sh"]
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]


###########################################
#--------------operator_base-----------------#
###########################################

FROM base AS operator_base

# Install the Telemetry and joystick diagnostic tools
# Program for testing joystick devices
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
    evtest \
    jstest-gtk \
    python3-serial \
    ros-${ROS_DISTRO}-image-transport-plugins \
    ros-${ROS_DISTRO}-image-view \
    ros-${ROS_DISTRO}-teleop-twist-keyboard \
    && rm -rf /var/lib/apt/lists/*

# ROOT user: Temperarily bind code to let rosdep scan and install dependencies
RUN --mount=type=bind,source=source,target=/home/ros/ws/src \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    apt-get update \
    && rosdep install -y --ignore-src --from-paths src \
    && rm -rf /var/lib/apt/lists/*


# ================== LAPTOP_DEV (for simulations) ======#
FROM operator_base AS laptop_dev

# Install simulation tools
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
    ros-${ROS_DISTRO}-xacro \
    ros-${ROS_DISTRO}-joint-state-publisher-gui \
    ros-${ROS_DISTRO}-ros-gz \
    ros-${ROS_DISTRO}-rviz2 \
    ros-${ROS_DISTRO}-rqt* \
    git \
    gdb \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Drop privileges:
USER $USERNAME

CMD ["/bin/bash"]
# ================== CONTROLLER_DEV ==================== #

FROM operator_base AS controller_dev

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
    git \
    gdb \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Drop privileges:
USER $USERNAME

CMD ["/bin/bash"]

# ================= CONTROLLER_PROD ==================== #
FROM operator_base AS controller_prod
# Drop privileges
USER $USERNAME

# TODO: Replace with CMD ["ros2", "launch", "controller_bringup", "controller_launch.py"]
CMD ["ros2", "topic", "echo", "/camera/camera/color/image_raw"]

# ================= ROBOT BASE ====================== #
FROM base AS robot_base

# Copy the hardware manifest into the container
WORKDIR /home/ros/ws

# Fetch third-party hardware driver source (e.g. realsense-ros) via vcstool.
# NOTE: this must land in a plain directory, NOT the --mount=type=bind path
# used below for the user's own source. A build-time bind mount only exists
# for the single RUN instruction it's attached to -- anything vcs writes into
# it (like a fresh clone) disappears once that RUN ends. Cloning here instead
# is a normal COPY/RUN layer, so it's permanently baked into the image.
COPY hardware.repos /tmp/hardware.repos
RUN mkdir -p src/vendor && vcs import src/vendor < /tmp/hardware.repos

# Install hardware interface libraries
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    liblgpio-dev \
    # Note, we need to use the pip gpiozero
    swig \
    python3-dev \
    python3-pip \
    && pip3 install --upgrade lgpio gpiozero --break-system-packages \
    && rm -rf /var/lib/apt/lists/*


# Install ROS2 dependencies:
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
    ros-${ROS_DISTRO}-camera-ros \
    ros-${ROS_DISTRO}-librealsense2* \
    && rm -rf /var/lib/apt/lists/*

# Resolve realsense-ros's own dependencies and build it into the image now.
# src/vendor is a real layer (not bind-mounted), so this persists -- robot_dev
# won't need to rebuild it just because the user's own ./source is mounted
# on top of src/ later.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
    python3-colcon-common-extensions \
    && rosdep install -y --ignore-src --from-paths src/vendor \
    && rm -rf /var/lib/apt/lists/*

RUN . /opt/ros/${ROS_DISTRO}/setup.bash \
    && colcon build --symlink-install


# Temperarily bind code to let rosdep scan and install dependencies
# Note: the docker mount overwrites the src folder
RUN --mount=type=bind,source=source,target=/home/ros/ws/src \
    # Cache
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    apt-get update \
    && rosdep install -y --ignore-src --from-paths /home/ros/ws/src \
    # Do NOT install these two packages, as they are not compatible with the Pi5 and will break the build.
    # Do not install librealsense2 (cloning realsense from source)
    --skip-keys="python3-lgpio python3-gpiozero librealsense2 realsense2_camera" \
    && rm -rf /var/lib/apt/lists/*


# ================= ROBOT DEV ====================== #
FROM robot_base AS robot_dev

# Note: We must have permissions to be able to do this, so we need to run as root for this step. We can drop privileges later.

# Install dev-specific debugging tools
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
    git \
    gdb \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Root work is done, drop privilegs
USER $USERNAME

# Enter bash shell by default
CMD ["/bin/bash"]
