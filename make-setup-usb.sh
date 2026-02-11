#!/bin/bash
set -e

dlist=$(blkid);

echo ""
echo "cron.backup disk list:"
grep "/dev/sd*" <<< $dlist;
echo ""

read -p "UUID disk1 for mount of nextcloud-data (/data): " disk1

if [ "$disk1" == "" ]; then
	echo "exit: UUID disk1 can not be empty!"
	exit 1;
fi
foundDisk1=$(echo "$(grep "$disk1" <<< "$dlist")");
if [ "$foundDisk1" == "" ]; then
	echo 'exit: disk1 not found.'
	exit 1;
fi

read -p "UUID disk2 for mount of nextcloud-data-backup (/data-backup): " disk2

if [ "$disk1" == "$disk2" ]; then
	echo 'exit: uuid disk1 and disk2 can not be the same.'
	exit 1;
elif [ ! "$disk2" == "" ]; then
	foundDisk2=$(echo "$(grep "$disk2" <<< "$dlist")");
	if [ "$foundDisk2" == "" ]; then
		echo 'exit: disk2 not found.'
		exit 1;
	fi
fi

read -p "If you want to setup, type [y]: " runSetup

if [ "$runSetup" != "y" ]; then
	echo "setup cancelled!"
	exit 1;
fi

fstabf="/etc/fstab";
dlf="/root/cron.backup/disklist.ini";

echo "disk1=\"$disk1\";" > $dlf;
echo "disk2=\"$disk2\";" >> $dlf;
chmod 600 $dlf;

if ! [ -f "${fstabf}.default" ]; then
	echo "creating fstab backup ..."
	cp "$fstabf" "${fstabf}.default"
else
	echo "prepare fstab ..."
	cp -f "${fstabf}.default" $fstabf
fi

echo "UUID=$disk1   /data   ext4   defaults,nofail   0   0" >> $fstabf;

if [ ! "$disk2" == "" ]; then
	echo "UUID=$disk2   /data-backup   ext4   defaults,nofail   0   0" >> $fstabf;
fi

echo "done."
