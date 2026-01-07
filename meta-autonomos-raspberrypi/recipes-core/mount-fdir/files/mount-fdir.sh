#!/bin/sh
# mount-fdir.sh - Mount Fault Detection, Isolation, and Recovery
#
# Verifies critical mounts are available, retrying if necessary.
# Designed for embedded systems where storage may be slow or flaky.
#
# Configuration: /etc/mount-fdir.conf
#   MOUNT_FDIR_MOUNTS - space-separated list of mount points to verify
#   MOUNT_FDIR_RETRIES - number of retry attempts (default: 3)
#   MOUNT_FDIR_DELAY - seconds between retries (default: 2)

set -e

CONF_FILE="/etc/mount-fdir.conf"

# Defaults
MOUNT_FDIR_MOUNTS=""
MOUNT_FDIR_RETRIES=3
MOUNT_FDIR_DELAY=2

# Load configuration
if [ -f "$CONF_FILE" ]; then
    . "$CONF_FILE"
fi

if [ -z "$MOUNT_FDIR_MOUNTS" ]; then
    echo "mount-fdir: No mounts configured in $CONF_FILE, nothing to verify"
    exit 0
fi

# Track failures
FAILED_MOUNTS=""

for mount_point in $MOUNT_FDIR_MOUNTS; do
    echo "mount-fdir: Verifying $mount_point"

    attempt=0
    mounted=false

    while [ $attempt -lt $MOUNT_FDIR_RETRIES ]; do
        attempt=$((attempt + 1))

        if mountpoint -q "$mount_point" 2>/dev/null; then
            echo "mount-fdir: $mount_point is mounted"
            mounted=true
            break
        fi

        echo "mount-fdir: $mount_point not mounted (attempt $attempt/$MOUNT_FDIR_RETRIES)"

        # Try to mount it
        if mount "$mount_point" 2>/dev/null; then
            echo "mount-fdir: Successfully mounted $mount_point"
            mounted=true
            break
        fi

        if [ $attempt -lt $MOUNT_FDIR_RETRIES ]; then
            echo "mount-fdir: Retrying in ${MOUNT_FDIR_DELAY}s..."
            sleep $MOUNT_FDIR_DELAY
        fi
    done

    if [ "$mounted" = false ]; then
        echo "mount-fdir: CRITICAL - Failed to mount $mount_point after $MOUNT_FDIR_RETRIES attempts" >&2
        FAILED_MOUNTS="$FAILED_MOUNTS $mount_point"
    fi
done

if [ -n "$FAILED_MOUNTS" ]; then
    echo "mount-fdir: CRITICAL - The following mounts failed:$FAILED_MOUNTS" >&2
    echo "mount-fdir: System will continue in DEGRADED state" >&2
    # Exit with error but don't prevent boot - let dependent services handle degradation
    exit 1
fi

echo "mount-fdir: All mounts verified successfully"
exit 0
