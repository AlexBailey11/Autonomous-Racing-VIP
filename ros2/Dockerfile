# =============================================
# ROS2 Humble Dev Environment
# Uses Ubuntu 22.04
# Written for Docker usage on Fedora system
# =============================================

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV ROS_DISTRO=humble

# =====
# Set up the base system and necessary packages
# =====
RUN apt update && apt install -y \
    locales sudo curl gnupg2 lsb-release build-essential git wget vim nano tmux \
    bash-completion iputils-ping net-tools software-properties-common \
    # X11 and GL dependencies needed for RViz
    libgl1-mesa-glx libgl1-mesa-dri mesa-utils \
    libx11-xcb1 libxcb1 libxcb-glx0 libxcb-keysyms1 libxcb-image0 \
    libxcb-shm0 libxcb-icccm4 libxcb-sync1 libxcb-xfixes0 libxcb-shape0 \
    libxcb-randr0 libxcb-render-util0 libxcb-xinerama0 libxcb-xkb1 \
    libxkbcommon-x11-0 libxkbcommon0 \
    x11-utils x11-apps \
    && rm -rf /var/lib/apt/lists/*

# =====
# Locale setup
# =====
RUN locale-gen en_US en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# =====
# ROS2 Setup
# =====

# Add the repo
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
    -o /usr/share/keyrings/ros-archive-keyring.gpg

RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
    http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" \
    > /etc/apt/sources.list.d/ros2.list

# Install ROS2 Desktop and relevant tools
RUN apt update && apt install -y ros-humble-desktop ros-humble-rviz2 \
    ros-humble-ackermann-msgs ros-humble-tf-transformations \
    ros-humble-tf2-tools ros-humble-navigation2 ros-humble-nav2-bringup \
    ros-humble-xacro ros-humble-rmw-cyclonedds-cpp python3-colcon-common-extensions \
    python3-rosdep python3-vcstool python3-argcomplete python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Initialize rosdep
RUN rosdep init || true
RUN rosdep update

# Use CycloneDDS
ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp

# =====
# Qt/X11 environment
# =====
ENV QT_QPA_PLATFORM=xcb
ENV QT_XCB_NO_MITSHM=1
ENV LIBGL_ALWAYS_INDIRECT=0

# =====
# Create non-root dev user matching host UID/GID to avoid permission issues
# Override at build time with:
#   docker build --build-arg USER_UID=$(id -u) --build-arg USER_GID=$(id -g) ...
# =====
ARG USERNAME=ros
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd -s /bin/bash --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} \
    && echo "${USERNAME} ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

# Add the user to the video and render groups for GPU/DRI access
RUN usermod -aG video,render ${USERNAME} || true

# =====
# Install f1tenth_gym dependencies as root so they are available system-wide
# Pin versions to match what the custom numba 0.64.0 build expects
# =====
RUN pip3 install \
    gym \
    numpy \
    Pillow \
    pyglet \
    pyopengl \
    pyyaml \
    scipy \
    transforms3d \
    cvxopt

# =====
# Set up workspace as ros user
# =====
USER ${USERNAME}
WORKDIR /home/${USERNAME}

# =====
# Auto-source ROS2 and workspace in every shell
# =====
RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> /home/$USERNAME/.bashrc \
    && echo "source /home/$USERNAME/ros2_ws/f1tenth/install/setup.bash 2>/dev/null || true" >> /home/$USERNAME/.bashrc \
    && echo "export ROS_DOMAIN_ID=7" >> /home/$USERNAME/.bashrc

# =====
# Set up inputrc
# =====
RUN echo '"\e[A": history-search-backward' >> /home/${USERNAME}/.inputrc \
    && echo '"\e[B": history-search-forward' >> /home/${USERNAME}/.inputrc \
    && echo "set show-all-if-ambiguous on" >> /home/${USERNAME}/.inputrc

# =====
# Copy and set up the post-start setup script
# This installs f1tenth_gym from the mounted workspace and patches numba.
# Run it once after first launch: ~/setup_gym.sh
# =====
COPY setup_gym.sh /home/${USERNAME}/setup_gym.sh
RUN sudo chmod +x /home/${USERNAME}/setup_gym.sh

CMD ["/bin/bash"]