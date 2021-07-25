#!/bin/bash
set -e

if [ "$EUID" -ne 0 ]
        then echo "Must be run as root"
        exit 1
fi

usr/sbin/tripwire --check

