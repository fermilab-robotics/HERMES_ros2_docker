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
ARG ROS_DISTRO=lyrical

FROM ros:${ROS_DISTRO}-ros-base AS base

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

# Possibly... might need to remove old gpg key and update for ROS2?

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

### --- Setup entrypoint ---------------- ###
RUN chown -R ${USER_UID}:${USER_GID} /home/${USERNAME}/ws
COPY entrypoint.sh /entrypoint.sh
RUN ["chmod", "+x", "/entrypoint.sh"]
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]


###########################################
#--------------operator_base-----------------#
###########################################

FROM base as operator_base

# Install the Telemetry and joystick diagnostic tools
# Program for testing joystick devices
RUN apt-get update && apt-get install -y --no-install-recommends \
    evtest \
    jstest-gtk \
    python3-serial \
    ros-${ROS_DISTRO}-image-view \
    ros-${ROS_DISTRO}-teleop-twist-keyboard \
    && rm -rf /var/lib/apt/lists/*

# ROOT user: Temperarily bind code to let rosdep scan and install dependencies
RUN --mount=type=bind,source=source,target=/home/ros/ws/src \
    apt-get update \
    && rosdep install -y --ignore-src --from-paths src \
    && rm -rf /var/lib/apt/lists/*

# ================== Laptop_Dev (Development ================ #
FROM operator_base as laptop_dev

# Install dev-specific tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    gdb \
    vim \
    && rm -rf /var/lib/apt/lists/*


# Drop privileiges
USER $USERNAME

# Enter bash shell by default
CMD ["/bin/bash"]

# ================== CONTROLLER ==================== #

FROM operator_base as controller

# Install Pi-Specific tools...


# Drop privileges
USER $USERNAME

CMD ["ros2", "run", "image_view", "image_view", "--ros-args", "-p", "image:=/camera/camera/color/image_raw"]

# ================== ROBOT ====================== #
FROM base AS robot_prod

# Use vcstool to clone hardware repos into src/
# Copy the hardware manifest into the container
COPY hardware.repos /tmp/hardware.repos

# Use vcstool to dynamically clone the hardware repos into src/
RUN mkdir -p src && vcs import src < /tmp/hardware.repos


# Install hardware interface libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    liblgpio-dev \
    python3-lgpio \
    python3-gpiozero \
    && rm -rf /var/lib/apt/lists/*

USER $USERNAME

# Compile the code during image build
RUN --mount=type=bind,source=source,target=/home/ros/ws/src \
    --mount=type=cache,target=/home/ros/ws/build,uid=$USER_UID,gid=$USER_GID \
    --mount=type=cache,target=/home/ros/ws/log,uid=$USER_UID,gid=$USER_GID \
    bash -c "source /opt/ros/${ROS_DISTRO}/setup.sh && colcon build"

# Source the workspace in bashrc
RUN echo "source /home/${USERNAME}/ws/install/setup.bash" >> /home/${USERNAME}/.bashrc

# Production command
CMD ["ros2", "launch", "robot_bringup", "server_launch.py"]

