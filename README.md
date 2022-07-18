# ubuntu20.04-cudagl11.0-ros-foxy_docker

## docker build cmd
```
docker build --no-cache --force-rm -f Dockerfile -t gpuvoxel:base .
```

## docker run cmd
```
docker run -it \
    --rm \
    --volume=/tmp/.X11-unix:/tmp/.X11-unix:rw \
    --runtime=nvidia
    --env="NVIDIA_DRIVER_CAPABILITIES=all" \
    --env="NVIDIA_VISIBLE_DEVICES=all" \
    --env="DISPLAY=$DISPLAY" \
    --shm-size=1gb \
    --name=foxy-cuda-test \
    ros-foxy-cudagl11.0:base /bin/bash
```
