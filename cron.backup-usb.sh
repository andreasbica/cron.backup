#!/bin/bash
set -e

. /root/cron.backup/disklist.ini
logf="/var/log/cron-backup.log";

echo 'start rsync >' `date -u` > $logf
echo "" >> $logf

if [ "$disk1" == "" ] || [ "$disk2" == "" ]; then
  echo "skipped. uuid empty."
  echo 'error: rsync skipped. uuid of disk 1 or 2 empty.' >> $logf

else
  echo "determine I/O load ..." >> $logf
  echo "I/O allowed max. load to process backup = 2.5" >> $logf

  detectedLoad=$(echo "$(top -bn2 | grep -o -E "[[:digit:]]*\.[[:digit:]] wa" | tr -d ' wa' | tail -1)");

  echo "I/O load = $detectedLoad"
  echo "I/O load detected = $detectedLoad" >> $logf
  echo "" >> $logf

  load=$(awk '{print $1*$2}' <<< "$detectedLoad 100");

  if [ $load -gt 250 ]; then
    echo "rsync skipped. I/O to busy."
    echo "rsync skipped. I/O to busy." >> $logf
  else
    if curl -s -I http://localhost/index.php/login | grep -q "200 OK"; then
      dlist=$(blkid);
      foundDisk1=$(echo "$(grep "$disk1" <<< "$dlist")");
      foundDisk2=$(echo "$(grep "$disk2" <<< "$dlist")");
      if [ "$foundDisk1" != "" ] && [ "$foundDisk2" != "" ]; then
        echo 'backup ...'
        sudo rsync -av --delete --exclude-from=/root/cron.backup/rsync-exclude-backup-usb.txt /data/* /data-backup/ >> $logf
      else
        echo "skipped. disk 1 or 2 not found."
        echo 'error: rsync skipped. uuid of disk 1 or 2 not found.' >> $logf
      fi
    else
      echo "rsync skipped. nextcloud not reachable."
      echo "rsync skipped. nextcloud not reachable." >> $logf
    fi
  fi

fi

echo "" >> $logf
echo 'end rsync >' `date -u` >> $logf