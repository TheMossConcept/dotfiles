#!/bin/bash
# Installs and starts forticlient-dns-restore.service (see the forticlient-dns-restore script
# next to this file for what it does). Safe to re-run. Run as root:
#   sudo ~/.homesick/repos/dotfiles/home/.config/forticlient-dns-restore/install.sh
set -euo pipefail
trap 'echo "ERROR: line $LINENO: $BASH_COMMAND" >&2' ERR

if [[ $EUID -ne 0 ]]; then
    echo "Run this script as root (with sudo)" >&2
    exit 1
fi

# Resolve symlinks so this works both from the dotfiles repo and from the homeshick link in ~/.config
SOURCE_DIR="$(dirname "$(readlink -f "$0")")"
SCRIPT_SOURCE="$SOURCE_DIR/forticlient-dns-restore"
UNIT_SOURCE="$SOURCE_DIR/forticlient-dns-restore.service"
SCRIPT_TARGET=/usr/local/bin/forticlient-dns-restore
UNIT_TARGET=/etc/systemd/system/forticlient-dns-restore.service
UNIT=forticlient-dns-restore.service

# Copied (not linked) so that a root service never runs a script the user can modify
install -m 755 "$SCRIPT_SOURCE" "$SCRIPT_TARGET"
install -m 644 "$UNIT_SOURCE" "$UNIT_TARGET"
systemctl daemon-reload
systemctl enable "$UNIT"
systemctl restart "$UNIT"

# Verify: installed files match the sources, and the service is enabled and stays running
sleep 2
cmp "$SCRIPT_SOURCE" "$SCRIPT_TARGET"
cmp "$UNIT_SOURCE" "$UNIT_TARGET"
systemctl is-enabled "$UNIT"
systemctl is-active "$UNIT"
journalctl -u "$UNIT" --no-pager -n 5
echo "OK: $UNIT is installed, enabled and running"
