#!/bin/bash
set -e

. /root/cron.backup/disklist.ini
logf="/var/log/cron-backup.log";

echo 'start rsync >' `date -u` > $logf
echo "" >> $logf

if [ "$disk1" == "" ]; then
  echo "skipped. uuid empty."
  echo 'error: rsync skipped. uuid of backup disk empty.' >> $logf

else
  echo "determine I/O load ..." >> $logf
  echo "I/O allowed max. load to process backup = 2.5" >> $logf

  detectedLoad=$(echo "$(top -bn2 | grep -o -E "[[:digit:]]*\.[[:digit:]] wa" | tr -d ' wa' | tail -1)");

  echo "I/O load = $detectedLoad"
  echo "I/O load detected = $detectedLoad" >> $logf
  echo ""
  echo "" >> $logf

  load=$(awk '{print $1*$2}' <<< "$detectedLoad 100");

  if [ $load -gt 250 ]; then
    echo "rsync skipped. I/O to busy."
    echo "rsync skipped. I/O to busy." >> $logf

  else
    if curl -s -I http://localhost/index.php/login | grep -q "200 OK"; then
      dlist=$(blkid);
      foundDisk1=$(echo "$(grep "$disk1" <<< "$dlist")");
      if [ "$foundDisk1" != "" ]; then

        echo 'backup [/var/www/] ...'
        echo 'backup [/var/www/] ...' >> $logf
        time sudo rsync -aAXHv --delete --exclude-from=/root/cron.backup/rsync-exclude-backup-nvme.txt /var/www/ /mnt/backup/www/ >> $logf

        echo ""
        echo "" >> $logf

        echo 'backup [/var/lib/mysql/] ...'
        echo 'backup [/var/lib/mysql/] ...' >> $logf
        time sudo rsync -aAXHv --delete --inplace /var/lib/mysql/ /mnt/backup/mysql/ >> $logf

      else
        echo "skipped. backup disk not found."
        echo 'error: rsync skipped. uuid of backup disk not found.' >> $logf
      fi
    else
      echo "rsync skipped. nextcloud not reachable."
      echo "rsync skipped. nextcloud not reachable." >> $logf
    fi
  fi
fi

echo "" >> $logf
echo 'end rsync >' `date -u` >> $logf