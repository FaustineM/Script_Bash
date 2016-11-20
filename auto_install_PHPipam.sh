#!/bin/bash

# phpipam is an open-source web IP addresses management application (IPAM)

# Using variables for URL and path in order to facilitate updates

# Download link
ARCHIVE_URL="http://netcologne.dl.sourceforge.net/project/phpipam/phpipam-1.2.1.tar"
HTDOCS_PATH=/var/www/html
WWW_SUBFOLDER="phpipam"
INSTALL_PATH="$HTDOCS_PATH/$WWW_SUBFOLDER" 

SRC_CONFIG="$INSTALL_PATH/config.dist.php"
DST_CONFIG="$INSTALL_PATH/config.php"

TMP_FOLDER=$(mktemp -d)

DOWNLOAD_PATH="$TMP_FOLDER/phpipam.tar"

### Manage PHP settings ###

PHP_TIME_OK=$(grep -v ";" /etc/php.ini | grep date.timezone | wc -l)

if [ $PHP_TIME_OK -eq 0 ]
then
        sed -i.bck 's/;date.timezone =/date.timezone = UTC/g' /etc/php.ini
fi

### Manage depenencies ###

yum install -y php-pear php-cli php-ldap

### Download archive ###

curl -L "$ARCHIVE_URL" > "$DOWNLOAD_PATH"
mkdir "$INSTALL_PATH"
tar xvf "$DOWNLOAD_PATH" --strip-components=1 -C "$INSTALL_PATH"

### Configure database ###

DB_USER=ipamuser
DB_PASS=0miU1eWL1KNiA8wF
DB_NAME=ipam
BASE_URL="/$WWW_SUBFOLDER/"

# EOF tags indicate beginning and end of other language use (SQL)
mysql -u root -p << EOF
CREATE DATABASE $DB_NAME;
CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
grant ALL PRIVILEGES on $DB_NAME.* to '$DB_USER'@'localhost' ;
FLUSH PRIVILEGES;
EOF

mysql -u $DB_USER --password=$DB_PASS $DB_NAME < "$INSTALL_PATH/db/SCHEMA.sql"

echo "s#define('BASE', \"/\");#define('BASE', \"$BASE_URL\");#g" > "$TMP_FOLDER/phpipam.config.sed"
echo "s#\$db\['user'\] = \"phpipam\";#\$db\['user'\] = \"$DB_USER\";#g" >> "$TMP_FOLDER/phpipam.config.sed"
echo "s#\$db\['pass'\] = \"phpipamadmin\";#\$db\['pass'\] = \"$DB_PASS\";#g" >> "$TMP_FOLDER/phpipam.config.sed"
echo "s#\$db\['name'\] = \"phpipam\";#\$db\['name'\] = \"$DB_NAME\";#g" >> "$TMP_FOLDER/phpipam.config.sed"

cp "$SRC_CONFIG" "$DST_CONFIG" 

sed -f "$TMP_FOLDER/phpipam.config.sed" -i.bck "$DST_CONFIG"

rm -rf "$TMP_FOLDER"

apachectl restart

exit 0