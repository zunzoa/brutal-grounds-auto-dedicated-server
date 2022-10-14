#!/bin/bash

echo -n "Enter your Steam username: "
read STEAM_USER

echo "Running SteamCMD to download Brutal Grounds Dedicated Server, when prompt enter your Steam password and optionally, if you have it enabled, Steam Guard code"
/opt/steam/steamcmd.sh +force_install_dir /opt/brutal_grounds_ds +login $STEAM_USER +app_update 1123110 +quit

echo "Brutal Grounds Dedicated Server installed!"