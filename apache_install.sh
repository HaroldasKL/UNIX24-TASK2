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


APACHE_SOURCE_CODE_URL="https://dlcdn.apache.org/httpd/httpd-2.4.59.tar.bz2"
APACHE_SOURCE_DIRECTORY_NAME="${APACHE_SOURCE_CODE_URL##*/}" # httpd-2.4.59.tar.bz2
APACHE_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION=$(basename "$APACHE_SOURCE_DIRECTORY_NAME" .tar.bz2) # httpd-2.4.59
APACHE_FILE_INSTALL_LOCATION="/opt/apache2"

curl -O "$APACHE_SOURCE_CODE_URL"

tar xvf "$APACHE_SOURCE_DIRECTORY_NAME"

cd "./$APACHE_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION" || exit
./configure --prefix="$APACHE_FILE_INSTALL_LOCATION"
make -j "$(nproc)" # nproc - print the number of processing units available
make install -j "$(nproc)"
echo "Starting apache service"
"$APACHE_FILE_INSTALL_LOCATION"/bin/apachectl start


response=$(curl "http://localhost:80")
if [[ "$response" == "<html><body><h1>It works!</h1></body></html>" ]]; then
	echo "Apache is running"
	IS_APACHE_RUNNING=true
else
	echo "Apache is not running"
fi