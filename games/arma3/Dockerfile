FROM 		--platform=$TARGETOS/$TARGETARCH quintenqvd/pterodactyl_images:installer_steamcmd

## Update base packages and install dependencies
ENV         DEBIAN_FRONTEND=noninteractive
RUN         dpkg --add-architecture armhf \
            && apt-get update \
            && apt-get upgrade -y \
            && apt-get install -y \
                curl \
                tzdata \
                locales \
                iproute2 \
                gettext-base \
                ca-certificates \
                libssl-dev \
                libsdl2-2.0-0 \
                libsdl2-2.0-0:armhf \
                numactl \
                libstdc++6:armhf \
				net-tools \
                libnss-wrapper \
                libnss-wrapper:armhf \
                libtbbmalloc2 \
                libtbbmalloc2:armhf

## Configure locale
RUN         update-locale lang=en_US.UTF-8 \
            && dpkg-reconfigure --frontend noninteractive locales

## Prepare NSS Wrapper for the entrypoint as a workaround for Arma 3 requiring a valid UID
ENV         NSS_WRAPPER_PASSWD=/tmp/passwd NSS_WRAPPER_GROUP=/tmp/group
RUN         touch ${NSS_WRAPPER_PASSWD} ${NSS_WRAPPER_GROUP} \
            && chgrp 0 ${NSS_WRAPPER_PASSWD} ${NSS_WRAPPER_GROUP} \
            && chmod g+rw ${NSS_WRAPPER_PASSWD} ${NSS_WRAPPER_GROUP}
ADD         passwd.template /passwd.template

## Setup user and working directory
RUN         useradd -m -d /home/container -s /bin/bash container
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

## Copy over and execute entrypoint.sh
COPY        ./entrypoint.sh /entrypoint.sh
CMD         [ "/bin/bash", "/entrypoint.sh" ]
