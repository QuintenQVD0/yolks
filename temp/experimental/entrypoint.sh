#!/bin/bash

# Set working directory
cd /home/container || exit

print_message() {
  local message="$1"
  # Replace literal \n with actual newlines
  message=$(echo -e "$message")
  cat << EOF
==============================
Information
==============================

${message}

==============================
EOF
}

# Log/Color Echo function
cecho() {
    local level="$1"
    local text="$2"
    local reset="\033[0m"

    case "$level" in
        info|white)
            code="\033[97m"; prefix="[INFO] " ;;
        warning|yellow)
            code="\033[33m"; prefix="[WARNING] " ;;
        error|red)
            code="\033[31m"; prefix="[ERROR] " ;;
        success|green)
            code="\033[32m"; prefix="[SUCCESS] " ;;
        system|cyan)
            code="\033[36m"; prefix="[SYSTEM] " ;;
        blue)
            code="\033[34m"; prefix="[BLUE] " ;;
        magenta)
            code="\033[35m"; prefix="[MAGENTA] " ;;
        bold)
            code="\033[1m"; prefix="" ;;
        *)
            code="$reset"; prefix="" ;;
    esac

    # Use printf instead of echo -e
    printf "%b%s%s%b\n" "${code}" "${prefix}" "${text}" "${reset}"
}



start_vnc() {
    local name="$1"

    # Validate VNC_PORT
    if [[ -z "${VNC_PORT}" ]]; then
        cecho error "❌ Error: VNC_PORT is not set."
        return 1
    fi

    if ! [[ "${VNC_PORT}" =~ ^[0-9]+$ ]] || (( VNC_PORT < 1025 || VNC_PORT > 65535 )); then
        cecho error "❌ Error: VNC_PORT must be a valid non-privileged TCP port number (1025-65535)."
        return 1
    fi

    /usr/bin/vncserver -geometry 1920x1080 -rfbport 5900 -name "$name" -rfbauth /home/container/.vnc/passwd -localhost
	sleep 5
    /usr/bin/websockify -D --web /usr/share/novnc "${VNC_PORT}" --log-file "/home/container/.vnc/websockify.txt" localhost:5900
}



# Display system information
cecho system "Running on Debian version: $(cat /etc/debian_version)"
cecho system "Current timezone: $(cat /etc/timezone)"
cecho system "Wine version: $(wine --version)"

cecho system "Running license validation..."
if ! java -jar /license-key-validator.jar; then
    exit 1
fi

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
cecho info "Creating Wine prefix directory..."
mkdir -p "$WINEPREFIX"

# Set new VNC password if available
if [ -f /home/container/.vnc/passwd ]; then
    cecho info "Setting VNC password..."
    echo "${VNC_PASS}" | vncpasswd -f > /home/container/.vnc/passwd
fi

# Install additional Winetricks
for trick in $WINETRICKS_RUN; do
    echo "Installing Winetrick: $trick"
    winetricks -q "$trick"
done

# Kill any old VNC sessions if running
cecho info "Killing any existing VNC sessions..."
[ -z "${DISPLAY}" ] || /usr/bin/vncserver -kill "${DISPLAY}"

# Clean up potential leftover lock files
cecho info "Removing leftover VNC lock files..."
find /tmp -maxdepth 1 -name ".X*-lock" -type f -exec rm -f {} \;
if [[ -d /tmp/.X11-unix ]]; then
    find /tmp/.X11-unix -maxdepth 1 -name 'X*' -type s -exec rm -f {} \;
fi

# Check if FS_VERSION is not 22 or 25
if [[ "${FS_VERSION}" != "22" && "${FS_VERSION}" != "25" ]]; then
  # Set FS_VERSION to 25
  FS_VERSION="25"
  cecho warning "FS_VERSION was invalid so defaulted to 25"
else
  cecho info "FS_VERSION is to Farming Simulator 20${FS_VERSION}"
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

# Skip SSL generation if nossl.txt exists
if [ -f "/home/container/nossl.txt" ]; then
  cecho warning "SSL generation skipped because /home/container/nossl.txt exists."
