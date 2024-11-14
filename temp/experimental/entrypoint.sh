#!/bin/bash
cd /home/container

# Information output
echo "Running on Debian $(cat /etc/debian_version)"
echo "Current timezone: $(cat /etc/timezone)"
wine --version
export DISPLAY=":1"

# Make internal Docker IP address available to processes.
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP


if [ -f "/home/container/.vnc/passwd" ]; then
    echo "Needed VNC files already there"
else 
    mkdir -p /home/container/.vnc && cd /home/container/.vnc
    wget https://raw.githubusercontent.com/QuintenQVD0/yolks/refs/heads/master/temp/experimental/xstartup
    touch /home/container/.vnc/passwd /home/container/.Xauthority
    chmod 600 /home/container/.vnc/passwd
    /bin/echo -e "export DISPLAY=${DISPLAY}"  >> /home/container/.vnc/xstartup
    /bin/echo -e "[ -r /home/container/.Xresources ] && xrdb /home/container/.Xresources\nxsetroot -solid grey"  >> /home/container/.vnc/xstartup
fi

cd /home/container

# kill old vnc session
[ -z "${DISPLAY}" ] || /usr/bin/vncserver -kill ${DISPLAY}
find /tmp -maxdepth 1 -name ".X*-lock" -type f -exec rm -f {} \;
if [[ -d /tmp/.X11-unix ]]; then
    find /tmp/.X11-unix -maxdepth 1 -name 'X*' -type s -exec rm -f {} \;
fi

# set new vnc password to ARG
if [ -f /home/container/.vnc/passwd ]; then
    echo "${VNC_PASS}" | vncpasswd -f > /home/container/.vnc/passwd
fi

echo "First launch will throw some errors. Ignore them"

mkdir -p $WINEPREFIX

# List and install other packages
for trick in $WINETRICKS_RUN; do
        echo "Installing $trick"
        winetricks -q $trick
done

# Replace Startup Variables
MODIFIED_STARTUP=$(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo ":/home/container$ ${MODIFIED_STARTUP}"

# start vnc server
/usr/bin/vncserver -geometry 1920x1080 -rfbport ${VNC_PORT} -rfbauth /home/container/.vnc/passwd 

