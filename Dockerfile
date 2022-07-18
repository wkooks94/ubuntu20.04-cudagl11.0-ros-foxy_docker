FROM nvidia/cudagl:11.0.3-devel-ubuntu20.04

ARG DEBIAN_FRONTEND=noninteractive

## Update nvidia GPG key
RUN rm /etc/apt/sources.list.d/cuda.list \
    && apt-key del 7fa2af80 \
    && apt-get update && apt-get install -y --no-install-recommends wget \
    && wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.0-1_all.deb \
    && dpkg -i cuda-keyring_1.0-1_all.deb \
    && apt-get update
    
## Install ROS2
# Install language
RUN apt-get install -q -y --no-install-recommends locales \
    && locale-gen en_US en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*
ENV LANG=en_US.UTF-8

# Setup timezone
RUN echo 'Etc/UTC' > /etc/timezone \
    && ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime \
    && apt-get update \
    && apt-get install -q -y --no-install-recommends tzdata \
    && rm -rf /var/lib/apt/lists/*

# install packages
RUN apt-get update \
    && apt-get install -q -y --no-install-recommends \
    curl \
    dirmngr \
    gnupg2 \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*
    
# setup keys and sources.list
RUN apt-get update \
    && curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key  -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu focal main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null
    
# install ros2 packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    ros-foxy-ros-core=0.9.2-1* \
    python3-argcomplete \
    && rm -rf /var/lib/apt/lists/*

ENV ROS_DISTRO=foxy
ENV AMENT_PREFIX_PATH=/opt/ros/foxy
ENV COLCON_PREFIX_PATH=/opt/ros/foxy
ENV LD_LIBRARY_PATH=/opt/ros/foxy/lib
ENV PATH=/opt/ros/foxy/bin:$PATH
ENV PYTHONPATH=/opt/ros/foxy/lib/python3.8/site-packages
ENV ROS_PYTHON_VERSION=3
ENV ROS_VERSION=2

# install dev tools
RUN apt-get update && apt-get install -q -y --no-install-recommends \
    bash-completion \
    build-essential \
    cmake \
    gdb \
    git \
    pylint3 \
    python3-argcomplete \
    python3-colcon-common-extensions \
    python3-pip \
    python3-rosdep \
    python3-vcstool \
    vim \
    # Install ros distro testing packages
    ros-foxy-ament-lint \
    ros-foxy-launch-testing \
    ros-foxy-launch-testing-ament-cmake \
    ros-foxy-launch-testing-ros \
    python3-autopep8 \
    && rm -rf /var/lib/apt/lists/* \
    && rosdep init || echo "rosdep already initialized"
    
COPY ./ros_entrypoint.sh /
RUN chmod 755 /ros_entrypoint.sh
    
ARG USERNAME=ros-foxy
ARG USER_UID=1000
ARG USER_GID=$USER_UID

## Create a non-root user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && rm -rf /var/lib/apt/lists/*
    
USER $USERNAME

# Env vars for the nvidia-container-runtime.
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES graphics,utility,compute
ENV QT_X11_NO_MITSHM=1

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["/bin/bash"]
