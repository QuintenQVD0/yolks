# FROM --platform=linux/arm64 ubuntu:20.04 as builder

# ENV   DEBIAN_FRONTEND noninteractive

# RUN 	apt update \
# 		&& apt install -y git curl cmake ninja-build pkg-config clang llvm lld libsdl2-dev libepoxy-dev libssl-dev g++-x86-64-linux-gnu python3 python3-clang libstdc++-10-dev-arm64-cross squashfs-tools libc-bin

# RUN     mkdir -p /usr/src && cd /usr/src \
#         && git clone --recurse-submodules https://github.com/FEX-Emu/FEX.git \
#         && cd FEX && mkdir Build && cd Build \
#         &&  CC=clang CXX=clang++ cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DENABLE_LTO=True -DENABLE_LLD=True -DBUILD_TESTS=False -DENABLE_ASSERTIONS=False -G Ninja .. \
#         && ninja \
#         && ls -la /usr/src/FEX/Build/Bin

#FROM --platform=linux/arm64 ubuntu:22.04 as builder
#ENV   DEBIAN_FRONTEND noninteractive
#
#RUN 	apt update \
#		&& apt install -y curl wget build-essential tar
#
#RUN 	cd /usr/src/ && wget https://github.com/openssl/openssl/releases/download/OpenSSL_1_1_1t/openssl-1.1.1t.tar.gz \
#  		&& tar xvf openssl-1.1.1t.tar.gz \
#		&& cd openssl-1.1.1t/ \
#  		&& ./config \
#		&& make

FROM --platform=linux/arm64 ubuntu:22.04

ENV   DEBIAN_FRONTEND noninteractive

## add container user
RUN   useradd -m -d /home/container -s /bin/bash container

#COPY --from=builder /usr/src/FEX/Build/Bin /usr/local/bin/

RUN     apt update && apt -y install software-properties-common \
        && add-apt-repository ppa:fex-emu/fex \
        && apt update \
        && apt -y install fex-emu-armv8.2 fex-emu-binfmt32 fex-emu-binfmt64

RUN		apt update \ 
        && apt -y install curl git iproute2 libssl-dev squashfuse fuse squashfs-tools tzdata tar wget zip build-essential unzip \
		&& wget http://launchpadlibrarian.net/668077130/libssl1.1_1.1.1f-1ubuntu2.19_arm64.deb \
  		&& dpkg -i http://launchpadlibrarian.net/668077130/libssl1.1_1.1.1f-1ubuntu2.19_arm64.deb \
        && ls -la /usr/local/bin

#COPY --from=builder /usr/src/openssl-1.1.1t /usr/src/
#RUN		ls -la /usr/src

WORKDIR /home/container

COPY  ./entrypoint.sh /entrypoint.sh
CMD   [ "/bin/bash", "/entrypoint.sh" ]
