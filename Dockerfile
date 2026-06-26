# ============ BASE PACKAGE ===============

FROM ros:lyrical-ros-base AS base

# Core tools and middleware
RUN apt-get update \
    && apt-get install -y nano \
    ros-lyrical-rmw-cyclonedds-cpp \
    python3-vcstool \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user. Note that the username is different from host!
ARG USERNAME=ros
ARG USER_UID=1000
ARG USER_GID=$USER_UID



# Delete user if it exists in container (e.g Ubuntu Noble: ubuntu)
RUN if id -u $USER_UID ; then userdel `id -un $USER_UID` ; fi

RUN groupadd --gid $USER_GID $USERNAME \
    # -s specifies the default login shell for the user
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    # Create a home directory and config directory for the user (some programs want that)
    && mkdir /home/$USERNAME/.config && chown $USER_UID:$USER_GID /home/$USERNAME/.config


# [Optional] Add sudo support. Omit if you don't need to install software after connecting.
RUN apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && rm -rf /var/lib/apt/lists/*

RUN rosdep init || true \
    && rosdep update \

# Configurations
COPY config/ /site_config/

# DDS config
COPY cyclonedds.xml /cyclonedds.xml
ENV CYCLONEDDS_URI="file:///cyclonedds.xml"

# Set environment variables
# Tell ROS 2 to use Cyclone as the default middleware
ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp

# Source the ROS2 environment 
RUN echo "source /opt/ros/lyrical/setup.bash" >> /home/ros/.bashrc

WORKDIR /home/ros/ws

# Copy over repository source to get overall dependencies
COPY ./source ./src

COPY entrypoint.sh /entrypoint.sh

# Entrypoint script and launch bash
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
CMD ["/bin/bash"]


# ================== Controller (Display node) ================ #

FROM base as controller

# rosdep scans code
RUN apt-get update \
    && rosdep install -y --ignore-src --from-paths src \
    && rm -rf /var/lib/apt/lists/*

# Install the Telemetry and joystick diagnostic tools
# Program for testing joystick devices
RUN apt-get update \
    && apt-get install -y \
    evtest \
    jstest-gtk \
    python3-serial \
    ros-lyrical-image-view \
    ros-lyrical-teleop_twist_keyboard \
    && rm -rf /var/lib/apt/lists/*

USER $USERNAME


# ================== Laptop (Display node) ================ #

FROM base as laptop

# rosdep scans code
RUN apt-get update \
    && rosdep install -y --ignore-src --from-paths src \
    && rm -rf /var/lib/apt/lists/*
    
# Install the Telemetry and joystick diagnostic tools
# Program for testing joystick devices
RUN apt-get update \
    && apt-get install -y \
    evtest \
    jstest-gtk \
    python3-serial \
    ros-lyrical-image-view \
    ros-lyrical-teleop_twist_keyboard \
    && rm -rf /var/lib/apt/lists/*

USER $USERNAME


# ================== ROBOT ====================== #
FROM base AS robot

# Use vcstool to clone hardware repos into src/


# Copy the hardware manifest into the container
COPY hardware.repos /tmp/hardware.repos

# Use vcstool to dynamically clone the hardware repos into src/
RUN vcs import src < /tmp/hardware.repos


RUN apt-get update \
    && rosdep install -y --ignore-src --from-paths src \
    && rm -rf /var/lib/apt/lists/*

# Install hardware interface libraries
RUN apt-get update && apt-get install -y \
    build-essential \
    liblgpio-dev \
    python3-pip \
    && pip3 install gpiozero lgpio --break-system-packages \
    && rm -rf /var/lib/apt/lists/*

USER $USERNAME