else
  # Generate the certificate if it doesn't exist
  if [ ! -f "$CERT_FILE" ]; then
    cecho info "Generating self-signed certificate at $CERT_FILE (valid 5 years)..."
    openssl req -new -x509 -days 1825 -nodes -out "$CERT_FILE" -keyout "$CERT_FILE" \
      -subj "/C=EU/ST=${REGION}/L=${CITY}/O=MyOrg/OU=IT/CN=${SERVER_IP}"
    cecho success "Certificate generated successfully."
  else
    cecho success "Certificate $CERT_FILE already exists. Skipping generation."
  fi
fi


# Handle various progression states
if [ "${PROGRESSION}" == "INSTALL_SERVER" ]; then
    start_vnc "Installing"

    cecho info "Files that are in the mount:"
    ls -la /fs

    print_message "Starting the installation process. Please do NOT stop the server!\n\nTo monitor progress, visit: https://${SERVER_IP}:${VNC_PORT}"

    IMG_FILE=$(find /fs -maxdepth 1 -type f -iname "*.img" | head -n 1)
    INSTALL_PATH="/fs/fs_img"

    if [ -n "${IMG_FILE}" ]; then
        cecho info "Found image file: ${IMG_FILE}"

        # If already extracted, reuse it
        if [ -d "${INSTALL_PATH}" ] && [ -f "${INSTALL_PATH}/Setup.exe" ]; then
            cecho info "Detected existing extracted folder — skipping extraction."
        else
            cecho info "Extracting image file to ${INSTALL_PATH}..."
            rm -rf "${INSTALL_PATH}"
            mkdir -p "${INSTALL_PATH}"
            7z x "${IMG_FILE}" -o"${INSTALL_PATH}" >/dev/null 2>&1

            if [ $? -ne 0 ]; then
                cecho error "Extraction failed for ${IMG_FILE}."
                exit 1
            fi

            if [ ! -f "${INSTALL_PATH}/Setup.exe" ]; then
                cecho error "Setup.exe not found after extraction!"
                exit 1
            fi

            cecho success "Extraction complete. Found Setup.exe."
        fi

        STARTCMD="wine ${INSTALL_PATH}/Setup.exe /SILENT /SP- /DIR=\"Z:\home\container\Farming Simulator 20${FS_VERSION}\""
    elif [ -e "/fs/Setup.exe" ]; then
        cecho info "Found an already extracted .img in the mount, using that"
        STARTCMD="wine /fs/Setup.exe /SILENT /SP- /DIR=\"Z:\home\container\Farming Simulator 20${FS_VERSION}\""
    else
        cecho info "No .img file found. Using default installer."
        STARTCMD="wine /fs/FarmingSimulator20${FS_VERSION}.exe /SILENT /SP- /DIR=\"Z:\home\container\Farming Simulator 20${FS_VERSION}\""
    fi
elif [ "${PROGRESSION}" == "INSTALL_DLC" ] && [ -n "${DLC_EXE}" ]; then
    /usr/bin/vncserver -geometry 1920x1080 -rfbport "5900" -rfbauth /home/container/.vnc/passwd -localhost
    /usr/bin/websockify -D --web /usr/share/novnc "${VNC_PORT}" localhost:5900
    
    STARTCMD="wine /home/container/dlc_install/${DLC_EXE}"

elif [ "${PROGRESSION}" == "ACTIVATE" ] && [ -f "/home/container/.vnc/passwd" ]; then
    # Activate VNC and set the start command for the game
    start_vnc "Activate / Update"

    print_message "Starting the activation process. Please connect to the VNC server to enter your license key.\n\nConnect here: https://${SERVER_IP}:${VNC_PORT}"
    STARTCMD="wine /home/container/Farming\ Simulator\ 20${FS_VERSION}/FarmingSimulator20${FS_VERSION}.exe"

elif [ "${PROGRESSION}" == "RUN" ] && [ -f "/home/container/.vnc/passwd" ]; then
    start_vnc "Farming Simulator 22/25 Server"

    print_message "You can now configure the server on the dashboard.\n\nConnect to the VNC server here: https://${SERVER_IP}:${VNC_PORT}"
    STARTCMD=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')
else
    # Unrecognized progression state
    cecho error "Error: The PROGRESSION variable is set to an unknown value."
    STARTCMD="sleep 50"
    exit 1

fi

cecho bold "Starting with command: ${STARTCMD}"
eval "${STARTCMD}"

# Keep session alive if needed
if [[ "$PROGRESSION" == "ACTIVATE" || "$PROGRESSION" == "INSTALL_DLC" ]]; then
    tail -f /dev/null
fi
