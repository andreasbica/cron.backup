#!/bin/bash
set -e

read -p "If you want to clone from [/] (root) to [/mnt/clone-root/], type [y]: " runSetup

if [ "$runSetup" != "y" ]; then
	echo "clone cancelled!"
	exit 1;
fi

#sudo rsync -aAXHvn --dry-run --delete --progress \
sudo rsync -aAXHv --delete --progress \
  / --exclude-from=/root/cron.backup/clone-root-exclude.txt \
  /mnt/clone-root/

echo 'clone finished'
echo ''