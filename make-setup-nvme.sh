#!/bin/bash
set -e

dlist=$(blkid);

echo ""
echo "cron.backup disk list:"
grep "/dev/nvme1n*" <<< $dlist;
echo ""

read -p "UUID to mount backup disk (/mnt/backup): " disk1

if [ "$disk1" == "" ]; then
  echo "exit: UUID backup disk can not be empty!"
  exit 1;
fi
foundDisk1=$(echo "$(grep "$disk1" <<< "$dlist")");
if [ "$foundDisk1" == "" ]; then
  echo 'exit: backup disk not found.'
  exit 1;
fi

read -p "If you want to setup, type [y]: " runSetup

if [ "$runSetup" != "y" ]; then
  echo "setup cancelled!"
  exit 1;
fi

fstabf="/etc/fstab";
dlf="/root/cron.backup/disklist.ini";

echo "disk1=\"$disk1\";" > $dlf;
chmod 600 $dlf;

if ! [ -f "${fstabf}.default" ]; then
  echo "creating fstab backup ..."
  cp "$fstabf" "${fstabf}.default"
else
  echo "prepare fstab ..."
  cp -f "${fstabf}.default" $fstabf
fi

echo "UUID=$disk1   /mnt/backup   ext4   defaults,nofail   0   0" >> $fstabf;
echo "done."