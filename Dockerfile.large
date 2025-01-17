# syntax=docker/dockerfile:1
FROM ubuntu:24.04 as build
ENV DEBIAN_FRONTEND=noninteractive \
CXX=/usr/bin/g++- \
CC=/usr/bin/gcc-14

RUN apt update \
&& apt install -y git curl software-properties-common cmake libmariadb-dev-compat libluajit-5.1-dev libzmq3-dev zlib1g-dev libssl-dev binutils-dev gcc-14 g++-14 
RUN git clone --recursive https://github.com/LandSandBoat/server.git /server
# Install https://github.com/AdamGagorik/ffxiahbot
RUN echo "ffxiahbot" >> /server/tools/requirements.txt \
&& cd /server \
&& mkdir -p build 
RUN CFLAGS=-m64 CXXFLAGS=-m64 LDFLAGS=-m64 cmake -S . -B build \
&& cmake --build build -j2 \
&& rm -rf /server/build 
RUN chmod +x /server/tools/dbtool.py 
ADD contrib/containers/update_db_then_launch.sh /server/update_db_then_launch.sh
RUN chmod +x /server/tools/dbtool.py /server/update_db_then_launch.sh
ADD contrib/settings /server/settings

FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
COPY --from=build /server /server

RUN apt update \
&& apt install -y python3.12-venv software-properties-common cmake mariadb-client libmariadb-dev-compat libluajit-5.1-dev libzmq3-dev zlib1g-dev libssl-dev luarocks binutils-dev \
&& python3.12 -m venv /server/.auctioneer \
&& /server/.auctioneer/bin/python3 -m pip install --no-cache-dir --upgrade -r /server/tools/requirements.txt 

# # Avoid any UI since we don't have one
# ENV DEBIAN_FRONTEND=noninteractive

# RUN apt update && apt install -y \
# curl jq software-properties-common \
# # Need mariadb as per-requirements, doesn't come pre-packaged I don't think
# libmariadb3 libmariadb-dev mariadb-server \
# # Python 3.12
# python3.12-venv \
# # Update and install all requirements as well as some useful tools such as net-tools and nano
# net-tools nano git cmake make libluajit-5.1-dev libzmq3-dev libssl-dev zlib1g-dev luarocks binutils-dev \
# && apt clean all \
# # Clone Repo to /server
# && git clone --recursive https://github.com/LandSandBoat/server.git /server \
# # Install https://github.com/AdamGagorik/ffxiahbot
# && echo "ffxiahbot" >> /server/tools/requirements.txt \
# && python3.12 -m venv /server/.auctioneer \
# && /server/.auctioneer/bin/python3 -m pip install --no-cache-dir --upgrade -r /server/tools/requirements.txt \
# # Configure and build
# && cd /server && mkdir docker_build && cd docker_build && cmake .. && make -j $(nproc)  && cd .. && rm -r /server/docker_build \
# # Ensure we can run the db update & startup script
# && chmod +x /server/tools/dbtool.py 
# # Adding + Chmod'ing your launch script
# ADD contrib/containers/update_db_then_launch.sh /server/update_db_then_launch.sh
# RUN chmod +x /server/update_db_then_launch.sh
# # Adding our Contrib Settings and FFXIAHbots configuration
# ADD contrib/settings /server/settings

# # Startup the server when the container starts
# ENTRYPOINT ["/server/update_db_then_launch.sh"]