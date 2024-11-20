#!/bin/bash

# Set working directory
cd /home/container

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

# Ensure Wine prefix directory exists
echo "Creating Wine prefix directory..."
mkdir -p "$WINEPREFIX"

# Set new VNC password if available
if [ -f /home/container/.vnc/passwd ]; then
    echo "Setting VNC password..."
    echo "${VNC_PASS}" | vncpasswd -f > /home/container/.vnc/passwd
fi

# Check if wine-mono required and install it if so
if [[ $WINETRICKS_RUN =~ mono ]]; then
        echo "Installing mono"
        WINETRICKS_RUN=${WINETRICKS_RUN/mono}

        if [ ! -f "$WINEPREFIX/mono.msi" ]; then
                wget -q -O $WINEPREFIX/mono.msi https://dl.winehq.org/wine/wine-mono/9.3.0/wine-mono-9.3.0-x86.msi
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

# Soon (Auto install)
# mkdir -p "/home/container/Farming\ Simulator\ 20${FS_VERSION}"
# AVAILABLE_SPACE=$(df --output=avail -BG "/home/container/Farming\ Simulator\ 20${FS_VERSION}" | tail -n 1 | sed 's/G//')
#Compare the available space with the required space
#if [ "$AVAILABLE_SPACE" -lt "30" ]; then
#    echo "ERROR: Less than 30 GB free space on "/home/container/Farming\ Simulator\ 20${FS_VERSION}"Exiting..."
#    STARTCMD="sleep 50"
#    exit 1
#fi
#if ! [ -f "/fs/FarmingSimulator20${FS_VERSION}.exe" ]; then
#  echo "Installer files not found"
#  STARTCMD="sleep 50"
#  exit 1
#else
#  STARTCMD="wine /fs/FarmingSimulator20${FS_VERSION}.exe /SILENT /SP- /DIR=\"Z:\home\container\Farming\ Simulator\ 20${FS_VERSION}\""
#fi

# Handle various progression states
if [ "${PROGRESSION}" == "INSTALL_SERVER" ]; then
	echo "Starting the VNC server..."
    /usr/bin/vncserver -geometry 1920x1080 -rfbport "${VNC_PORT}" -rfbauth /home/container/.vnc/passwd
	
 	echo "Starting the install proces, please connect to the VNC server to continue the setup"
    STARTCMD="wine /fs/FarmingSimulator20${FS_VERSION}.exe"
	
elif [ "${PROGRESSION}" == "INSTALL_DLC" ] && [ ! -z "${DLC_EXE}" ]; then
    /usr/bin/vncserver -geometry 1920x1080 -rfbport "${VNC_PORT}" -rfbauth /home/container/.vnc/passwd
    STARTCMD="wine /home/container/dlc_install/${DLC_EXE}"
elif [ "${PROGRESSION}" == "SETUP_VNC" ]; then
    # Set up VNC configuration if it doesn't already exist
    echo "Setting up VNC configuration..."
    if [ -f "/home/container/.vnc/passwd" ]; then
        echo "VNC configuration already exists."
    else
        mkdir -p /home/container/.vnc && cd /home/container/.vnc
        wget https://raw.githubusercontent.com/QuintenQVD0/yolks/refs/heads/master/temp/experimental/xstartup
        touch /home/container/.vnc/passwd /home/container/.Xauthority
        chmod 600 /home/container/.vnc/passwd
        chmod 755 /home/container/.vnc/xstartup
    fi
    echo "Please stop the server and set the PROGRESSION variable to INSTALL_SERVER"
    STARTCMD="sleep 20"

elif [ "${PROGRESSION}" == "ACTIVATE" ] && [ -f "/home/container/.vnc/passwd" ]; then
    # Activate VNC and set the start command for the game
    echo "Activating VNC server..."
    /usr/bin/vncserver -geometry 1920x1080 -rfbport "${VNC_PORT}" -rfbauth /home/container/.vnc/passwd
	
 	echo "Starting the activation proces, please connect to the VNC server to enter your licence key..."
    STARTCMD="wine /home/container/Farming\ Simulator\ 20${FS_VERSION}/FarmingSimulator20${FS_VERSION}.exe"

elif [ "${PROGRESSION}" == "RUN" ] && [ -f "/home/container/.vnc/passwd" ]; then
    # Prepare the startup command using environment variables
    echo "Preparing startup command..."
    /usr/bin/vncserver -geometry 1920x1080 -rfbport "${VNC_PORT}" -rfbauth /home/container/.vnc/passwd

    if [ -n "${WEB_REVERSE_PORT}" ]; then
		echo "Starting the Reverse proxy for the web dashboard on port ${$WEB_REVERSE_PORT}"
        /usr/sbin/reverse_proxy_linux_x64 --listen-port ${WEB_REVERSE_PORT} --log-file /home/container/farming-dashboard-reverse-server.log --background
    else
        echo "WEB_REVERSE_PORT is not set or is empty. So we do not start the dashboard reverse proxy"
    fi
    STARTCMD=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')

else
    # Unrecognized progression state
    echo "Error: The PROGRESSION variable is set to an unknown value."
    exit 1

    STARTCMD="sleep 50"
fi

# Echo the final startup command
echo "Starting with command: ${STARTCMD}"

# Execute the startup command
eval "${STARTCMD}"
