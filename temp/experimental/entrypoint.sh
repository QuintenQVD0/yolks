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

# Handle various progression states
if [ "${PROGRESSION}" == "MOVE_MOUNT_FILES" ]; then
    # Move the mounted game and server files to the correct directory
    echo "Moving mounted game and server files..., This can take a wile"
    mkdir -p /home/container/Farming\ Simulator\ 2022/
    #cp -r /fs/* /home/container/Farming\ Simulator\ 2022/
    mv /fs/* /home/container/Farming\ Simulator\ 2022/
    echo "Please stop the server and set the PROGRESSION variable to SETUP_VNC"
    STARTCMD="sleep 20"

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
        echo "export DISPLAY=${DISPLAY}" >> /home/container/.vnc/xstartup
        echo "[ -r /home/container/.Xresources ] && xrdb /home/container/.Xresources" >> /home/container/.vnc/xstartup
        echo "xsetroot -solid grey" >> /home/container/.vnc/xstartup
    fi
    echo "Please stop the server and set the PROGRESSION variable to ACTIVATE"
    STARTCMD="sleep 20"

elif [ "${PROGRESSION}" == "ACTIVATE" ] && [ -f "/home/container/.vnc/passwd" ]; then
    # Activate VNC and set the start command for the game
    echo "Activating VNC server..."
    /usr/bin/vncserver -geometry 1920x1080 -rfbport "${VNC_PORT}" -rfbauth /home/container/.vnc/passwd 
    STARTCMD="wine /home/container/Farming\ Simulator\ 2022/FarmingSimulator2022.exe"

elif [ "${PROGRESSION}" == "RUN" ] && [ -f "/home/container/.vnc/passwd" ]; then
    # Prepare the startup command using environment variables
    echo "Preparing startup command..."
    STARTCMD=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')

else
    # Unrecognized progression state
    echo "Error: The PROGRESSION variable is set to an unknown value."
    exit 1
fi

# Echo the final startup command
echo "Starting with command: ${STARTCMD}"

# Execute the startup command
eval "${STARTCMD}"
