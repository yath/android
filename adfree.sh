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

REMOVE_ONLY=0

if [ "$1" = "remove" ]; then
    REMOVE_ONLY=1
    shift
fi

HOSTFILE=${1:-/etc/hosts}

#################################################
set -e

echo "starting..."

is_rw() {
    awk '$2 == "/system" && $4 ~/(^|,)rw(,|$)/ {RW=1} END{exit ! RW}' /proc/mounts
}

REMOUNTED=0
is_rw || { mount /system -o remount,rw; REMOUNTED=1; }

# better be safe than sorry...
is_rw || { echo "Unable to gain write access to /system, aborting" >&2; exit 1; }

# remove old adfree entries
echo "Removing ADFREE entries from $HOSTFILE"
sed -i '/^### ADFREE DATA BEGIN ###$/,/^### ADFREE DATA END ###$/ d' "$HOSTFILE"

if [ "$REMOVE_ONLY" -ne 1 ]; then
    # print new ADFREE header
    echo "Adding new ADFREE entries to $HOSTFILE"
    echo "### ADFREE DATA BEGIN ###" >> "$HOSTFILE"
    echo -n "# last adfree run: " >> "$HOSTFILE"
    date >> "$HOSTFILE"
    echo "" >> "$HOSTFILE"

    for host in $ALSO; do
        echo "$IPADDR $host" >> "$HOSTFILE"
    done
    echo -e "\n# entries retrieved from $URL" >> "$HOSTFILE"

    { wget -O- "$URL" >> "$HOSTFILE"; } 2>&1

    echo "### ADFREE DATA END ###" >> "$HOSTFILE"
fi

# mount /system read-only if it was at the beginning
[ "$REMOUNTED" -eq 1 ] && mount /system -o remount,ro

echo "done."
