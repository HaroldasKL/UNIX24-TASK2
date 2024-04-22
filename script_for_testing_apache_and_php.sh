#!/bin/bash

# CONSTANTS
#------------------------
APR_VERSION="1.7.4"
EXPAT_VERSION="2.6.2" # IF you update EXPAT_VERSION, please also update variable SHA512_SUM_OF_REMOTE_EXPAT_FILES
APR_UTIL_VERSION="1.6.3"
APACHE_VERSION="2.4.59"
PHP_VERSION="8.3.4"
MARIADB_VERSION="11.3.2"

USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36 OPR/108.0.0.0"

TAR_BZ2_EXTENSION=".tar.bz2"
SHA256_EXTENSION=".sha256"
TAR_GZ_EXTENSION=".tar.gz"
TAR_XZ_EXTENSION=".tar.xz"


PACKAGES_INSTALLATION_DIRECTORY="/opt"
NUMBER_OF_PROCESSING_UNITS=$(nproc)
#------------------------
# END OF CONSTANTS

# Track script running time
start=$(date +%s)
current_date=$(date +"%Y-%m-%d")
current_time=$(date +"%T")
echo "Script started"
echo "Current date: $current_date"
echo "Current time: $current_time"


function install_needed_packages {
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
}

function install_apr {
    APR_SOURCE_CODE_URL="https://dlcdn.apache.org/apr"
    APR_SOURCE_CODE_FULL_URL="${APR_SOURCE_CODE_URL}/apr-${APR_VERSION}${TAR_BZ2_EXTENSION}"
    APR_SOURCE_CODE_SHA256_SUM_URL="${APR_SOURCE_CODE_URL}/apr-${APR_VERSION}${TAR_BZ2_EXTENSION}${SHA256_EXTENSION}"
    APR_SOURCE_DIRECTORY_NAME="${APR_SOURCE_CODE_FULL_URL##*/}" # apr-${APR_VERSION}.tar.bz2
    APR_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION=$(basename "$APR_SOURCE_DIRECTORY_NAME" .tar.bz2) # apr-${APR_VERSION}
    APR_FILE_INSTALL_LOCATION="${PACKAGES_INSTALLATION_DIRECTORY}/apr-${APR_VERSION}"
    
    wget -U "${USER_AGENT}" "$APR_SOURCE_CODE_URL"
    
    SHA256_SUM_OF_REMOTE_APR_FILES=$(curl -s -A "$USER_AGENT" "${APR_SOURCE_CODE_SHA256_SUM_URL}" | cut -f -1 -d " ")
    SHA256_SUM_OF_LOCAL_APR_FILES=$(sha256sum "${APR_SOURCE_DIRECTORY_NAME}" | cut -f -1 -d " ")
    
    if [[ "${SHA256_SUM_OF_REMOTE_APR_FILES}" == "${SHA256_SUM_OF_LOCAL_APR_FILES}" ]]; then
        echo "Checksum matches"
    else
        echo "Checksum does not match!"
        echo "Remote file checksum: |${SHA256_SUM_OF_REMOTE_APR_FILES}|"
        echo "Local file checksum:  |${SHA256_SUM_OF_LOCAL_APR_FILES}|"
        exit 1
    fi
    
    tar xvf "$APR_SOURCE_DIRECTORY_NAME"
    
    cd "./$APR_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION" || exit
    
    sudo ./configure --prefix="$APR_FILE_INSTALL_LOCATION"
    sudo make -j "$NUMBER_OF_PROCESSING_UNITS"
    sudo make install -j "$NUMBER_OF_PROCESSING_UNITS"
    cd ..
    
    #sudo rm "${APR_SOURCE_DIRECTORY_NAME}"
    #sudo rm -r "${APR_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION}"
}

