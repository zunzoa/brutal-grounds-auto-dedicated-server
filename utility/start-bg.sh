#!/bin/bash

echo -n "Server Name (name of the server in server list): "
read SERVER_NAME

echo -n "Host Name (name of who hosts the server): "
read HOST_NAME

echo -n "Admin ID (Steam 64 bit ID in decimal format): "
read ADMIN_ID

echo -n "Server Password (server access password or just hit enter for no password): "
read SERVER_PASSWORD

/opt/brutal_grounds_ds/BrutalGroundsServer.sh -log -nullrhi -SteamServerName=$SERVER_NAME -AdminId=$ADMIN_ID -HostName=$HOST_NAME -Password=$SERVER_PASSWORD