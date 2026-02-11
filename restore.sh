#!/bin/bash
set -e

read -p "If you want to restore from /mnt/backup/*, type [y]: " runSetup

if [ "$runSetup" != "y" ]; then
	echo "restore cancelled!"
	exit 1;
fi

echo 'start rsync restore [/mnt/backup/*] ...'
echo ''

echo 'restore [/mnt/backup/www/data/ > /var/www/data/] ...'
sudo rsync -av --progress /mnt/backup/www/data/ /var/www/data/
echo ''

echo 'restore [/mnt/backup/www/html/nextcloud/ > /var/www/html/nextcloud/] ...'
sudo rsync -av --progress /mnt/backup/www/html/nextcloud/ /var/www/html/nextcloud/
echo ''

echo 'restore [/mnt/backup/mysql/ > /var/lib/mysql/] ...'
sudo rsync -av --progress /mnt/backup/mysql/ /var/lib/mysql/
echo ''

echo 'restore finished'
echo ''