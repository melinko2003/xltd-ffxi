apt update -y
apt install -y python3.12-venv python3.12-dev software-properties-common cmake mariadb-server mariadb-client libmariadb-dev-compat \
 libluajit-5.1-dev libzmq3-dev zlib1g-dev libssl-dev luarocks binutils-dev libgcc-14-dev
git clone --recursive https://github.com/LandSandBoat/server.git /server 
cd /server 
git checkout $1 
mv /opt/$(uname -p)/xi_* /server/
mv /opt/settings /server
python3.12 -m venv /server/.auctioneer \
/server/.auctioneer/bin/python3 -m pip install --no-cache-dir --upgrade -r /opt/requirements.txt

while ! mysql --host=$XI_NETWORK_SQL_HOST --port=$XI_NETWORK_SQL_PORT --user=$XI_NETWORK_SQL_LOGIN --password=$XI_NETWORK_SQL_PASSWORD $XI_NETWORK_SQL_DATABASE -e "SELECT 1 FROM zone_weather LIMIT 1"; do
    sleep 5
done
sleep 5

# Update databse
echo "updating database"
/server/.auctioneer/bin/python3 /server/tools/dbtool.py update
sleep 5

# Update zone_settings to host IP
mysql --host=$XI_NETWORK_SQL_HOST --port=$XI_NETWORK_SQL_PORT --user=$XI_NETWORK_SQL_LOGIN --password=$XI_NETWORK_SQL_PASSWORD $XI_NETWORK_SQL_DATABASE -e "UPDATE zone_settings set zoneip='$XI_NETWORK_ZONE_IP'"

# Start servers
echo "starting xi_connect"
nohup ./xi_connect &
sleep 5

echo "starting xi_search"
nohup ./xi_search &

sleep 5
echo "starting xi_map"
./xi_map

sleep 5
echo "starting xi_world"
./xi_world

sleep 5
echo "starting up the Auctioneer."
/server/.auctioneer/bin/python3 -m ffxiahbot broker --config /server/settings/config.yaml --inp-csv /server/settings/items.csv --buy-items --sell-item