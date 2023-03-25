#!/bin/bash
cd /home/container

# Make internal Docker IP address available to processes.
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Print Node.js Version
printf "\033[1m\033[33mcontainer@pterodactyl~ \033[0mNode -v\n"
node -v

printf "\033[1m\033[33mcontainer@pterodactyl~ \033[0mdotnet --version\n"
dotnet --version

export DOTNET_ROOT=/usr/share/

# Replace Startup Variables
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
eval ${MODIFIED_STARTUP}
