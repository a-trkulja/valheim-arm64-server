#!/bin/bash

# update server's data
/home/steam/steamcmd/steamcmd.sh \
        +force_install_dir /home/steam/valheim/server/ \
        +login anonymous \
        +app_update 896660 \
        +exit

#Copy 64bit steamclient, since it keeps using 32bit
cp /home/steam/steamcmd/linux64/steamclient.so /home/steam/valheim/server/

# Apply default values for server if not set
VALHEIM_SERVER_NAME=${VALHEIM_SERVER_NAME:-My\ server}
VALHEIM_SERVER_PUBLIC=${VALHEIM_SERVER_PUBLIC:0}
VALHEIM_SERVER_WORLD=${VALHEIM_SERVER_WORLD:-Dedicated}
VALHEIM_SERVER_PASSWORD=${VALHEIM_SERVER_PASSWORD:-secret}

# Launch server
export templdpath=$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=./linux64:$LD_LIBRARY_PATH
export SteamAppId=892970

echo "Starting server PRESS CTRL-C to exit"

# NOTE: Minimum password length is 5 characters & Password cant be in the server name.
# NOTE: You need to make sure the ports 2456-2458 is being forwarded to your server through your local router & firewall.
/home/steam/valheim/server/valheim_server.x86_64 -nographics -batchmode -port 2456 -public ${VALHEIM_SERVER_PUBLIC} -name "${VALHEIM_SERVER_NAME}" -world "${VALHEIM_SERVER_WORLD}" -password "${VALHEIM_SERVER_PASSWORD}" -savedir "/home/steam/valheim/data" $SERVER_ARGS

# Trap container stop for graceful exit
trap "kill -SIGINT $!;" SIGTERM

# Wait for server to exit
while wait $!; [ $? != 0 ]; do true; done

export LD_LIBRARY_PATH=$templdpath