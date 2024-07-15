#!/bin/bash
cd /home/container || exit

# Make internal Docker IP address available to processes.
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Replace Startup Variables
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo -e ":/home/container$ ${MODIFIED_STARTUP}"

if [ -z "${FEX_ROOTFS_PATH}" ]; then
    echo "Setting Default RootFS PATH"
    export FEX_ROOTFS_PATH=/home/container/rootfs/
else
    echo "Custom RootFS PATH"
fi

if [ -d "/home/container/rootfs/" ] ||[ -d "${FEX_ROOTFS_PATH}/RootFS" ]
then
    echo "RootFS already downloaded"	 
else
    echo -e "\nThis server will need at least 9GB of disk space!"
    export FEX_APP_DATA_LOCATION=${FEX_ROOTFS_PATH}; export FEX_APP_CONFIG_LOCATION=/home/container/; export XDG_DATA_HOME=/home/container; FEXRootFSFetcher -y -x --distro-name=ubuntu --distro-version=22.04
fi

# Generate Config.json if the RootFS is in a mount
if [ -f "/home/container/rootfs/Ubuntu_22_04/break_chroot.sh" ] || [ -f "${FEX_ROOTFS_PATH}/RootFS/Ubuntu_22_04/break_chroot.sh" ]
then
    if [ ! -f "/home/container/Config.json" ]
    then
        echo '{"Config":{"RootFS":"Ubuntu_22_04"}}' > /home/container/Config.json
    fi
fi

sleep 2

export FEX_APP_DATA_LOCATION=${FEX_ROOTFS_PATH}
export FEX_APP_CONFIG_LOCATION=/home/container/
export XDG_DATA_HOME=/home/container

if [ -f "/home/container/Config.json" ]; then
    echo -e "\nNeeded config file exists, skipping"
    # Switch to the container's working directory
    cd /home/container || exit 1
else 
    echo -e "\nNeeded config file does not exist. exiting"
    exit 0
fi

# Run the Server
eval ${MODIFIED_STARTUP}
