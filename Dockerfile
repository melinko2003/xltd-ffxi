# syntax=docker/dockerfile:1
FROM ubuntu:24.04 AS build
ENV DEBIAN_FRONTEND=noninteractive

# docker buildx build --platform=linux/amd64,linux/arm64 -t xltd-ffxi:latest -t xltd-ffxi:$(git log -1 --pretty=format:"%h") -f Dockerfile.mini .

RUN apt update && apt clean all
RUN apt install -y software-properties-common curl git python3.12-dev cmake libmariadb-dev-compat libluajit-5.1-dev libzmq3-dev zlib1g-dev libssl-dev binutils-dev gcc-14 g++-14 libgcc-14-dev && apt clean all
RUN git clone --recursive https://github.com/LandSandBoat/server.git /server
# Install https://github.com/AdamGagorik/ffxiahbot
RUN echo "ffxiahbot" >> /server/tools/requirements.txt \
&& mkdir -p server/build \
&& mkdir -p /opt/$(uname -p) \
&& cd /server \
&& export CC=/usr/bin/gcc-14 \
&& export CXX=/usr/bin/g++-14 \
&& sed -i 's/if ((c >= 0 && c <= 0x20) || c >= 0x7F)/if (!std::isprint(static_cast<unsigned char>(c)))/' src/map/lua/luautils.cpp \
&& if [ $(uname -p) = "x86_64" ]; CFLAGS=-m64 CXXFLAGS=-m64 LDFLAGS=-m64 cmake -S . -B build ; fi \
&& if [ $(uname -p) = "aarch64"  ]; cmake -S . -B build ; fi \
&& cmake --build build -j2 \
&& rm -rf /server/build \
&& mv /server/tools/requirements.txt /opt/ \
&& mv xi_* /opt/$(uname -p)/
RUN cd /server && echo $(git log -1 --pretty=format:"%h") > /opt/VERSION

FROM ubuntu:24.04
COPY --from=build /opt /opt
ADD contrib/settings /opt/settings
ADD contrib/containers/update_then_launch.sh /opt/update_then_launch.sh
RUN chmod +x /opt/update_then_launch.sh /opt/$(uname -p)/*

CMD ["/opt/update_then_launch.sh", "$(cat /opt/VERSION)"]