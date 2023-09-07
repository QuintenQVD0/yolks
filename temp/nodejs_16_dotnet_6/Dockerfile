FROM        --platform=$TARGETOS/$TARGETARCH node:16-bullseye-slim

LABEL       author="Michael Parker" maintainer="parker@pterodactyl.io"

RUN         apt update \
            && apt -y install ffmpeg iproute2 git sqlite3 libsqlite3-dev python3 python3-dev ca-certificates dnsutils tzdata zip tar curl build-essential libtool apt-transport-https lsb-release \
            && useradd -m -d /home/container container

RUN         npm install npm@9.8.1 -g

RUN         apt update \
			&& apt -y install curl tar bzip2 file wget\
            && wget https://dot.net/v1/dotnet-install.sh \
			&& mkdir -p /usr/share \
            && chmod +x dotnet-install.sh \
			&& ./dotnet-install.sh -i /usr/share -v 6.0.405 \
			&& ln -s /usr/share/dotnet /usr/bin/dotnet \
			&& apt -y install ffmpeg wget iproute2 git ca-certificates tzdata zip tar libtool \
			&& apt -y install libc6 libgcc1 libgssapi-krb5-2 libicu67 libssl1.1 libstdc++6 zlib1g \
			&& apt update -y \
			&& dotnet --info 



USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY  ./entrypoint.sh /entrypoint.sh
CMD   [ "/bin/bash", "/entrypoint.sh" ]

