#!/bin/bash

# 0. Check integrity of files
# 1. Download apache, compile, install and run
# 2. Download php, compile, install and run
# 3. Download mariaDB, compile, install and run

start=$(date +%s)
current_date=$(date +"%Y-%m-%d")
current_time=$(date +"%T")
echo "Script started"
echo "Current date: $current_date"
echo "Current time: $current_time"

IS_APACHE_RUNNING=false
IS_PHP_FOUND=false
IS_MARIADB_FOUND=false

function check_if_running_as_root {
    SCRIPT_EXECUTOR_ID=$(id -u)
    echo "Running script as $(whoami) with ID: $SCRIPT_EXECUTOR_ID"
    if [[ "$SCRIPT_EXECUTOR_ID" -ne 0 ]]; then
        echo "Please run $0 as root"
        echo "Exiting..."
        exit
    fi
}


# FOR NOW WITH APT
# function install_PCRE {
# 	PCRE_SOURCE_CODE_URL="https://sourceforge.net/projects/pcre/files/pcre/8.45/pcre-8.45.tar.bz2/download"
# 	curl -O "$PCRE_SOURCE_CODE_URL"
# 	PCRE_SOURCE_DIRECTORY_NAME="${PCRE_SOURCE_CODE_URL##*/}"
# 	tar xvf "$PCRE_SOURCE_DIRECTORY_NAME"
# }


APACHE_SOURCE_CODE_URL="https://dlcdn.apache.org/httpd/httpd-2.4.59.tar.bz2"
APACHE_SOURCE_DIRECTORY_NAME="${APACHE_SOURCE_CODE_URL##*/}" # httpd-2.4.59.tar.bz2
APACHE_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION=$(basename "$APACHE_SOURCE_DIRECTORY_NAME" .tar.bz2) # httpd-2.4.59
APACHE_FILE_INSTALL_LOCATION="/opt/apache2"

function install_libs_for_apache_with_apt {
    # Will need to compile it from source later
    echo "Updating apt cache"
    sudo apt-get update
    echo "Installing packages for apache"
    sudo apt-get install gcc bzip2 make libpcre3 libpcre3-dev -y
    sudo apt-get install libapr1-dev libaprutil1-dev -y
    echo "Finished installing packages for apache"
}

function clear_apache_source_code_files {
    sudo rm "$APACHE_SOURCE_DIRECTORY_NAME"
    sudo rm -rf "$APACHE_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION"
}

function download_apache_source_code {
    
    curl -O "$APACHE_SOURCE_CODE_URL"
}

function extract_apache_source_code {
    tar xvf "$APACHE_SOURCE_DIRECTORY_NAME"
}

function compile_apache_source_code {
    cd "./$APACHE_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION" || exit
    ./configure --prefix="$APACHE_FILE_INSTALL_LOCATION"
    make -j "$(nproc)" # nproc - print the number of processing units available
    make install -j "$(nproc)"
    echo "Starting apache service"
    "$APACHE_FILE_INSTALL_LOCATION"/bin/apachectl start
}

function test_if_apache_works {
    response=$(curl "http://localhost:80")
    if [[ "$response" == "<html><body><h1>It works!</h1></body></html>" ]]; then
        echo "Apache is running"
        IS_APACHE_RUNNING=true
    else
        echo "Apache is not running"
    fi
}

function install_apache {
    #install_libs_for_apache_with_apt
    clear_apache_source_code_files
    download_apache_source_code
    extract_apache_source_code
    compile_apache_source_code
    clear_apache_source_code_files
}


PHP_SOURCE_CODE_URL="https://www.php.net/distributions/php-8.3.4.tar.gz"
PHP_SOURCE_DIRECTORY_NAME="${PHP_SOURCE_CODE_URL##*/}"
PHP_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION=$(basename "$PHP_SOURCE_DIRECTORY_NAME" .tar.gz) # php-8.3.4
PHP_FILE_INSTALL_LOCATION="/opt/php"

function install_libs_for_php_with_apt {
    # Will need to compile it from source later
    sudo apt-get update
    echo "Installing packages for php"
    sudo apt-get install pkg-config libxml2-dev libsqlite3-dev -y
    echo "Finished installing packages for php"
}

function clear_php_source_code_files {
    sudo rm "$PHP_SOURCE_DIRECTORY_NAME"
    sudo rm -rf "$PHP_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION"
}

function download_php_source_code {
    curl -O "$PHP_SOURCE_CODE_URL"
}

function extract_php_source_code {
    tar xvf "$PHP_SOURCE_DIRECTORY_NAME"
}

function compile_php_source_code {
    cd "./$PHP_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION" || exit
    sudo ./configure --prefix="$PHP_FILE_INSTALL_LOCATION"
    sudo make -j "$(nproc)" # print the number of processing units available
    sudo make install -j "$(nproc)"
}

function install_php {
    #install_libs_for_php_with_apt
    download_php_source_code
    extract_php_source_code
    compile_php_source_code
    clear_php_source_code_files
}

function test_if_php_exists {
    response=$(which /opt/php/bin/php)
    if [[ "$response" == "/opt/php/bin/php" ]]; then
        echo "Php found"
        IS_PHP_FOUND=true
    else
        echo "Php not found"
    fi
}

