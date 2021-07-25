#!/bin/bash
set -e

if [ "$EUID" -ne 0 ]
        then echo "Must be run as root"
        exit 1
fi

REPORT_FILE=$(ls -dt /var/lib/tripwire/report/*|head -n1)
echo "Showing the content of ${REPORT_FILE}"
echo
twprint -m r --twrfile ${REPORT_FILE}


