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
    export FEX_APP_DATA_LOCATION=${FEX_ROOTFS_PATH}; export FEX_APP_CONFIG_LOCATION=/home/container/; export XDG_DATA_HOME=/home/container; FEXRootFSFetcher -y -x --distro-name=ubuntu --distro-version=20.04
fi

# Generate Config.json if the RootFS is in a mount
if [ -f "/home/container/rootfs/Ubuntu_20_04/break_chroot.sh" ] || [ -f "${FEX_ROOTFS_PATH}/RootFS/Ubuntu_20_04/break_chroot.sh" ]
then
    if [ ! -f "/home/container/Config.json" ]
    then
        echo '{"Config":{"RootFS":"Ubuntu_20_04"}}' > /home/container/Config.json
    fi
fi

sleep 2

if [ -f "/home/container/Config.json" ]; then
    echo -e "\nNeeded config file exists, skipping"
else 
    echo -e "\nNeeded config file does not exist. exiting"
    exit 0
fi

export FEX_APP_DATA_LOCATION=${FEX_ROOTFS_PATH}
export FEX_APP_CONFIG_LOCATION=/home/container/
export XDG_DATA_HOME=/home/container


if [[ "${FRAMEWORK}" == "carbon" ]]; then
    # Carbon: https://github.com/CarbonCommunity/Carbon.Core
    echo "Updating Carbon..."
    curl -sSL "https://github.com/CarbonCommunity/Carbon.Core/releases/download/production_build/Carbon.Linux.Release.tar.gz" | tar zx
    echo "Done updating Carbon!"

    export DOORSTOP_ENABLED=1
    export DOORSTOP_TARGET_ASSEMBLY="$(pwd)/carbon/managed/Carbon.Preloader.dll"
    MODIFIED_STARTUP="LD_PRELOAD=$(pwd)/libdoorstop.so ${MODIFIED_STARTUP}"

elif [[ "$OXIDE" == "1" ]] || [[ "${FRAMEWORK}" == "oxide" ]]; then
    # Oxide: https://github.com/OxideMod/Oxide.Rust
    echo "Updating uMod..."
    curl -sSL "https://github.com/OxideMod/Oxide.Rust/releases/latest/download/Oxide.Rust-linux.zip" > umod.zip
    unzip -o -q umod.zip
    rm umod.zip
    echo "Done updating uMod!"
# else Vanilla, do nothing
fi

# Fix for Rust not starting
export LD_LIBRARY_PATH=$(pwd)/RustDedicated_Data/Plugins/x86_64:$(pwd)

# Run the Server
node /wrapper.js "${MODIFIED_STARTUP}"
