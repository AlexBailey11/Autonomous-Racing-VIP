# Workspace Infrastructure for Autonomous Racing VIP


## Purpose
The overall goal of this was to remove the need for students to install or dual-boot Ubuntu 22.04 on their personal laptops, and instead have a portable version of the workspace infrastructure. For me, the main motivation was to remove the need for me to triple-boot, as I had already had Fedora installed previously.
>### Disclaimer
>I created all of this on a Fedora 43 KDE Edition installation, and with my local clones of the `f1tenth` and `f1tenth_gym` repos created by others. Some assumptions were made, and I did my best to outline those below, but things may break if I have forgotten something or your setup is slightly different than mine.

## Setup
### 1. Ensure you have docker installed on your host
Please follow the guide for your host's OS in [Docker's Installation Guide](https://docs.docker.com/engine/install/).
A simple test to see if you have completed this step is as follows:
```
sudo docker run hello-world
```

### 2. Clone `f1tenth` and `f1tenth_gym` Repos
To clone these repos, follow the instructions provided in the VIP's wiki. A synopsys of those instructions can be found below.

**1. Create ideal folder structure**
Ideally the structure of your host's directories is set up the same as below. Note, the workspace directory and repos will be set up in later steps.
```
Autonomous-Racing-VIP
├── README.md
└── ros2
    ├── Dockerfile
    ├── launch.sh
    └── ros_ws
        ├── f1tenth
        ├── f1tenth_gym
        └── setup_gym.sh
```
**2. Clone the repos**
More information about this step can be found on the VIP's wiki. Below are the high level instructions for what to do.
Move to the workspace directory and clone the necessary repos:
```
cd ros_ws
git clone --recurse-submodules https://github.com/Nick-Zhang1996/f1tenth
git clone https://github.com/f1tenth/f1tenth_gym
```
After doing these steps, you should have a folder structure shown above. If not, I cannot confidently say that your setup will work.

### 3. Build the docker image
Once you have the above set up correctly, you should be able to build the docker image and start the container. To build the image, run the following command while in the directory containing the Dockerfile (`/ros2`):
```
docker build --build-arg USER_UID=$(id -u) --build-arg USER_GID=$(id -g) -t ros2-humble-dev .
```
This will create a new docker image called ros2-humble-dev, which will be used by the launch script to create the container. It is important that you keep the name of the image the same, or update the launch script file with whatever your image is called.

### 4. Launch the container
To launch the container, you simply run the launch script from your terminal. It will take care of creating the container if it is the first time you are launching, and in subsequent launches, it will simply relaunch the previously created container. To do this, first you will need to ensure the scirpt is made executable:
```
chmod +x launch.sh
```
Then, you can simply run the script from within the `/ros` directory:
```
./launch.sh
```
This should put you directly into your Ubuntu 22.04 container with ROS2 installed.

### 5. Set up the simulator
The first time the container is launched after being created, you will need to run the setup script for the simulator. Similarly to the launch script, you will need to ensure it is executable:
```
chmod +x setup_gym.sh
```
Then, run the script:
```
./setup_gym.sh
```

## Usage
Below are some useful commands for using the container for working with the simulator and car.

**1. Opening another terminal**
To open another terminal so that you can run multiple ros processes simultaneously, utilize the following command on your host:
```
docker exec -it vip_ros2_dev /bin/bash
```
After doing so, ensure that all of the necessary bash setup has been done by sourcing the `.bashrc` file:
```
source ~/.bashrc
```