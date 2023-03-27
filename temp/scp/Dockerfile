FROM  --platform=linux/arm64 quintenqvd/pterodactyl_images:installer:steamcmd

RUN         apt update \
            && apt -y upgrade
RUN         apt install -y fontconfig dirmngr iproute2 curl ca-certificates openssl git tar sqlite3 libc6       
RUN         apt update
RUN         apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
RUN         sh -c 'echo "deb https://download.mono-project.com/repo/debian stable-buster main" > /etc/apt/sources.list.d/mono-official-stable.list'
RUN         apt update
RUN         apt install -y mono-complete lib32gcc-s1-amd64-cross


RUN         useradd -d /home/container -m container
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
CMD         [ "/bin/bash", "/entrypoint.sh" ]
