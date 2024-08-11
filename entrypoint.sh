#!/bin/bash
set -euo pipefail

cd /home/container

# Make internal Docker IP address available to processes.
export INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
echo "I'm a Cat :3 Thank you for using Hosting mit Herz"
# Safely replace Startup Variables
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo -e ":/home/container$ ${MODIFIED_STARTUP}"

# Execute the startup command
exec ${MODIFIED_STARTUP}