# EXPAT IS NEEDED FOR APR-UTIL
function install_expat {
    EXPAT_VERSION_DOTS_REPLACED_WITH_UNDERSCORES=${EXPAT_VERSION//./_} # Replace dots with underscores
    EXPAT_SOURCE_CODE_URL="https://github.com/libexpat/libexpat/releases/download/R_${EXPAT_VERSION_DOTS_REPLACED_WITH_UNDERSCORES}/expat-${EXPAT_VERSION}${TAR_XZ_EXTENSION}"
    EXPAT_SOURCE_DIRECTORY_NAME="${EXPAT_SOURCE_CODE_URL##*/}"
    EXPAT_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION=$(basename "$EXPAT_SOURCE_DIRECTORY_NAME" .tar.xz)
    EXPAT_FILE_INSTALL_LOCATION="${PACKAGES_INSTALLATION_DIRECTORY}/expat-${EXPAT_VERSION}"
    
    wget -U "${USER_AGENT}" "$EXPAT_SOURCE_CODE_URL"
    
    # IF you update EXPAT_VERSION, please also update this variable - SHA512_SUM_OF_REMOTE_EXPAT_FILES
    SHA512_SUM_OF_REMOTE_EXPAT_FILES="47b60967d6346d330dded87ea1a2957aa7d34dd825043386a89aa131054714f618ede57bfe97cf6caa40582a4bc67e198d2a915e7d8dbe8ee4f581857c2e3c2e"
    SHA512_SUM_OF_LOCAL_EXPAT_FILES=$(sha512sum "${EXPAT_SOURCE_DIRECTORY_NAME}" | cut -f -1 -d " ")
    
    if [[ "${SHA512_SUM_OF_REMOTE_EXPAT_FILES}" == "${SHA512_SUM_OF_LOCAL_EXPAT_FILES}" ]]; then
        echo "Checksum matches"
    else
        echo "Checksum does not match!"
        echo "Remote file checksum: |${SHA512_SUM_OF_REMOTE_EXPAT_FILES}|"
        echo "Local file checksum:  |${SHA512_SUM_OF_LOCAL_EXPAT_FILES}|"
        echo "It might be, because you updated EXPAT_VERSION and forgot to update variable SHA512_SUM_OF_REMOTE_EXPAT_FILES"
        exit 1
    fi
    
    tar xvf "$EXPAT_SOURCE_DIRECTORY_NAME"
    
    cd "./$EXPAT_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION" || exit
    sudo ./configure --prefix="$EXPAT_FILE_INSTALL_LOCATION"
    sudo make -j "$NUMBER_OF_PROCESSING_UNITS"
    sudo make install -j "$NUMBER_OF_PROCESSING_UNITS"
    cd ..
    
    #sudo rm "${EXPAT_SOURCE_DIRECTORY_NAME}"
    #sudo rm -r "${EXPAT_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION}"
}

function install_apr_util {
    APR_UTIL_SOURCE_CODE_URL="https://dlcdn.apache.org/apr"
    APR_UTIL_SOURCE_CODE_FULL_URL="${APR_UTIL_SOURCE_CODE_URL}/apr-util-${APR_UTIL_VERSION}${TAR_BZ2_EXTENSION}"
    APR_UTIL_SOURCE_CODE_SHA256_SUM_URL="${APR_UTIL_SOURCE_CODE_URL}/apr-util-${APR_UTIL_VERSION}${TAR_BZ2_EXTENSION}${SHA256_EXTENSION}"
    APR_UTIL_SOURCE_DIRECTORY_NAME="${APR_UTIL_SOURCE_CODE_FULL_URL##*/}"
    APR_UTIL_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION=$(basename "$APR_UTIL_SOURCE_DIRECTORY_NAME" .tar.bz2)
    APR_UTIL_FILE_INSTALL_LOCATION="${PACKAGES_INSTALLATION_DIRECTORY}/apr_util-${APR_UTIL_VERSION}"
    
    wget -U "${USER_AGENT}" "$APR_UTIL_SOURCE_CODE_URL"
    
    SHA256_SUM_OF_REMOTE_APR_UTIL_FILES=$(curl -s -A "$USER_AGENT" "${APR_UTIL_SOURCE_CODE_SHA256_SUM_URL}" | cut -f -1 -d " ")
    SHA256_SUM_OF_LOCAL_APR_UTIL_FILES=$(sha256sum "${APR_UTIL_SOURCE_DIRECTORY_NAME}" | cut -f -1 -d " ")
    
    if [[ "${SHA256_SUM_OF_REMOTE_APR_UTIL_FILES}" == "${SHA256_SUM_OF_LOCAL_APR_UTIL_FILES}" ]]; then
        echo "Checksum matches"
    else
        echo "Checksum does not match!"
        echo "Remote file checksum: |${SHA256_SUM_OF_REMOTE_APR_UTIL_FILES}|"
        echo "Local file checksum:  |${SHA256_SUM_OF_LOCAL_APR_UTIL_FILES}|"
        exit 1
    fi
    
    tar xvf "$APR_UTIL_SOURCE_DIRECTORY_NAME"
    
    cd "./$APR_UTIL_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION" || exit
    sudo ./configure --prefix="$APR_UTIL_FILE_INSTALL_LOCATION" --with-apr="$APR_FILE_INSTALL_LOCATION" --with-expat="$EXPAT_FILE_INSTALL_LOCATION"
    sudo make -j "$NUMBER_OF_PROCESSING_UNITS"
    sudo make install -j "$NUMBER_OF_PROCESSING_UNITS"
    cd ..
    
    # sudo rm "${APR_UTIL_SOURCE_DIRECTORY_NAME}"
    # sudo rm -r "${APR_UTIL_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION}"
}

function install_apache {
    APACHE_SOURCE_CODE_URL="https://dlcdn.apache.org/httpd/httpd-"
    APACHE_SOURCE_CODE_FULL_URL="${APACHE_SOURCE_CODE_URL}${APACHE_VERSION}${TAR_BZ2_EXTENSION}"
    APACHE_SOURCE_CODE_SHA256_SUM_URL="${APACHE_SOURCE_CODE_FULL_URL}${SHA256_EXTENSION}"
    APACHE_SOURCE_DIRECTORY_NAME="${APACHE_SOURCE_CODE_FULL_URL##*/}"
    APACHE_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION=$(basename "$APACHE_SOURCE_DIRECTORY_NAME" ${TAR_BZ2_EXTENSION})
    APACHE_FILE_INSTALL_LOCATION="${PACKAGES_INSTALLATION_DIRECTORY}/apache-${APACHE_VERSION}"
    
    wget -U "${USER_AGENT}" "$APACHE_SOURCE_CODE_FULL_URL"
    
    SHA256_SUM_OF_REMOTE_APACHE_FILES=$(curl -s -A "$USER_AGENT" "${APACHE_SOURCE_CODE_SHA256_SUM_URL}" | cut -f -1 -d " ")
    SHA256_SUM_OF_LOCAL_APACHE_FILES=$(sha256sum "${APACHE_SOURCE_DIRECTORY_NAME}" | cut -f -1 -d " ")
    
    if [[ "${SHA256_SUM_OF_REMOTE_APACHE_FILES}" == "${SHA256_SUM_OF_LOCAL_APACHE_FILES}" ]]; then
        echo "Checksum matches"
    else
        echo "Checksum does not match!"
        echo "Remote file checksum: |${SHA256_SUM_OF_REMOTE_APACHE_FILES}|"
        echo "Local file checksum:  |${SHA256_SUM_OF_LOCAL_APACHE_FILES}|"
    fi
    
    tar xvf "$APACHE_SOURCE_DIRECTORY_NAME"
    
    cd "./$APACHE_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION" || exit
    ./configure --prefix="$APACHE_FILE_INSTALL_LOCATION" --with-apr="$APR_FILE_INSTALL_LOCATION" --with-apr-util="$APR_UTIL_FILE_INSTALL_LOCATION" --enable-so
    sudo make -j "$NUMBER_OF_PROCESSING_UNITS"
    sudo make install -j "$NUMBER_OF_PROCESSING_UNITS"
    echo "Starting apache service"
    sudo "${APACHE_FILE_INSTALL_LOCATION}"/bin/apachectl -k start
    response=$(curl "http://localhost:80")
    if [[ "$response" == "<html><body><h1>It works!</h1></body></html>" ]]; then
        echo "Apache is running"
    else
        echo "Apache is not running"
    fi
    echo "Stopping apache service"
    sudo "${APACHE_FILE_INSTALL_LOCATION}"/bin/apachectl -k stop
    
    sudo echo "<FilesMatch \.php$>" >> "${APACHE_FILE_INSTALL_LOCATION}/conf/httpd.conf"
    sudo echo "    SetHandler application/x-httpd-php" >> "${APACHE_FILE_INSTALL_LOCATION}/conf/httpd.conf"
    sudo echo "</FilesMatch>" >> "${APACHE_FILE_INSTALL_LOCATION}/conf/httpd.conf"
    
    sudo echo "echo \"<?php phpinfo();?>\"" > "${APACHE_FILE_INSTALL_LOCATION}/htdocs/index.php"
    
    # sudo rm "${APACHE_SOURCE_DIRECTORY_NAME}"
    # sudo rm -r "${APACHE_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION}"
}

function check_if_apache_is_running {
    response=$(curl "http://localhost:80")
    if [[ "$response" == "<html><body><h1>It works!</h1></body></html>" ]]; then
        echo "Apache is running"
    else
        echo "Apache is not running"
    fi
    
    curl -s -I http://localhost/index.php | grep "Server:" | sudo tee output.txt
    sudo cat output.txt | tr -d '\r' > cleaned_output.txt
    response=$(< cleaned_output.txt)
    if [[ "$response" == "Server: Apache/${APACHE_VERSION} (Unix) PHP/${PHP_VERSION}" ]]; then
        echo "Apache is successfully configured with PHP!"
    else
        echo "Error configuring Apache with PHP!"
    fi
    rm output.txt
    rm cleaned_output.txt
}

function install_php {
    PHP_SOURCE_CODE_URL="https://www.php.net"
    PHP_SOURCE_CODE_FULL_URL="${PHP_SOURCE_CODE_URL}/distributions/php-${PHP_VERSION}${TAR_BZ2_EXTENSION}"
    PHP_SOURCE_CODE_SHA256_SUM_URL="${PHP_SOURCE_CODE_URL}/releases/index.php?json&version=${PHP_VERSION}"
    PHP_SOURCE_DIRECTORY_NAME="${PHP_SOURCE_CODE_FULL_URL##*/}"
    PHP_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION=$(basename "$PHP_SOURCE_DIRECTORY_NAME" ${TAR_BZ2_EXTENSION})
    PHP_FILE_INSTALL_LOCATION="${PACKAGES_INSTALLATION_DIRECTORY}/php-${PHP_VERSION}"
    
    wget -U "${USER_AGENT}" "$PHP_SOURCE_CODE_FULL_URL"
    
    curl -s -A "$USER_AGENT" "${PHP_SOURCE_CODE_SHA256_SUM_URL}" > "file.json"
    SHA256_SUM_OF_REMOTE_PHP_FILES=$(jq -r --arg PHP_VERSION "$PHP_VERSION" --arg TAR_BZ2_EXTENSION "$TAR_BZ2_EXTENSION" '.source[] | select(.filename == "php-\($PHP_VERSION)\($TAR_BZ2_EXTENSION)") | .sha256' file.json)
    rm "file.json"
    SHA256_SUM_OF_LOCAL_PHP_FILES=$(sha256sum "${PHP_SOURCE_DIRECTORY_NAME}" | cut -f -1 -d " ")
    if [[ "${SHA256_SUM_OF_REMOTE_PHP_FILES}" == "${SHA256_SUM_OF_LOCAL_PHP_FILES}" ]]; then
        echo "Checksum matches"
    else
        echo "Checksum does not match!"
        echo "Remote file checksum: |${SHA256_SUM_OF_REMOTE_PHP_FILES}|"
        echo "Local file checksum:  |${SHA256_SUM_OF_LOCAL_PHP_FILES}|"
        exit 1
    fi
    
    tar xvf "$PHP_SOURCE_DIRECTORY_NAME"
    
    cd "./$PHP_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION" || exit
    
    sudo ./configure --prefix="$PHP_FILE_INSTALL_LOCATION" --with-apxs2="${APACHE_FILE_INSTALL_LOCATION}"/bin/apxs
    sudo make -j "$NUMBER_OF_PROCESSING_UNITS"
    sudo make install -j "$NUMBER_OF_PROCESSING_UNITS"
    sudo cp php.ini-development ${PHP_FILE_INSTALL_LOCATION}/lib/php.ini
    cd ..
    
    echo "Starting apache service"
    sudo "${APACHE_FILE_INSTALL_LOCATION}"/bin/apachectl -k start
    # sudo rm "${PHP_SOURCE_DIRECTORY_NAME}"
    # sudo rm -r "${PHP_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION}"
}

function check_if_php_is_installed {
    response=$(which ${PHP_FILE_INSTALL_LOCATION}/bin/php)
    if [[ "$response" == "${PHP_FILE_INSTALL_LOCATION}/bin/php" ]]; then
        echo "Php found"
    else
        echo "Php not found"
    fi
}

function install_mariadb {
    MARIADB_SOURCE_CODE_URL="https://downloads.mariadb.org/rest-api/mariadb"
    MARIADB_SOURCE_CODE_FULL_URL="${MARIADB_SOURCE_CODE_URL}/${MARIADB_VERSION}/mariadb-${MARIADB_VERSION}${TAR_GZ_EXTENSION}"
    MARIADB_SOURCE_CODE_SHA256_SUM_URL="${MARIADB_SOURCE_CODE_FULL_URL}/checksum"
    MARIADB_SOURCE_DIRECTORY_NAME="${MARIADB_SOURCE_CODE_FULL_URL##*/}"
    MARIADB_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION=$(basename "$MARIADB_SOURCE_DIRECTORY_NAME" .tar.gz)
    MARIADB_FILE_INSTALL_LOCATION="${PACKAGES_INSTALLATION_DIRECTORY}/mariadb-${MARIADB_VERSION}"
    
    wget -U "${USER_AGENT}" "$MARIADB_SOURCE_CODE_FULL_URL"
    
    SHA256_SUM_OF_REMOTE_MARIADB_FILES=$(curl -s -A "$USER_AGENT" "$MARIADB_SOURCE_CODE_SHA256_SUM_URL" | jq -r '.response.checksum.sha256sum')
    SHA256_SUM_OF_LOCAL_MARIADB_FILES=$(sha256sum "${MARIADB_SOURCE_DIRECTORY_NAME}" | cut -f -1 -d " ")
    if [[ "${SHA256_SUM_OF_REMOTE_MARIADB_FILES}" == "${SHA256_SUM_OF_LOCAL_MARIADB_FILES}" ]]; then
        echo "Checksum matches"
    else
        echo "Checksum does not match!"
        echo "Remote file checksum: |${SHA256_SUM_OF_REMOTE_MARIADB_FILES}|"
        echo "Local file checksum:  |${SHA256_SUM_OF_LOCAL_MARIADB_FILES}|"
    fi
    
    tar xvf "$MARIADB_SOURCE_DIRECTORY_NAME"
    
    cd "./$MARIADB_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION" || exit
    
    sudo cmake . -DCMAKE_INSTALL_PREFIX:PATH="$MARIADB_FILE_INSTALL_LOCATION"
    sudo make -j "$NUMBER_OF_PROCESSING_UNITS"
    sudo make install -j "$NUMBER_OF_PROCESSING_UNITS"
    
    sudo groupadd mysql
    sudo useradd -r -g mysql mysql
    
    sudo ${MARIADB_FILE_INSTALL_LOCATION}/scripts/mysql_install_db --user=mysql --datadir=${MARIADB_FILE_INSTALL_LOCATION}/data
    
    echo "[mysqld]" > /etc/my.cnf
    echo "pid-file=/var/run/mysqld/mysqld.pid" >> /etc/my.cnf
    
    sudo mkdir /var/run/mysqld
    sudo touch /var/run/mysqld/mysqld.pid
    sudo chown -R mysql:mysql /var/run/mysqld
    sudo ${MARIADB_FILE_INSTALL_LOCATION}/support-files/mysql.server start --user=mysql
    cd ..
    
    # sudo rm "${MARIADB_SOURCE_DIRECTORY_NAME}"
    # sudo rm -r "${MARIADB_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION}"
}

function check_if_mariadb_is_installed {
    response=$(which ${MARIADB_FILE_INSTALL_LOCATION}/bin/mariadb)
    if [[ "$response" == "${MARIADB_FILE_INSTALL_LOCATION}/bin/mariadb" ]]; then
        echo "Mariadb found"
    else
        echo "Mariadb not found"
    fi
}

function delete_source_code_files {
    echo "Cleaning up source code directories"
    sudo rm "${APR_SOURCE_DIRECTORY_NAME}"
    sudo rm -r "${APR_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION}"
    
    sudo rm "${EXPAT_SOURCE_DIRECTORY_NAME}"
    sudo rm -r "${EXPAT_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION}"
    
    sudo rm "${APR_UTIL_SOURCE_DIRECTORY_NAME}"
    sudo rm -r "${APR_UTIL_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION}"
    
    sudo rm "${APACHE_SOURCE_DIRECTORY_NAME}"
    sudo rm -r "${APACHE_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION}"
    
    sudo rm "${PHP_SOURCE_DIRECTORY_NAME}"
    sudo rm -r "${PHP_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION}"
    
    sudo rm "${MARIADB_SOURCE_DIRECTORY_NAME}"
    sudo rm -r "${MARIADB_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION}"
    echo "Cleaned up"
}

# Install needed packages
install_needed_packages

install_apr
install_expat
install_apr_util
install_apache
install_php
install_mariadb

check_if_apache_is_running
check_if_php_is_installed
check_if_mariadb_is_installed

#delete_source_code_files

end=$(date +%s)
runtime=$((end-start))
echo "Script took $((runtime / 60)) minutes and $((runtime % 60)) seconds to run."

current_date=$(date +"%Y-%m-%d")
current_time=$(date +"%T")
echo "Script ended"
echo "Current date: $current_date"
echo "Current time: $current_time"
