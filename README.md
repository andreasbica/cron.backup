# Setup for Raspberry Pi external data backup disk

## login to your Pi as root

Setup your data backup disk.

```
cd /root
wget -O- https://github.com/andreasbica/cron.backup/archive/latest.tar.gz | tar --transform 's/cron.backup-latest/cron.backup/' -xvz
chmod 700 cron.backup -R
```

```
bash cron.backup/make-setup.sh
reboot
```

## config cron

`crontab -u root -e`

Add this line

`*/30 * * * * sudo bash /root/cron.backup/cron.backup.sh`

## see the log

`less /var/log/cron-backup.log`
