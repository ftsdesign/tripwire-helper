#!/bin/bash
set -e

if [ "$EUID" -ne 0 ]
	then echo "Must be run as root"
	exit 1
fi

HOST=$(hostname)
echo "Initial setup of read-only Tripwire volume for ${HOST}, ENTER to continue or Ctrl-C to abort"
read INPUT

RO_ROOT=$(pwd)
echo "Tripwire read-only volume will need to be mounted as ${RO_ROOT}, ENTER to continue or Ctrl-C to abort"
read INPUT

mkdir -v -p etc/tripwire
cp -v /etc/tripwire/* etc/tripwire

mkdir -v -p usr/sbin
cp -v /usr/sbin/tripwire usr/sbin

mkdir -v -p var/lib/tripwire
cp -v -r /var/lib/tripwire/* var/lib/tripwire

echo
echo "Modifying the configuration..."
CFG_FILE_SIGNED="tw.cfg"
CFG_FILE_NEW="twcfg.txt"
CFG_FILE_ORIG="twcfg.txt.orig"
rm -vf ${CFG_FILE_SIGNED} ${CFG_FILE_NEW} ${CFG_FILE_ORIG}
twadmin --print-cfgfile > ${CFG_FILE_ORIG}
cp -v ${CFG_FILE_ORIG} ${CFG_FILE_NEW}

KEY="ROOT"
VAL="${RO_ROOT}/usr/sbin"
grep -q ${KEY} ${CFG_FILE_NEW} || (echo "Key ${KEY} not found"; exit 1)
echo "Setting ${KEY} to ${VAL}"
sed -i "s!^${KEY}.*!${KEY}=${VAL}!" ${CFG_FILE_NEW}

KEY="SITEKEYFILE"
VAL="${RO_ROOT}/etc/tripwire/site.key"
grep -q ${KEY} ${CFG_FILE_NEW} || (echo "Key ${KEY} not found"; exit 1)
echo "Setting ${KEY} to ${VAL}"
sed -i "s!^${KEY}.*!${KEY}=${VAL}!" ${CFG_FILE_NEW}

KEY="LOCALKEYFILE"
VAL="${RO_ROOT}/etc/tripwire/${HOST}-local.key"
grep -q ${KEY} ${CFG_FILE_NEW} || (echo "Key ${KEY} not found"; exit 1)
echo "Setting ${KEY} to ${VAL}"
sed -i "s!^${KEY}.*!${KEY}=${VAL}!" ${CFG_FILE_NEW}

echo
echo "New Tripwire config:"
echo
cat ${CFG_FILE_NEW}
echo
echo "Press ENTER to confirm the new config above, or Ctrl-C to abort"
read INPUT

SITE_KEY="etc/tripwire/site.key"
twadmin --create-cfgfile --cfgfile ${CFG_FILE_SIGNED} --site-keyfile $SITE_KEY -v ${CFG_FILE_NEW}
cp -v ${CFG_FILE_SIGNED} /etc/tripwire
cp -v ${CFG_FILE_SIGNED}  etc/tripwire
cp -v ${CFG_FILE_NEW} /etc/tripwire
cp -v ${CFG_FILE_NEW}  etc/tripwire

echo "Initializing Tripwire database..."
usr/sbin/tripwire --init

echo "Tripwire read-only volume setup completed successfully"
