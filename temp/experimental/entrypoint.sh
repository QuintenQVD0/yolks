#!/bin/bash

# Set working directory
cd /home/container || exit

# Display system information
echo "Running on Debian version: $(cat /etc/debian_version)"
echo "Current timezone: $(cat /etc/timezone)"
echo "Wine version: $(wine --version)"
export DISPLAY=":1"

# Make internal Docker IP address available to processes
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Define Wine prefix path
export WINEPREFIX=/home/container/.wine
#export XDG_RUNTIME_DIR="/home/container/.cache"

# Ensure Wine prefix directory exists
echo "Creating Wine prefix directory..."
mkdir -p "$WINEPREFIX"

# Set new VNC password if available
if [ -f /home/container/.vnc/passwd ]; then
    echo "Setting VNC password..."
    echo "${VNC_PASS}" | vncpasswd -f > /home/container/.vnc/passwd
fi

# Check if wine-mono required and install it if so
if [[ $WINETRICKS_RUN =~ movo ]]; then
        echo "Installing mono"
        WINETRICKS_RUN=${WINETRICKS_RUN/mono}

        if [ ! -f "$WINEPREFIX/mono.msi" ]; then
                wget -q -O $WINEPREFIX/mono.msi https://dl.winehq.org/wine/wine-mono/9.4.0/wine-mono-9.4.0-x86.msi
        fi

        wine msiexec /i $WINEPREFIX/mono.msi /qn /quiet /norestart /log $WINEPREFIX/mono_install.log
fi


# Install additional Winetricks
for trick in $WINETRICKS_RUN; do
    echo "Installing Winetrick: $trick"
    winetricks -q "$trick"
done

# Kill any old VNC sessions if running
echo "Killing any existing VNC sessions..."
[ -z "${DISPLAY}" ] || /usr/bin/vncserver -kill "${DISPLAY}"

# Clean up potential leftover lock files
echo "Removing leftover VNC lock files..."
find /tmp -maxdepth 1 -name ".X*-lock" -type f -exec rm -f {} \;
if [[ -d /tmp/.X11-unix ]]; then
    find /tmp/.X11-unix -maxdepth 1 -name 'X*' -type s -exec rm -f {} \;
fi

# Check if FS_VERSION is not 22 or 25
if [[ "${FS_VERSION}" != "22" && "${FS_VERSION}" != "25" ]]; then
  # Set FS_VERSION to 22
  FS_VERSION="22"
  echo "FS_VERSION is set to 22"
else
  echo "FS_VERSION is to Farming Simulator 20${FS_VERSION}"
fi

# Handle various progression states
if [ "${PROGRESSION}" == "INSTALL_SERVER" ]; then
    /usr/bin/vncserver -geometry 1920x1080 -rfbport "${VNC_PORT}" -rfbauth /home/container/.vnc/passwd
     # Check if the directory is writable and the file exists
     
    STARTCMD="wine /fs/FarmingSimulator20${FS_VERSION}.exe /SILENT /SP- /DIR=\"Z:\home\container\Farming Simulator 20${FS_VERSION}\""

elif [ "${PROGRESSION}" == "INSTALL_DLC" ] && [ -n "${DLC_EXE}" ]; then
    /usr/bin/vncserver -geometry 1920x1080 -rfbport "${VNC_PORT}" -rfbauth /home/container/.vnc/passwd
    STARTCMD="wine /home/container/dlc_install/${DLC_EXE}"

elif [ "${PROGRESSION}" == "ACTIVATE" ] && [ -f "/home/container/.vnc/passwd" ]; then
    # Activate VNC and set the start command for the game
    echo "Activating VNC server..."
    /usr/bin/vncserver -geometry 1920x1080 -rfbport "${VNC_PORT}" -rfbauth /home/container/.vnc/passwd
    
    echo "Starting the activation proces, please connect to the VNC server to enter your licence key..."
    STARTCMD="wine /home/container/Farming\ Simulator\ 20${FS_VERSION}/FarmingSimulator20${FS_VERSION}.exe"
    
    # Echo the final startup command
    echo "Starting with command: ${STARTCMD}"
    
    # Execute the startup command
    eval "${STARTCMD}"
    
    # Keep the session alive after the executable exits
    tail -f /dev/null

elif [ "${PROGRESSION}" == "RUN" ] && [ -f "/home/container/.vnc/passwd" ]; then
    # Prepare the startup command using environment variables
    echo "Preparing startup command..."
    /usr/bin/vncserver -geometry 1920x1080 -rfbport "${VNC_PORT}" -rfbauth /home/container/.vnc/passwd

    STARTCMD=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')
else
    # Unrecognized progression state
    echo "Error: The PROGRESSION variable is set to an unknown value."
    STARTCMD="sleep 50"
    exit 1

fi

if ! [ "${PROGRESSION}" == "ACTIVATE" ]; then

    # Echo the final startup command
    echo "Starting with command: ${STARTCMD}"

    # Execute the startup command
    eval "${STARTCMD}"

fi
