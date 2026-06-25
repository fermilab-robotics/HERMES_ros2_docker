FROM osrf/ros:lyrical-desktop-full

RUN apt-get update \
    && apt-get install -y nano \
    && rm -rf /var/lib/apt/lists/*

COPY config/ /site_config/

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
    
# Install Cyclone DDS
RUN apt-get update \
    && apt-get install -y ros-lyrical-rmw-cyclonedds-cpp \
    iproute2 \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# Tell ROS 2 to use Cyclone as the default middleware
ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp

## Hardcoded to point directly at the Pi
ENV CYCLONEDDS_URI='<CycloneDDS><Domain><General><Interfaces><NetworkInterface name="wlp4s0"/></Interfaces></General><Discovery><Peers><Peer address="10.42.0.43"/></Peers></Discovery></Domain></CycloneDDS>'

# --- ADD THIS BLOCK FOR ROSDEP ---
WORKDIR /home/ros/ws

# Copy your host's 'source' folder into the container's 'src' folder for the build phase
COPY ./source ./src

# Initialize and update rosdep
RUN rosdep init || true \
    && rosdep update

# Install dependencies based on the package.xml files in the copied src/ folder
RUN apt-get update \
    && rosdep install -y --ignore-src --from-paths src -r \
       --skip-keys "slam_toolbox \
                    turtlebot3_gazebo \
                    gazebo_ros_pkgs \
                    ros_gz \
                    ros_gz_sim \
                    ros_gz_bridge \
                    rviz2" \
    && rm -rf /var/lib/apt/lists/*
# ---------------------------------

COPY entrypoint.sh /entrypoint.sh
# If we were using a base image, we would you the locale setting as well.

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
CMD ["/bin/bash"]


# Source the ROS2 environment (Not working right now)
RUN echo "source /opt/ros/lyrical/setup.bash" >> /home/ros/.bashrc

# Set the default user. Omit if we want to keep the default as root
# USER $USERNAME
