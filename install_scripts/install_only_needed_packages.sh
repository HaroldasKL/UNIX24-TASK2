#!/bin/bash

echo "Installing needed packages"
sudo apt update
sudo apt install bzip2 -y
# sudo apt install libexpat1-dev -y     # INSTALLED FROM SOURCE (EXPAT needed for APR-UTIL)
# sudo apt install libapr1-dev -y       # INSTALLED FROM SOURCE (APR)
# sudo apt install libaprutil1-dev -y   # INSTALLED FROM SOURCE (APR_UTIL)
sudo apt install gcc -y
sudo apt install g++ -y
sudo apt install libpcre3 -y
sudo apt install libpcre3-dev -y
sudo apt install make -y
sudo apt install libxml2-dev -y
sudo apt install libsqlite3-dev -y
sudo apt install jq -y
sudo apt install cmake -y
sudo apt install build-essential -y
sudo apt install libncurses5-dev -y
sudo apt install gnutls-dev -y
sudo apt install pkg-config -y
sudo apt install zlib1g-dev -y
echo "Finished installing"