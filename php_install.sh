#!/bin/bash

start=$(date +%s)
current_date=$(date +"%Y-%m-%d")
current_time=$(date +"%T")
echo "Script started"
echo "Current date: $current_date"
echo "Current time: $current_time"

echo "Installing needed packages"
sudo apt-get update
sudo apt install bzip2 -y
sudo apt install libapr1-dev -y
sudo apt install libaprutil1-dev -y
sudo apt install gcc -y
sudo apt install libpcre3 -y
sudo apt install libpcre3-dev -y
sudo apt install make -y
sudo apt install libxml2-dev -y
sudo apt install libsqlite3-dev -y
sudo apt install cmake -y
sudo apt install build-essential -y
sudo apt install libncurses5-dev -y
sudo apt install gnutls-dev -y
sudo apt install pkg-config -y
echo "Finished installing"

PHP_SOURCE_CODE_URL="https://www.php.net/distributions/php-8.3.4.tar.gz"
PHP_SOURCE_DIRECTORY_NAME="${PHP_SOURCE_CODE_URL##*/}"
PHP_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION=$(basename "$PHP_SOURCE_DIRECTORY_NAME" .tar.gz) # php-8.3.4
PHP_FILE_INSTALL_LOCATION="/opt/php"

curl -O "$PHP_SOURCE_CODE_URL"

tar xvf "$PHP_SOURCE_DIRECTORY_NAME"

cd "./$PHP_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION" || exit
sudo ./configure --prefix="$PHP_FILE_INSTALL_LOCATION"
sudo make -j "$(nproc)" # print the number of processing units available
sudo make install -j "$(nproc)"

response=$(which /opt/php/bin/php)
if [[ "$response" == "/opt/php/bin/php" ]]; then
    echo "Php found"
    IS_PHP_FOUND=true
else
    echo "Php not found"
fi