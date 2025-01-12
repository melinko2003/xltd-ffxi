FROM ubuntu:24.04

# Avoid any UI since we don't have one
ENV DEBIAN_FRONTEND=noninteractive

# Some dependencies are pulled from deadsnakes
RUN apt clean all && apt update -y && apt install -y \
wget curl jq software-properties-common \
# Need mariadb as per-requirements, doesn't come pre-packaged I don't think
libmariadb3 libmariadb-dev mariadb-server \
# Python 3.12
python3.12-venv python3-pip \
# Update and install all requirements as well as some useful tools such as net-tools and nano
net-tools nano git cmake make libluajit-5.1-dev libzmq3-dev libssl-dev zlib1g-dev luarocks binutils-dev \
&& apt clean all \
# Clone Repo to /server
&& git clone --recursive https://github.com/LandSandBoat/server.git /server \
# Install https://github.com/AdamGagorik/ffxiahbot
&& echo "ffxiahbot" >> /server/tools/requirements.txt \
&& python3.12 -m venv /server/.auctioneer \
&& /server/.auctioneer/bin/python3 -m pip install --upgrade -r /server/tools/requirements.txt \
# Configure and build
&& mkdir docker_build && cd docker_build && cmake .. && make -j $(nproc)  && cd .. && rm -r /server/docker_build \
# Ensure we can run the db update & startup script
&& chmod +x ./tools/dbtool.py 
# Adding + Chmod'ing your launch script
ADD contrib/containers/update_db_then_launch.sh /server/update_db_then_launch.sh
RUN chmod +x /server/update_db_then_launch.sh
# Adding our Contrib Settings and FFXIAHbots configuration
ADD contrib/settings /server/settings

# Startup the server when the container starts
ENTRYPOINT ./update_db_then_launch.sh