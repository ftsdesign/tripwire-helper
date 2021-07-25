# Tripwire helper

A simple set of tools to help setting up a read-only volume for tripwire, to ensure the keys and executable are not compromised.

## Prerequisites

Tripwire should already be installed on your system. Consult the documentation here if you need any help <https://github.com/Tripwire/tripwire-open-source>

## How to use

1. Mount your volume as read-write. You will need to always use the same mounting point.
1. Copy `*.sh` files to the root of the volume
1. `cd volume_root`
1. Run `sudo ./setup-tw-ro.sh` and follow the instructions. This will:
	1. Create a copy of tripwire configuration
	1. Modify the copy to make it point to your volume
	1. Sign it and replace tripwire configuration
	1. Regenerate the database
1. Unmount your volume
1. Mount your volume as read-only
1. `cd volume_root`
1. Run `sudo ./check.sh` to run the check
1. Run `sudo ./show-latest-report.sh` to see the latest report stored on your machine
