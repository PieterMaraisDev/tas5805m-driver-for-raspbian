#!/bin/sh
set -eu

module_name=tas58xx
module_version=1.0.0
kernel_version=${1:-$(uname -r)}
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
dkms_source_dir=/usr/src/${module_name}-${module_version}

if [ "$(id -u)" -ne 0 ]; then
	printf '%s\n' "Run this installer as root (for example: sudo ./install-dkms.sh)." >&2
	exit 1
fi

if ! command -v dkms >/dev/null 2>&1; then
	printf '%s\n' "dkms is not installed. On Ubuntu, run: apt install dkms linux-headers-${kernel_version}" >&2
	exit 1
fi

if [ ! -d "/lib/modules/${kernel_version}/build" ]; then
	printf '%s\n' "Kernel headers for ${kernel_version} are missing." >&2
	printf '%s\n' "On Ubuntu, run: apt install linux-headers-${kernel_version}" >&2
	exit 1
fi

# Remove this exact revision before refreshing its source. This makes rerunning
# the installer safe after editing the driver locally.
if dkms status -m "$module_name" -v "$module_version" 2>/dev/null | grep -q .; then
	dkms remove -m "$module_name" -v "$module_version" --all
fi

install -d -m 0755 "$dkms_source_dir/eq"
install -m 0644 "$script_dir/Makefile" "$dkms_source_dir/Makefile"
install -m 0644 "$script_dir/dkms.conf" "$dkms_source_dir/dkms.conf"
install -m 0644 "$script_dir/tas58xx.c" "$dkms_source_dir/tas58xx.c"
install -m 0644 "$script_dir/tas58xx.h" "$dkms_source_dir/tas58xx.h"
install -m 0644 "$script_dir"/eq/*.h "$dkms_source_dir/eq/"

dkms add -m "$module_name" -v "$module_version"
dkms build -m "$module_name" -v "$module_version" -k "$kernel_version"
dkms install -m "$module_name" -v "$module_version" -k "$kernel_version"

printf '%s\n' "Installed ${module_name}/${module_version} for kernel ${kernel_version}."
printf '%s\n' "DKMS will rebuild it automatically when a kernel and matching headers are installed."
