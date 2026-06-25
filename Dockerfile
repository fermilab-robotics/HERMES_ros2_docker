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


COPY entrypoint.sh /entrypoint.sh
# If we were using a base image, we would you the locale setting as well.

# Source the ROS2 environment
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
CMD ["/bin/bash"]

# Set the default user. Omit if we want to keep the default as root
# USER $USERNAME
