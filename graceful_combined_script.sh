#!/bin/bash
start=$(date +%s)
current_date=$(date +"%Y-%m-%d")
current_time=$(date +"%T")
echo "Script started"
echo "Current date: $current_date"
echo "Current time: $current_time"


function install_needed_packages {
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
    sudo apt install zlib1g-dev -y
    echo "Finished installing"
}


function install_apache {
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
}

function check_if_apache_is_running {
    response=$(curl "http://localhost:80")
    if [[ "$response" == "<html><body><h1>It works!</h1></body></html>" ]]; then
        echo "Apache is running"
    else
        echo "Apache is not running"
    fi
}

function install_php {
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
}

function check_if_php_is_installed {
    response=$(which /opt/php/bin/php)
    if [[ "$response" == "/opt/php/bin/php" ]]; then
        echo "Php found"
    else
        echo "Php not found"
    fi
}

function install_mariadb {
    MARIADB_SOURCE_CODE_URL="https://mariadb.mirror.serveriai.lt//mariadb-11.3.2/source/mariadb-11.3.2.tar.gz"
    MARIADB_SOURCE_DIRECTORY_NAME="${MARIADB_SOURCE_CODE_URL##*/}"
    MARIADB_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION=$(basename "$MARIADB_SOURCE_DIRECTORY_NAME" .tar.gz) # mariadb-11.3.2
    MARIADB_FILE_INSTALL_LOCATION="/opt/mariadb"
    curl -O "$MARIADB_SOURCE_CODE_URL"
    tar xvf "$MARIADB_SOURCE_DIRECTORY_NAME"
    cd "./$MARIADB_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION" || exit
    sudo cmake . -DCMAKE_INSTALL_PREFIX:PATH="/opt/mariadb"
    sudo make -j "$(nproc)"
    sudo make install -j "$(nproc)"
    sudo groupadd mysql
    sudo useradd -r -g mysql mysql
    sudo /opt/mariadb/scripts/mysql_install_db --user=mysql --datadir=/opt/mariadb/data
    sudo /opt/mariadb/bin/mariadbd-safe --datadir='/opt/mariadb/data' &
}

function check_if_mariadb_is_installed {
    response=$(which /opt/mariadb/bin/mariadb)
    if [[ "$response" == "/opt/mariadb/bin/mariadb" ]]; then
        echo "Mariadb found"
    else
        echo "Mariadb not found"
    fi
}


install_needed_packages

install_apache
install_php
install_mariadb

check_if_apache_is_running
check_if_php_is_installed
check_if_mariadb_is_installed


end=$(date +%s)
runtime=$((end-start))
echo "Script took $((runtime / 60)) minutes and $((runtime % 60)) seconds to run."

current_date=$(date +"%Y-%m-%d")
current_time=$(date +"%T")
echo "Script ended"
echo "Current date: $current_date"
echo "Current time: $current_time"
