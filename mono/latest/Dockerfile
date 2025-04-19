FROM        --platform=$TARGETOS/$TARGETARCH ghcr.io/parkervcp/yolks:debian

LABEL       author="QuintenQVD" maintainer="josdekurk@gmail.com"

RUN         apt update \
            && apt -y upgrade
RUN         apt install -y fontconfig dirmngr ca-certificates gnupg
RUN         gpg --homedir /tmp --no-default-keyring --keyring /usr/share/keyrings/mono-official-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
RUN         echo "deb [signed-by=/usr/share/keyrings/mono-official-archive-keyring.gpg] https://download.mono-project.com/repo/debian stable-buster main" | tee /etc/apt/sources.list.d/mono-official-stable.list
RUN         apt update
RUN         apt install -y mono-complete

# Only install the needed steamcmd packages on the AMD64 build
RUN         if [ "$(uname -m)" = "x86_64" ]; then \
                dpkg --add-architecture i386 && \
                apt update && \
                apt -y install lib32gcc-s1 libsdl2-2.0-0:i386; \
            fi


USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
CMD         [ "/bin/bash", "/entrypoint.sh" ]