#!/bin/sh
set -eu

module_name=tas58xx
module_version=1.0.0
dkms_source_dir=/usr/src/${module_name}-${module_version}

if [ "$(id -u)" -ne 0 ]; then
	printf '%s\n' "Run this uninstaller as root (for example: sudo ./uninstall-dkms.sh)." >&2
	exit 1
fi

if command -v dkms >/dev/null 2>&1 && \
	dkms status -m "$module_name" -v "$module_version" 2>/dev/null | grep -q .; then
	dkms remove -m "$module_name" -v "$module_version" --all
fi

if [ -d "$dkms_source_dir" ]; then
	find "$dkms_source_dir" -depth -delete
fi

printf '%s\n' "Removed ${module_name}/${module_version} from DKMS."
