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
# With improvements from The_Compiler and tommie, thanks!


IPADDR="127.0.0.99"
URL="http://pgl.yoyo.org/adservers/serverlist.php?showintro=0;hostformat=hosts;mimetype=plaintext;useip=$IPADDR"
ALSO="r.admob.com dev.dolphin-browser.com ads.aapl.shazamid.com"

VERSION="0.23"

REMOVE_ONLY=0

if [ "$1" = "remove" ]; then
    REMOVE_ONLY=1
    shift
fi

HOSTFILE=${1:-/etc/hosts}

# detect mountpoint of the host file
ETC_MOUNT="$(df -P "$HOSTFILE" | awk 'NR==2 { print $6 }')"

#################################################
set -e

echo "starting adfree v${VERSION}..."

is_rw() {
    awk -vD="$ETC_MOUNT" '$2 == D && $4 ~/(^|,)rw(,|$)/ {RW=1} END{exit ! RW}' /proc/mounts
}

REMOUNTED=0
is_rw || { mount "$ETC_MOUNT" -o remount,rw; REMOUNTED=1; }

# better be safe than sorry...
is_rw || { echo "Unable to gain write access to $ETC_MOUNT, aborting" >&2; exit 1; }

# remove old adfree entries
echo "Removing ADFREE entries from $HOSTFILE"
sed -i '/^### ADFREE DATA BEGIN ###$/,/^### ADFREE DATA END ###$/ d' "$HOSTFILE"

if [ "$REMOVE_ONLY" -ne 1 ]; then
    echo "Adding new ADFREE entries to $HOSTFILE"
    {
        # print new ADFREE header
        echo "### ADFREE DATA BEGIN ###"
        echo "# last adfree v$VERSION run: $(date)"

        for host in $ALSO; do
            echo "$IPADDR $host"
        done

        echo -e "\n# entries retrieved from $URL"

        wget -O- "$URL" 2>&3

        echo "### ADFREE DATA END ###"
    } 3>&1 >> "$HOSTFILE"
fi

# mount directory read-only if it was at the beginning
[ "$REMOUNTED" -eq 1 ] && mount "$ETC_MOUNT" -o remount,ro

echo "done."
