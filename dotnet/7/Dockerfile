FROM        --platform=$TARGETOS/$TARGETARCH debian:bullseye-slim

LABEL       author="QuintenQVD" maintainer="josdekurk@gmail.com"

RUN         apt update \
			&& apt -y install curl tar bzip2 file wget \
            && wget https://dot.net/v1/dotnet-install.sh \
			&& mkdir -p /usr/share \
            && chmod +x dotnet-install.sh \
			&& D_V="$(curl -sSL https://dotnet.microsoft.com/en-us/download/dotnet/7.0 | grep -i  '<h3 id="sdk-7.*">SDK 7.*.*</h3>'  | head -1 | awk -F\" '{print $3}' | awk '{print $2;}' | sed 's/<\/h3>//g')" \
			&& echo $D_V \			
			&& ./dotnet-install.sh -i /usr/share -v $D_V \
			&& ln -s /usr/share/dotnet /usr/bin/dotnet \
			&& apt -y install ffmpeg wget iproute2 git ca-certificates tzdata zip tar libtool \
			&& apt -y install libc6 libgcc1 libgssapi-krb5-2 libicu67 libssl1.1 libstdc++6 zlib1g tini \
			&& apt update -y \
			&& dotnet --version \
            && useradd -m -d /home/container container

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

STOPSIGNAL SIGINT

COPY        --chown=container:container ./../entrypoint.sh /entrypoint.sh
RUN         chmod +x /entrypoint.sh
ENTRYPOINT    ["/usr/bin/tini", "-g", "--"]
CMD         ["/entrypoint.sh"]