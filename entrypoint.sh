#!/bin/bash
set -euo pipefail

cd /home/container

# Make internal Docker IP address available to processes.
export INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')

# Safely replace Startup Variables
MODIFIED_STARTUP=$(envsubst <<< "${STARTUP}")

# Print the command to be executed (for logging/debugging purposes)
echo ":/home/container$ ${MODIFIED_STARTUP}"

# Execute the startup command
exec ${MODIFIED_STARTUP}
