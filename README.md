# xltd-ffxi
Ephemeral LSB FFXI Private Server builds. Idea is to Make a server we can "rotate" in/out, with a db dump/refresh included. Intended platforms are Raspberry Pis, and Intel N150 systems.  
  
My use case:  
I'm a traveling IT guy. It would be nice to have an all-in-one system that includes, game, client, backup of current dats, HD Dats, and patches and enough to get me going on the road.  
  
## Points of improvement 
* Write a dynamic IP resetting script so it sets the ip the system on start up, re-checks, sets it, notifies the server, and then restarts it. 

## Assumption
DB and config files are most important and aren't disposable, but everything else seems that way.  
  
Infrastructure:  
1) Spin up Host ( container, server, instance )
    1) Install package list
        1) Fedora 41
        2) Almalinux 9
        3) Ubuntu 24.04
2) Spin up Mysql ( package, manual install, or container ) 
  
General process to follow:
1) git clone [LSB/server:base](https://github.com/LandSandBoat/server) `/opt/server/`
```bash
$ git clone https://github.com/LandSandBoat/server /opt/server
```
2) file moves from `/opt/` to `/opt/server` OR obtain them from the site.
```bash
$ cp /opt/
```
3) insert git version into the `settings/main.lua`
4) Import via `mysql -u root -proot xidb < /opt/sql/ffxidb-init.sql` backup OR 
5) Create New Db via `/opt/server/.auctioneer/bin/python3 /opt/server/tools/dbtool.py setup ffxidb` 
6) Perform any updates to the sql via `/opt/server/.auctioneer/bin/python3 /opt/server/tools/dbtool.py update full`
7) env IP=$(method_to_get_ip)
8) Update Zoneip via `mysql -u root -proot xidb -e "UPDATE zone_settings SET zoneip = '$IP';"` and a custom script.
9) Perform a Backup NOW() ( See Below )  
10) Start `xi_*.service`(s)
    1) `systemctl start xi_world.service` or `/opt/server/xi_world --log /var/log/ffxi-world-server.log &`
    2) `systemctl start xi_search.service` or `/opt/server/xi_search --log /var/log/ffxi-search-server.log &`
    3) `systemctl start xi_map.service` or `/opt/server/xi_map --log /var/log/ffxi-map-server.log &`
    4) `systemctl start xi_connect.service` or `/opt/server/xi_connect --log /var/log/ffxi-connect-server.log &`
    5) `systemctl start xi_auctioneer.service` or 
    `/opt/server/.auctioneer/bin/python3 -m ffxiahbot broker --config /opt/server/settings/config.yaml --inp-csv /opt/server/settings/items.csv --buy-items --sell-items >> /var/log/ffxi-auctioneer-server.log &`
11) Scheduled_Backups Every: `30m` ( Configurable, See Below ) 

Backups: 
1) Perform a backup NOW()
    1) Perform backup via `/opt/server/.auctioneer/bin/python3 /opt/server/tools/dbtool.py backup` ( 21M to start )
    2) Update init file: `mv /opt/server/sql/backups/xidb-*.sql /opt/sql/ffxidb-init.sql` ( Indicates the Start of Play Status )  
Scheduled_Backups:
1) Perform Backup every: `30m` ( By Default)
    1) Read & Set `every`, if overridden.  
    2) Perform a backup NOW()

Usage:
0) mkdir contrib/backups
1) docker -itd xltd-ffxi:latest -v contrib/backups:/opt/sql/ -v contrib/settings:/opt/server/settings 

## Targeted HW platforms
I'm limiting my testing to small stuff I can throw in a backpack. 
* [ FAILS ] Raspberry Pi 3b+
* [ ] Raspberry Pi 4b 8Gb ( Arm64 )
* [ ] Macbook Pros ( x86_64 & M1-4 ) running Docker to provide Linux
* [ Works ] x86_64 Laptops 
* [ Works ] Intel N150 systems. 

## Targeted OS platforms
I'm going to get a little more wilder here
* [ Works ] Ubuntu 24.04 Arm64 / x86_64 
* [ Works ] Fedora 41 Arm64 / x86_64 
* [ Works ] Almalinux 9 Arm64 / x86_64 

## Works in Progress
* In Repo Version Management of LSB
* OS Refresh Cycle
* Daily rebuilds
* Document Fedora Build Arm64 / x86_64 
* Document Almalinux Build Arm64 / x86_64 
* Document Ubuntu 24.04 Build Arm64 / x86_64 
* Container Builds Arm64 / x86_64 
* Rpm builds Arm64 / x86_64 
* Deb Builds Arm64 / x86_64 
