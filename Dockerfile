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

# 3. RoboticsSeaBass Guide to docker and ROS2 - overlay and underlay pattern:
# https://roboticseabass.com/2023/07/09/updated-guide-docker-and-ros2/

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

# Add user to dialout group (to get serial devices work)
RUN usermod -aG dialout ${USERNAME}

# Configurations (some packages might want this)
COPY config/ /site_config/

# DDS config
# Comment out copy for DEV
# COPY cyclonedds.xml /cyclonedds.xml
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
    ros-${ROS_DISTRO}-compressed-image-transport \
    ros-${ROS_DISTRO}-image-view \
    ros-${ROS_DISTRO}-rqt-image-view  \
    ros-${ROS_DISTRO}-teleop-twist-keyboard \
     # ROS2 control:
    ros-${ROS_DISTRO}-ros2-control \
    ros-${ROS_DISTRO}-ros2-controllers \
    && rm -rf /var/lib/apt/lists/*

# ROOT user: Temperarily bind code to let rosdep scan and install dependencies
RUN --mount=type=bind,source=source,target=/home/ros/ws/src \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    apt-get update \
    && rosdep install -y --ignore-src --from-paths src --skip-keys="ros_gz ros_gz_sim ros_gz_bridge ros_gz_bridge"

# TODO: Make skip keys standard for controller and robot
# OR: USE condition="..." in package.xml
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
    ros-${ROS_DISTRO}-gz-ros2-control \
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

# ----------------Build colcon workspace -------------

# Set the default SHELL to bash so we don't need /bin/bash -c in our run command
SHELL ["/bin/bash", "-c"]

RUN --mount=type=bind,source=source,target=/home/ros/ws/src \
    source /opt/ros/${ROS_DISTRO}/setup.bash \
    # Source the underlay before running colcon build
    && source  ${UNDERLAY_WS}/install/local_setup.bash \
    && colcon build --packages-select my_bringup hermes_description my_diagnostics

#drop privileges
USER $USERNAME

# Run our launch file (entrypoint.sh handles the install/setup.bash sourcing)
CMD ["ros2", "launch", "my_bringup", "controller.launch.py"]

# ================= ROBOT BASE ====================== #
FROM base AS robot_base

# Underlay workspace -- third party hardware driver source
ARG UNDERLAY_WS=/opt/underlay_ws
ENV UNDERLAY_WS=${UNDERLAY_WS}

WORKDIR ${UNDERLAY_WS}

# Fetch third-party hardware driver source (e.g. realsense-ros) via vcstool.
COPY hardware.repos /tmp/hardware.repos
RUN mkdir -p src && vcs import --recursive src < /tmp/hardware.repos

# Install hardware interface libraries needed for vendor drivers
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    liblgpio-dev \
     # for lidar:
    libudev-dev \
    # Note, we need to use the pip gpiozero
    swig \
    python3-dev \
    python3-pip \
    # critical: install compression plugins before building the underlay:
    ros-${ROS_DISTRO}-image-transport-plugins \
    ros-${ROS_DISTRO}-compressed-image-transport \
    && pip3 install --upgrade lgpio gpiozero --break-system-packages \
    && rm -rf /var/lib/apt/lists/*

# Note
# Install ROS2 dependencies, but NOT the camera node binary
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
   #  ros-${ROS_DISTRO}-camera-ros \ - for Pi Cam
    ros-${ROS_DISTRO}-librealsense2* \
    && rm -rf /var/lib/apt/lists/*


    # Resolve realsense-ros's own dependencies and build the underlay now.
# on top of src/ later. Ensure we skip the camera binary
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
    python3-colcon-common-extensions \
    # -r means that the rosdep still succeeds even if one package didn't
    && rosdep install -y --ignore-src -r --from-paths src --skip-keys="librealsense2 realsense2_camera" \
    && rm -rf /var/lib/apt/lists/*


RUN /bin/bash -c "source /opt/ros/${ROS_DISTRO}/setup.bash && colcon build --symlink-install --cmake-args=-DCMAKE_BUILD_TYPE=Release" \
    && chown -R ros:ros ${UNDERLAY_WS} \
    && echo "source ${UNDERLAY_WS}/install/local_setup.bash" >> /home/ros/.bashrc \
    # Overlay hasn't been built yet at image-build time 
    && echo '[ -f /home/ros/ws/install/local_setup.bash ] && source /home/ros/ws/install/local_setup.bash' >> /home/ros/.bashrc


# Overlay workspace - our own packages under src/, built at runtime
WORKDIR /home/ros/ws

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
    --skip-keys="python3-lgpio python3-gpiozero librealsense2 realsense2_camera ros_gz ros_gz_sim ros_gz_bridge ros_gz_bridge rviz2" \
    && rm -rf /var/lib/apt/lists/*


# ================= ROBOT DEV ====================== #
# Eventually: this should be hermes_dev
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


# ================= ROBOT PROD ====================== #

FROM robot_base AS robot_prod

# ----------------Build colcon workspace -------------

# Set the default SHELL to bash so we don't need /bin/bash -c in our run command
SHELL ["/bin/bash", "-c"]

RUN --mount=type=bind,source=source,target=/home/ros/ws/src \
    source /opt/ros/${ROS_DISTRO}/setup.bash \
    # Source the underlay before running colcon build
    && source  ${UNDERLAY_WS}/install/local_setup.bash \
    && colcon build --packages-select hermes_hardware my_bringup hermes_description my_diagnostics

#drop privileges
USER $USERNAME

# Run our launch file (entrypoint.sh handles the install/setup.bash sourcing)
CMD ["ros2", "launch", "my_bringup", "hermes.launch.py"]