#!/bin/bash

APR_VERSION="1.7.4"
EXPAT_VERSION="2.6.2"
APR_UTIL_VERSION="1.6.3"
APACHE_VERSION="2.4.59"
PHP_VERSION="8.3.4"
MARIADB_VERSION="11.3.2"


APACHE_SOURCE_CODE_URL="https://dlcdn.apache.org/httpd/httpd-"
TAR_BZ2_EXTENSION=".tar.bz2"
SHA256_EXTENSION=".sha256"
APACHE_SOURCE_CODE__FULL_URL="${APACHE_SOURCE_CODE_URL}${APACHE_VERSION}${TAR_BZ2_EXTENSION}"
APACHE_SOURCE_DIRECTORY_NAME="${APACHE_SOURCE_CODE__FULL_URL##*/}"
APACHE_SOURCE_DIRECTORY_NAME_WITHOUT_EXTENSION=$(basename "$APACHE_SOURCE_DIRECTORY_NAME" ${TAR_BZ2_EXTENSION})
APACHE_FILE_INSTALL_LOCATION="${PACKAGES_INSTALLATION_DIRECTORY}/apache-${APACHE_VERSION}"

wget -U "${USER_AGENT}" "$APACHE_SOURCE_CODE__FULL_URL"


SHA256_SUM_OF_REMOTE_APACHE_FILES=$(curl -s "${APACHE_SOURCE_CODE_URL}${APACHE_VERSION}${TAR_BZ2_EXTENSION}${SHA256_EXTENSION}" | cut -f -1 -d " ")

SHA256_SUM_OF_LOCAL_APACHE_FILES=$(sha256sum "${APACHE_SOURCE_DIRECTORY_NAME}" | cut -f -1 -d " ")

if [[ "${SHA256_SUM_OF_REMOTE_APACHE_FILES}" == "${SHA256_SUM_OF_LOCAL_APACHE_FILES}" ]]; then
    echo "Checksum matches"
else
    echo "Checksum does not match!"
    echo "Remote file checksum: |${SHA256_SUM_OF_REMOTE_APACHE_FILES}|"
    echo "Local file checksum:  |${SHA256_SUM_OF_LOCAL_APACHE_FILES}|"
fi


PHP_VERSION="8.3.4"

SHA256_SUM_OF_REMOTE_PHP_FILES=$(curl -s https://downloads.apache.org/httpd/httpd-${APACHE_VERSION}.tar.bz2.sha256 | cut -f -1 -d " ")

SHA256_SUM_OF_LOCAL_PHP_FILES=$(sha256sum httpd-${APACHE_VERSION}.tar.bz2 | cut -f -1 -d " ")

if [[ "${SHA256_SUM_OF_REMOTE_APACHE_FILES}" == "${SHA256_SUM_OF_LOCAL_APACHE_FILES}" ]]; then
    echo "Checksum matches"
else
    echo "Checksum does not match!"
    echo "Remote file checksum: |${SHA256_SUM_OF_REMOTE_APACHE_FILES}|"
    echo "Local file checksum:  |${SHA256_SUM_OF_LOCAL_APACHE_FILES}|"
fi