#!/bin/bash
# =============================================
# ROS2 Humble Dev Launcher
# Written for Docker usage on Fedora system
# =============================================

CONTAINER_NAME="vip_ros2_dev"
IMAGE_NAME="ros2-humble-dev"
WORKSPACE_PATH="$HOME/Documents/AutonomousDrivingVIP/ros2/ros_ws/f1tenth"

# =====
# Validate display is set
# =====
if [ -z "$DISPLAY" ]; then
    echo "WARNING: \$DISPLAY is not set. Defaulting to :0"
    export DISPLAY=:0
fi

# =====
# Grant X11 access to the container
# =====
xhost +local:docker >/dev/null 2>&1
xhost +SI:localuser:$(id -un) >/dev/null 2>&1

# =====
# Determine GPU flags
# =====
GPU_FLAGS=""
if [ -d /dev/dri ]; then
    GPU_FLAGS="--device /dev/dri"
fi

# =====
# Start or create the container
# =====
if docker container inspect $CONTAINER_NAME &>/dev/null; then
    echo "Container '$CONTAINER_NAME' exists. Starting..."
    docker start -ai $CONTAINER_NAME
else
    echo "Creating new ROS2 container '$CONTAINER_NAME'..."
    docker run -it \
        --name $CONTAINER_NAME \
        --network=host \
        --user $(id -u):$(id -g) \
        --env DISPLAY=$DISPLAY \
        --env QT_QPA_PLATFORM=xcb \
        --env QT_XCB_NO_MITSHM=1 \
        --env XDG_RUNTIME_DIR=/tmp \
        --env ROS_DOMAIN_ID=7 \
        -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
        -v "$WORKSPACE_PATH":/home/ros/ros2_ws \
        $GPU_FLAGS \
        $IMAGE_NAME
fi