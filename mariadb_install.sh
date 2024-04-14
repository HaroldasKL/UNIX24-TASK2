
#!/bin/bash
start=$(date +%s)
current_date=$(date +"%Y-%m-%d")
current_time=$(date +"%T")
echo "Script started"
echo "Current date: $current_date"
echo "Current time: $current_time"
sudo apt-get update
sudo apt install bzip2 libapr1-dev libaprutil1-dev gcc libpcre3 libpcre3-dev make libxml2-dev libsqlite3-dev cmake build-essential libncurses5-dev gnutls-dev pkg-config zlib1g zlib1g-dev -y
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
sudo /opt/mariadb/bin/mariadbd-safe --datadir='/opt/mariadb/data'

end=$(date +%s)
runtime=$((end-start))
echo "Script took $((runtime / 60)) minutes and $((runtime % 60)) seconds to run."

current_date=$(date +"%Y-%m-%d")
current_time=$(date +"%T")
echo "Script ended"
echo "Current date: $current_date"
echo "Current time: $current_time"