function clear_opt_dir {
    echo "Clearing /opt/ directory"
    sudo rm -rf /opt/*
    echo "Finished cleaning"
}


MARIADB_SOURCE_CODE_URL="https://mariadb.mirror.serveriai.lt//mariadb-11.3.2/source/mariadb-11.3.2.tar.gz"
MARIADB_SOURCE_DIRECTORY_NAME="${MARIADB_SOURCE_CODE_URL##*/}"
MARIADB_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION=$(basename "$MARIADB_SOURCE_DIRECTORY_NAME" .tar.gz) # mariadb-11.3.2
MARIADB_FILE_INSTALL_LOCATION="/opt/mariadb"

function install_libs_for_mariadb_with_apt {
    sudo apt-get update
    echo "Installing packages for mariaDB"
    sudo apt-get install cmake gnutls-dev build-essential libncurses5-dev zlib1g-dev -y
    echo "Finished installing packages for mariaDB"
}

function clear_mariadb_source_code_files {
    sudo rm "$MARIADB_SOURCE_DIRECTORY_NAME"
    sudo rm -rf "$MARIADB_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION"
}

function download_mariadb_source_code {
    curl -O "$MARIADB_SOURCE_CODE_URL"
}

function extract_mariadb_source_code {
    tar xvf "$MARIADB_SOURCE_DIRECTORY_NAME"
}

function compile_mariadb_source_code {
    cd "./$MARIADB_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION" || exit
    # sudo cmake .
    sudo cmake . -DCMAKE_INSTALL_PREFIX:PATH="/opt/mariadb"
    # sudo cmake . -CMAKE_INSTALL_PREFIX="/opt/mariadb/"
    # sudo ./configure --prefix="$MARIADB_FILE_INSTALL_LOCATION"
    sudo make -j "$(nproc)" # print the number of processing units available
    sudo make -j "$(nproc)"
    
    sudo groupadd mysql
    sudo useradd -r -g mysql mysql
    # sudo chown -R mysql:mysql .
    sudo /opt/mariadb/scripts/mysql_install_db --user=mysql
    
    sudo chown -R root .
    # sudo chown -R mysql data
    sudo /opt/mariadb/bin/mariadbd-safe
    #sudo /opt/mariadb/bin/mariadb
}

function install_mariadb {
    #install_libs_for_mariadb_with_apt
    download_mariadb_source_code
    extract_mariadb_source_code
    compile_mariadb_source_code
    clear_mariadb_source_code_files
}

function test_if_mariadb_is_found {
    response=$(/opt/mariadb/bin/mariadb --version)
    if [[ "$response" == "/opt/mariadb/bin/mariadb from 11.3.2-MariaDB, client 15.2 for Linux (x86_64) using readline 5.1" ]]; then
        echo "MariaDB found"
        IS_MARIADB_FOUND=true
    else
        echo "MariaDB not found"
    fi
}

function check_who_is_running {
    echo "##########################################################################"
    echo "Checking if everything was installed..."
    test_if_apache_works
    test_if_php_exists
    test_if_mariadb_is_found
    echo "##########################################################################"
}

function install_needed_packages {
    echo "Installing all needed packages"
    sudo apt-get update
    # ORIGINAL
    # sudo apt-get install bzip2 gcc make libpcre3 libpcre3-dev libapr1-dev libaprutil1-dev pkg-config libxml2-dev libsqlite3-dev cmake gnutls-dev build-essential libncurses5-dev zlib1g-dev cmake gnutls-dev build-essential libncurses5-dev zlib1g-dev -y
    # NEW
    sudo apt install bzip2 libapr1-dev libaprutil1-dev gcc libpcre3 libpcre3-dev make libxml2-dev libsqlite3-dev cmake build-essential -y
    echo "Finished installing"
}

function remove_installed_packages {
    echo "Removing all installed packages"
    sudo apt remove bzip2 gcc make libpcre3 libpcre3-dev libapr1-dev libaprutil1-dev pkg-config libxml2-dev libsqlite3-dev cmake gnutls-dev build-essential libncurses5-dev zlib1g-dev cmake gnutls-dev build-essential libncurses5-dev zlib1g-dev -y
    echo "Finished removing"
}

check_if_running_as_root
clear_opt_dir
install_needed_packages
#install_apache
#clear_apache_source_code_files
# install_php
# install_libs_for_apache_with_apt
# install_libs_for_php_with_apt
# install_libs_for_mariadb_with_apt
#install_needed_packages
install_mariadb
# remove_installed_packages
#check_who_is_running

rm /home/hakl8025/UNIX24-TASK2/httpd-2.4.59.tar.bz2
rm -rf /home/hakl8025/UNIX24-TASK2/httpd-2.4.59

rm /home/hakl8025/UNIX24-TASK2/php-8.3.4.tar.gz
rm -rf /home/hakl8025/UNIX24-TASK2/php-8.3.4

end=$(date +%s)
runtime=$((end-start))
echo "Script took $((runtime / 60)) minutes and $((runtime % 60)) seconds to run."

current_date=$(date +"%Y-%m-%d")
current_time=$(date +"%T")
echo "Script ended"
echo "Current date: $current_date"
echo "Current time: $current_time"
