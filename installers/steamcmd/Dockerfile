# FROM debian:bullseye-slim as build-box64

# RUN apt-get update && \
#     apt-get install --yes --no-install-recommends git python3 build-essential cmake ca-certificates && \
#     apt-get install --yes --no-install-recommends gcc-arm-linux-gnueabihf libc6-dev-armhf-cross libc6

# RUN git clone https://github.com/ptitSeb/box64.git; mkdir /box64/build

# WORKDIR /box64/build
# RUN cmake .. -DRPI4ARM64=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo && \
#     make -j$(nproc) && \
#     make install DESTDIR=/tmp/install
	
# FROM debian:bullseye-slim as build-box86

# RUN dpkg --add-architecture armhf && \
#     apt-get update && \
#     apt-get install --yes --no-install-recommends git  python3 build-essential cmake ca-certificates && \
#     apt-get install --yes --no-install-recommends gcc-arm-linux-gnueabihf libc6-dev-armhf-cross libc6:armhf libstdc++6:armhf && \
#     apt-get clean && \
#     rm -rf /var/lib/apt/lists/{apt,dpkg,cache,log} /tmp/* /var/tmp/*

# RUN git clone https://github.com/ptitSeb/box86.git; mkdir /box86/build

# WORKDIR /box86/build
# RUN cmake .. -DRPI4ARM64=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo && \
#     make -j$(nproc) && \
#     make install DESTDIR=/tmp/install


FROM        --platform=$TARGETOS/$TARGETARCH debian:bullseye-slim

ENV     DEBIAN_FRONTEND noninteractive

#COPY --from=build-box86 /tmp/install /
#COPY --from=build-box64 /tmp/install /

##Install box64
RUN         wget https://ryanfortner.github.io/box64-debs/box64.list -O /etc/apt/sources.list.d/box64.list \
            && wget -O- https://ryanfortner.github.io/box64-debs/KEY.gpg | gpg --dearmor | tee /usr/share/keyrings/box64-debs-archive-keyring.gpg \
            && apt update && apt install box64 -y

RUN		dpkg --add-architecture armhf

RUN		apt update \
        && apt install -y wget gnupg2 \
		&& wget https://itai-nelken.github.io/weekly-box86-debs/debian/box86.list -O /etc/apt/sources.list.d/box86.list \
		&& wget -qO- https://itai-nelken.github.io/weekly-box86-debs/debian/KEY.gpg | apt-key add - \
		&& apt update && apt install box86:armhf libc6 libc6:armhf -y

        
RUN dpkg --add-architecture armhf && \
    apt-get update && \
    apt-get install --yes --no-install-recommends libc6:armhf libstdc++6:armhf gcc-arm-linux-gnueabihf libc6:armhf libncurses5:armhf libsdl2-image-2.0-0:armhf && \
    apt-get -y autoremove && \
    apt-get clean autoclean && \
    rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists
			
ENV         DEBIAN_FRONTEND=noninteractive

RUN         dpkg --add-architecture armhf \
				&& apt update \
				&& apt upgrade -y \
				&& apt -y --no-install-recommends install ca-certificates curl git wget

RUN         apt install -y libc6:armhf libsdl2-2.0-0 libsdl2-2.0-0:armhf libncurses5:armhf libsdl2*:armhf libopenal*:armhf libpng*:armhf libfontconfig*:armhf libXcomposite*:armhf libbz2-dev:armhf libXtst*:armhf 

			
ENV     STEAMOS=1
ENV     STEAM_RUNTIME=1
ENV     DBUS_FATAL_WARNINGS=0