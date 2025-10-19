#!/bin/bash

# Define color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_debug() { echo -e "${BLUE}[DEBUG]${NC} $1"; }

cd /home/container || { log_error "Failed to change to /home/container"; exit 1; }

# Get internal Docker IP
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2); exit}')
export INTERNAL_IP

# Replace startup variables
MODIFIED_STARTUP=$(echo -e "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')
log_info "Startup command: ${MODIFIED_STARTUP}"

# Set default RootFS path
if [ -z "${FEX_ROOTFS_PATH}" ]; then
    log_warn "FEX_ROOTFS_PATH not set, using default"
    export FEX_ROOTFS_PATH="/home/container/rootfs/"
else
    log_info "Using custom RootFS path: ${FEX_ROOTFS_PATH}"
fi

# Check for RootFS
if [ -d "/home/container/rootfs/" ] || [ -d "${FEX_ROOTFS_PATH}/RootFS" ]; then
    log_info "RootFS already present"
else
    log_warn "RootFS not found. Downloading..."
    echo -e "\n${YELLOW}This server requires at least 9GB of disk space!${NC}"
    export FEX_APP_DATA_LOCATION="${FEX_ROOTFS_PATH}"
    export FEX_APP_CONFIG_LOCATION="/home/container/"
    export XDG_DATA_HOME="/home/container"
    FEXRootFSFetcher -y -x --distro-name=ubuntu --distro-version=22.04
fi

# Generate Config.json if needed
if [ -f "/home/container/rootfs/Ubuntu_22_04/break_chroot.sh" ] || \
   [ -f "${FEX_ROOTFS_PATH}/RootFS/Ubuntu_22_04/break_chroot.sh" ]; then
    if [ ! -f "/home/container/Config.json" ]; then
        echo '{"Config":{"RootFS":"Ubuntu_22_04"}}' > /home/container/Config.json
        log_info "Generated missing Config.json"
    fi
fi

sleep 2

# Export runtime env vars
export FEX_APP_DATA_LOCATION="${FEX_ROOTFS_PATH}"
export FEX_APP_CONFIG_LOCATION="/home/container/"
export XDG_DATA_HOME="/home/container"

# Check Config.json presence
if [ -f "/home/container/Config.json" ]; then
    log_info "Config.json found, continuing"

    # Handle Steam credentials
    if [ -z "${STEAM_USER}" ]; then
        log_warn "STEAM_USER not set. Using anonymous login."
        STEAM_USER="anonymous"
        STEAM_PASS=""
        STEAM_AUTH=""
    else
        log_info "Using Steam user: ${STEAM_USER}"
    fi

    # Set environment for Steam Proton
    if [ -f "/usr/local/bin/proton" ]; then
        if [ ! -z ${SRCDS_APPID} ]; then
            mkdir -p /home/container/.steam/steam/steamapps/compatdata/${SRCDS_APPID}
            export STEAM_COMPAT_CLIENT_INSTALL_PATH="/home/container/.steam/steam"
            export STEAM_COMPAT_DATA_PATH="/home/container/.steam/steam/steamapps/compatdata/${SRCDS_APPID}"
        else
            log_warn "----------------------------------------------------------------------------------"
            log_warn "WARNING!!! Proton needs variable SRCDS_APPID, else it will not work. Please add it"
            log_warn "Server stops now"
            log_warn "----------------------------------------------------------------------------------"
            exit 0
            fi
    fi

    # Auto update block (original logic restored)
    if [ -z "${AUTO_UPDATE}" ] || [ "${AUTO_UPDATE}" == "1" ]; then
        if [ -n "${SRCDS_APPID}" ]; then
            log_info "Auto-updating game server (AppID: ${SRCDS_APPID})"
            export HOME="/home/container"
            if [ "${STEAM_USER}" == "anonymous" ]; then
                FEX ./steamcmd/steamcmd.sh +force_install_dir /home/container +login ${STEAM_USER} ${STEAM_PASS} ${STEAM_AUTH} \
                $( [[ "${WINDOWS_INSTALL}" == "1" ]] && printf %s '+@sSteamCmdForcePlatformType windows' ) \
                +app_update ${SRCDS_APPID} \
                $( [[ -z "${SRCDS_BETAID}" ]] || printf %s "-beta ${SRCDS_BETAID}" ) \
                $( [[ -z "${SRCDS_BETAPASS}" ]] || printf %s "-betapassword ${SRCDS_BETAPASS}" ) \
                $( [[ -z "${HLDS_GAME}" ]] || printf %s "+app_set_config 90 mod ${HLDS_GAME}" ) \
                ${INSTALL_FLAGS} \
                $( [[ "${VALIDATE}" == "1" ]] && printf %s 'validate' ) +quit
            else
                FEX ./steamcmd/steamcmd.sh +force_install_dir /home/container +login ${STEAM_USER} ${STEAM_PASS} ${STEAM_AUTH} \
                $( [[ "${WINDOWS_INSTALL}" == "1" ]] && printf %s '+@sSteamCmdForcePlatformType windows' ) \
                +app_update ${SRCDS_APPID} \
                $( [[ -z "${SRCDS_BETAID}" ]] || printf %s "-beta ${SRCDS_BETAID}" ) \
                $( [[ -z "${SRCDS_BETAPASS}" ]] || printf %s "-betapassword ${SRCDS_BETAPASS}" ) \
                $( [[ -z "${HLDS_GAME}" ]] || printf %s "+app_set_config 90 mod ${HLDS_GAME}" ) \
                ${INSTALL_FLAGS} \
                $( [[ "${VALIDATE}" == "1" ]] && printf %s 'validate' ) +quit
            fi
        else
            log_warn "SRCDS_APPID not provided. Skipping update."
        fi
    else
        log_info "Auto-update disabled. Skipping update."
    fi
else
    log_error "Missing Config.json. Exiting."
    exit 0
fi

# Launch the server
log_info "Launching server..."
eval "${MODIFIED_STARTUP}"
