#!/bin/bash

close_connection() {
  pkill -3 autossh
  exit 0
}

trap close_connection TERM

autossh -M 0 -N -o "PubkeyAuthentication=yes" -o "PasswordAuthentication=no" -o "StrictHostKeyChecking=no" -o "ServerAliveInterval=5" -o "ServerAliveCountMax 3" -o ExitOnForwardFailure=yes -t -t -i /config/.ssh/${SSH_KEY_NAME:-id_rsa} ${PROXY_SSH_USER:-dev}@${PROXY_HOST} -p ${PROXY_SSH_PORT:-22} $@
