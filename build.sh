#!/bin/bash
set -e

# Generate an admin password
ADMIN_PASSWORD=$(</dev/urandom tr -dc '1234567890abcdefhijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ' | head -c18)
export ADMIN_PASSWORD

# Generate a public/private key pair for ssh
rm -f ssh-key ssh-key.pub
ssh-keygen -f ssh-key -q -N ""

packer build win-server.json

# Output administrator password
echo "Administrator password was set to: ${ADMIN_PASSWORD}"
