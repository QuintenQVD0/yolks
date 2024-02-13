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

sleep 2

export FEX_APP_DATA_LOCATION=${FEX_ROOTFS_PATH}
export FEX_APP_CONFIG_LOCATION=/home/container/
export XDG_DATA_HOME=/home/container

if [ -f "/home/container/Config.json" ]; then
    echo -e "\nNeeded config file exists, skipping"
    # Switch to the container's working directory
    cd /home/container || exit 1

    ## just in case someone removed the defaults.
    if [ "${STEAM_USER}" == "" ]; then
        echo -e "steam user is not set.\n"
        echo -e "Using anonymous user.\n"
        STEAM_USER=anonymous
        STEAM_PASS=""
        STEAM_AUTH=""
    else
        echo -e "user set to ${STEAM_USER}"
    fi

    ## if auto_update is not set or to 1 update
    if [ -z ${AUTO_UPDATE} ] || [ "${AUTO_UPDATE}" == "1" ]; then 
        # Update Source Server
        if [ ! -z ${SRCDS_APPID} ]; then
            if [ "${STEAM_USER}" == "anonymous" ]; then
                export HOME=/home/container; FEXInterpreter ./steamcmd/steamcmd.sh +force_install_dir /home/container +login ${STEAM_USER} ${STEAM_PASS} ${STEAM_AUTH} $( [[ "${WINDOWS_INSTALL}" == "1" ]] && printf %s '+@sSteamCmdForcePlatformType windows' ) +app_update ${SRCDS_APPID} $( [[ -z ${SRCDS_BETAID} ]] || printf %s "-beta ${SRCDS_BETAID}" ) $( [[ -z ${SRCDS_BETAPASS} ]] || printf %s "-betapassword ${SRCDS_BETAPASS}" ) $( [[ -z ${HLDS_GAME} ]] || printf %s "+app_set_config 90 mod ${HLDS_GAME}" )  ${INSTALL_FLAGS} $( [[ "${VALIDATE}" == "1" ]] && printf %s 'validate' ) +quit
            else
                export HOME=/home/container; FEXInterpreter numactl --physcpubind=+0 ./steamcmd/steamcmd.sh +force_install_dir /home/container +login ${STEAM_USER} ${STEAM_PASS} ${STEAM_AUTH} $( [[ "${WINDOWS_INSTALL}" == "1" ]] && printf %s '+@sSteamCmdForcePlatformType windows' ) +app_update ${SRCDS_APPID} $( [[ -z ${SRCDS_BETAID} ]] || printf %s "-beta ${SRCDS_BETAID}" ) $( [[ -z ${SRCDS_BETAPASS} ]] || printf %s "-betapassword ${SRCDS_BETAPASS}" ) $( [[ -z ${HLDS_GAME} ]] || printf %s "+app_set_config 90 mod ${HLDS_GAME}" ) ${INSTALL_FLAGS} $( [[ "${VALIDATE}" == "1" ]] && printf %s 'validate' ) +quit
            fi
        else
            echo -e "No appid set. Starting Server"
        fi

    else
        echo -e "Not updating game server as auto update was set to 0. Starting Server"
    fi

else 
    echo -e "\nNeeded config file does not exist. exiting"
    exit 0
fi


# Run the Server
eval ${MODIFIED_STARTUP}
