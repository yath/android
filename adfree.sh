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
ALSO="r.admob.com dev.dolphin-browser.com ads.aapl.shazamid.com"

#################################################
set -e

echo "starting..."

is_rw() {
    awk '$2 == "/system" && $4 ~/(^|,)rw(,|$)/ {RW=1} END{exit ! RW}' /proc/mounts
}

is_rw || mount /system -o remount,rw

# better be safe than sorry...
is_rw || { echo "Unable to gain write access to /system, aborting" >&2; exit 1; }

grep -vF "$IPADDR" /etc/hosts > /etc/hosts.new

for host in $ALSO; do
    echo "$IPADDR $host" >> /etc/hosts.new
done

{ wget -O- "$URL" | grep "^[0-9]" >> /etc/hosts.new; } 2>&1

cp /etc/hosts.new /etc/hosts && rm /etc/hosts.new

is_rw && mount /system -o remount,ro

echo "done."
