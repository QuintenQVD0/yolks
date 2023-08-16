#!/bin/bash
cd /home/container || exit

# Make internal Docker IP address available to processes.
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Replace Startup Variables
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo -e ":/home/container$ ${MODIFIED_STARTUP}"

if [ -d "/home/container/rootfs" ]
then
    echo "RootFS already downloaded"	 
else
    echo -e "\nThis server will need at least 9GB of disk space!"
    export FEX_APP_DATA_LOCATION=/home/container/rootfs/; export FEX_APP_CONFIG_LOCATION=/home/container/; export XDG_DATA_HOME=/home/container; FEXRootFSFetcher -y -x --distro-name=ubuntu --distro-version=20.04
fi

sleep 2

if [ -f "/home/container/Config.json" ]; then
    echo -e "\nNeeded config file exists, skipping"
else 
    echo -e "\nNeeded config file does not exist. exiting"
    exit 0
fi

# Setup NSS Wrapper for use ($NSS_WRAPPER_PASSWD and $NSS_WRAPPER_GROUP have been set by the Dockerfile)
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
envsubst < /passwd.template > ${NSS_WRAPPER_PASSWD}

export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libnss_wrapper.so

export FEX_APP_DATA_LOCATION=/home/container/rootfs/
export FEX_APP_CONFIG_LOCATION=/home/container/
export XDG_DATA_HOME=/home/container

# Run the Server
eval ${MODIFIED_STARTUP}
