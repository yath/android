#!/system/bin/sh

# released under beer-ware license (http://en.wikipedia.org/wiki/Beerware).
# if you have app2sd, put this script to /system/sd, else to /data, chmod +x
# it, install gscript (available in the market) and create a script with the
# content "exec </path/to/this/script.sh>".
#
# change IPADDR below if you use 127.0.0.99 for anything else in your
# /etc/hosts.
#
# -- Sebastian Schmidt <yath@yath.de>, 1261118200 seconds from epoch
#
# With some improvements from The_Compiler, thanks!


IPADDR="127.0.0.99"
URL="http://pgl.yoyo.org/adservers/serverlist.php?showintro=0;hostformat=hosts;mimetype=plaintext;useip=$IPADDR"
ALSO="r.admob.com dev.dolphin-browser.com"

#################################################
set -e

echo "starting..."

grep -q '[^ ]* /system [^ ]* rw' /proc/mounts && isrw=1

[ -z "$isrw" ] && mount /system -o remount,rw

grep -vF "$IPADDR" /etc/hosts > /etc/hosts.new

{ wget -O- "$URL" | grep "^[0-9]" >> /etc/hosts.new; } 2>&1

for host in $ALSO; do
    echo "$IPADDR $host" >> /etc/hosts.new
done

cp /etc/hosts.new /etc/hosts && rm /etc/hosts.new

[ -z "$isrw" ] && mount /system -o remount,ro

echo "done."
