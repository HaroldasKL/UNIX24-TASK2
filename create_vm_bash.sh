#!/bin/bash

wget -q -O- https://downloads.opennebula.org/repo/repo.key | sudo apt-key add -
echo "deb https://downloads.opennebula.org/repo/5.6/Ubuntu/18.04 stable opennebula" | sudo tee /etc/apt/sources.list.d/opennebula.list
sudo apt update
sudo apt-get install -y opennebula-tools
# echo -e | ssh-keygen -P "haroldas"
# eval $(ssh-agent -s)

API_URL="https://grid5.mif.vu.lt/cloud3/RPC2"
API_USERNAME="hukl8291"
API_PASSWORD="Pakritusiospupos2."
TEMPLATE_NAME="Copy of IT Unix 24 debian-12"
DISK_SIZE="20G"
MEMORY="2048"
VCPU="1"
CPU="0.4"
VM_NAME="UNIX24-TASK2-TESTING"

TEMPLATE_ID=$(onetemplate list -l | grep "$TEMPLATE_NAME" | awk '{print $1}')