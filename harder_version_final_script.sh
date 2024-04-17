#!/bin/bash

# CONSTANTS
APR_VERSION="1.7.4"
EXPAT_VERSION="2.6.2"
APR_UTIL_VERSION="1.6.3"
APACHE_VERSION="2.4.59"
PACKAGES_INSTALLATION_DIRECTORY="/opt"
# NUMBER_OF_PROCESSING_UNITS=$(nproc)
NUMBER_OF_PROCESSING_UNITS=50










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
    sudo apt install cmake -y
    sudo apt install build-essential -y
    sudo apt install libncurses5-dev -y
    sudo apt install gnutls-dev -y
    sudo apt install pkg-config -y
    sudo apt install zlib1g-dev -y
    echo "Finished installing"
}


function install_apr {
    APR_SOURCE_CODE_URL="https://dlcdn.apache.org/apr/apr-${APR_VERSION}.tar.bz2"
    APR_SOURCE_DIRECTORY_NAME="${APR_SOURCE_CODE_URL##*/}" # apr-${APR_VERSION}.tar.bz2
    APR_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION=$(basename "$APR_SOURCE_DIRECTORY_NAME" .tar.bz2) # apr-${APR_VERSION}
    APR_FILE_INSTALL_LOCATION="${PACKAGES_INSTALLATION_DIRECTORY}/apr-${APR_VERSION}"

    curl -O "$APR_SOURCE_CODE_URL"
    
    tar xvf "$APR_SOURCE_DIRECTORY_NAME"
    
    cd "./$APR_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION" || exit

    sudo ./configure --prefix="$APR_FILE_INSTALL_LOCATION"
    sudo make -j "$NUMBER_OF_PROCESSING_UNITS"
    sudo make install -j "$NUMBER_OF_PROCESSING_UNITS"
}


 # EXPAT IS NEEDED FOR APR-UTIL
function install_expat {
    EXPAT_VERSION_DOTS_REPLACED_WITH_UNDERSCORES=${EXPAT_VERSION//./_} # Replace dots with underscores
    EXPAT_SOURCE_CODE_URL="https://github.com/libexpat/libexpat/releases/download/R_${EXPAT_VERSION_DOTS_REPLACED_WITH_UNDERSCORES}/expat-${EXPAT_VERSION}.tar.bz2"
    EXPAT_SOURCE_DIRECTORY_NAME="${EXPAT_SOURCE_CODE_URL##*/}"
    EXPAT_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION=$(basename "$EXPAT_SOURCE_DIRECTORY_NAME" .tar.bz2)
    EXPAT_FILE_INSTALL_LOCATION="${PACKAGES_INSTALLATION_DIRECTORY}/expat-${EXPAT_VERSION}"

    wget "$EXPAT_SOURCE_CODE_URL"
    
    tar xvf "$EXPAT_SOURCE_DIRECTORY_NAME"
    
    cd "./$EXPAT_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION" || exit
    sudo ./configure --prefix="$EXPAT_FILE_INSTALL_LOCATION"
    sudo make -j "$NUMBER_OF_PROCESSING_UNITS"
    sudo make install -j "$NUMBER_OF_PROCESSING_UNITS"
}

function install_apr_util {
    APR_UTIL_SOURCE_CODE_URL="https://dlcdn.apache.org/apr/apr-util-${APR_UTIL_VERSION}.tar.bz2"
    APR_UTIL_SOURCE_DIRECTORY_NAME="${APR_UTIL_SOURCE_CODE_URL##*/}"
    APR_UTIL_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION=$(basename "$APR_UTIL_SOURCE_DIRECTORY_NAME" .tar.bz2)
    APR_UTIL_FILE_INSTALL_LOCATION="${PACKAGES_INSTALLATION_DIRECTORY}/apr_util-${APR_UTIL_VERSION}"
    
    curl -O "$APR_UTIL_SOURCE_CODE_URL"
    
    tar xvf "$APR_UTIL_SOURCE_DIRECTORY_NAME"
    
    cd "./$APR_UTIL_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION" || exit
    sudo ./configure --prefix="$APR_UTIL_FILE_INSTALL_LOCATION" --with-apr="$APR_FILE_INSTALL_LOCATION" --with-expat="$EXPAT_FILE_INSTALL_LOCATION"
    sudo make -j "$NUMBER_OF_PROCESSING_UNITS"
    sudo make install -j "$NUMBER_OF_PROCESSING_UNITS"
}




function install_apache {
    APACHE_SOURCE_CODE_URL="https://dlcdn.apache.org/httpd/httpd-${APACHE_VERSION}.tar.bz2"
    APACHE_SOURCE_DIRECTORY_NAME="${APACHE_SOURCE_CODE_URL##*/}"
    APACHE_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION=$(basename "$APACHE_SOURCE_DIRECTORY_NAME" .tar.bz2)
    APACHE_FILE_INSTALL_LOCATION="${PACKAGES_INSTALLATION_DIRECTORY}/apache-${APACHE_VERSION}"
    curl -O "$APACHE_SOURCE_CODE_URL"
    
    tar xvf "$APACHE_SOURCE_DIRECTORY_NAME"
    
    cd "./$APACHE_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION" || exit
    ./configure --prefix="$APACHE_FILE_INSTALL_LOCATION" --with-apr="$APR_FILE_INSTALL_LOCATION" --with-apr-util="$APR_UTIL_FILE_INSTALL_LOCATION"
    sudo make -j "$NUMBER_OF_PROCESSING_UNITS"
    sudo make install -j "$NUMBER_OF_PROCESSING_UNITS"
    echo "Starting apache service"
    sudo "$APACHE_FILE_INSTALL_LOCATION"/bin/apachectl start
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
    sudo make -j "$NUMBER_OF_PROCESSING_UNITS"
    sudo make install -j "$NUMBER_OF_PROCESSING_UNITS"
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
    
    sudo cmake . -DCMAKE_INSTALL_PREFIX:PATH="$MARIADB_FILE_INSTALL_LOCATION"
    sudo make -j "$NUMBER_OF_PROCESSING_UNITS"
    sudo make install -j "$NUMBER_OF_PROCESSING_UNITS"
    
    sudo groupadd mysql
    sudo useradd -r -g mysql mysql
    
    sudo /opt/mariadb/scripts/mysql_install_db --user=mysql --datadir=/opt/mariadb/data
    
    echo "[mysqld]" > /etc/my.cnf
    echo "pid-file=/var/run/mysqld/mysqld.pid" >> /etc/my.cnf
    
    sudo mkdir /var/run/mysqld
    sudo touch /var/run/mysqld/mysqld.pid
    sudo chown -R mysql:mysql /var/run/mysqld
    sudo /opt/mariadb/support-files/mysql.server start --user=mysql
}

function check_if_mariadb_is_installed {
    response=$(which /opt/mariadb/bin/mariadb)
    if [[ "$response" == "/opt/mariadb/bin/mariadb" ]]; then
        echo "Mariadb found"
    else
        echo "Mariadb not found"
    fi
}

# Install needed packages
install_needed_packages

install_apr
install_expat
install_apr_util
install_apache
# install_php
# install_mariadb

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