#!/bin/bash

# Set working directory
cd /home/container || exit

print_message() {
  local message="$1"
  cat << EOF
==============================
Information
==============================

${message}

==============================
EOF
}

start_vnc() {
    local name="$1"
    /usr/bin/vncserver -geometry 1920x1080 -rfbport 5900 -name "$name" -rfbauth /home/container/.vnc/passwd -localhost
    /usr/bin/websockify -D --web /usr/share/novnc "${VNC_PORT}" localhost:5900
}


# Display system information
echo "Running on Debian version: $(cat /etc/debian_version)"
echo "Current timezone: $(cat /etc/timezone)"
echo "Wine version: $(wine --version)"

# Make internal Docker IP address available to processes
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

if ! [ "$INTERNAL_IP" == "10.0.0.41" ]; then
  export DISPLAY=":1"
fi

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
  # Set FS_VERSION to 25
  FS_VERSION="25"
  echo "FS_VERSION is set to 25"
else
  echo "FS_VERSION is to Farming Simulator 20${FS_VERSION}"
fi

# apply the new openbox config
sed -i '14s|.*|openbox --config-file /rc.xml \&|' /home/container/.vnc/xstartup

# Set the path for the certificate file
CERT_FILE="self.pem"

# Extract region (ST) and city (L) from TZ
if [[ "$TZ" == *"/"* ]]; then
  REGION="${TZ%%/*}"  # Part before /
  CITY="${TZ#*/}"     # Part after /
else
  # Fallback for single-value timezones like UTC
  REGION="UTC"
  CITY="City"         # Default city placeholder
fi

# Replace underscores with spaces for nicer display
CITY="${CITY//_/ }"
REGION="${REGION//_/ }"

# Generate the certificate if it doesn't exist
if [ ! -f "$CERT_FILE" ]; then
  echo "Generating self-signed certificate at $CERT_FILE (valid 5 years)..."
  openssl req -new -x509 -days 1825 -nodes -out "$CERT_FILE" -keyout "$CERT_FILE" \
  -subj "/C=EU/ST=${REGION}/L=${CITY}/O=MyOrg/OU=IT/CN=${SERVER_IP}"
  echo "Certificate generated successfully."
else
  echo "Certificate $CERT_FILE already exists. Skipping generation."
fi

# Handle various progression states
if [ "${PROGRESSION}" == "INSTALL_SERVER" ]; then
    start_vnc "Installing"
    
    print_message "Starting the installation process. Please do NOT stop the server!\n\nTo monitor progress, visit: https://${SERVER_IP}:${VNC_PORT}"
    STARTCMD="wine /fs/FarmingSimulator20${FS_VERSION}.exe /SILENT /SP- /DIR=\"Z:\home\container\Farming Simulator 20${FS_VERSION}\""

elif [ "${PROGRESSION}" == "INSTALL_DLC" ] && [ -n "${DLC_EXE}" ]; then
    /usr/bin/vncserver -geometry 1920x1080 -rfbport "5900" -rfbauth /home/container/.vnc/passwd -localhost
    /usr/bin/websockify -D --web /usr/share/novnc "${VNC_PORT}" localhost:5900
    
    STARTCMD="wine /home/container/dlc_install/${DLC_EXE}"

elif [ "${PROGRESSION}" == "ACTIVATE" ] && [ -f "/home/container/.vnc/passwd" ]; then
    # Activate VNC and set the start command for the game
    start_vnc "Activate / Update"

    print_message "Starting the activation process. Please connect to the VNC server to enter your license key.\n\nConnect here: https://${SERVER_IP}:${VNC_PORT}"    STARTCMD="wine /home/container/Farming\ Simulator\ 20${FS_VERSION}/FarmingSimulator20${FS_VERSION}.exe"
    STARTCMD="wine /home/container/Farming\ Simulator\ 20${FS_VERSION}/FarmingSimulator20${FS_VERSION}.exe"

elif [ "${PROGRESSION}" == "RUN" ] && [ -f "/home/container/.vnc/passwd" ]; then
    start_vnc "Farming Simulator 22/25 Server"

    print_message "You can now configure the server on the dashboard.\n\nConnect to the VNC server here: https://${SERVER_IP}:${VNC_PORT}"
    STARTCMD=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')
else
    # Unrecognized progression state
    echo "Error: The PROGRESSION variable is set to an unknown value."
    STARTCMD="sleep 50"
    exit 1

fi

echo "Starting with command: ${STARTCMD}"
eval "${STARTCMD}"

# Keep session alive if needed
if [[ "$PROGRESSION" == "ACTIVATE" || "$PROGRESSION" == "INSTALL_DLC" ]]; then
    tail -f /dev/null
fi
