#!/bin/bash

while [ ! -f /var/lib/cloud/instance/boot-finished ]; do
 echo -e "Cloud-init still running..."
 sleep 1
done