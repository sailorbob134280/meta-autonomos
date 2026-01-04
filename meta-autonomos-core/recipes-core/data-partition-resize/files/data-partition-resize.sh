#!/bin/sh
# Resize the data partition to fill available space
# This runs once at first boot

set -e

MARKER_FILE="/data/.partition-resized"
DATA_LABEL="data"

# Skip if already resized
if [ -f "$MARKER_FILE" ]; then
    echo "Data partition already resized, skipping."
    exit 0
fi

# Find the device for the data partition by label
DATA_DEV=$(findfs LABEL="$DATA_LABEL" 2>/dev/null) || true

if [ -z "$DATA_DEV" ]; then
    echo "ERROR: Could not find partition with label '$DATA_LABEL'"
    exit 1
fi

echo "Found data partition: $DATA_DEV"

# Extract the disk device and partition number
# e.g., /dev/mmcblk0p4 -> /dev/mmcblk0 and 4
case "$DATA_DEV" in
    /dev/mmcblk*p*)
        DISK_DEV=$(echo "$DATA_DEV" | sed 's/p[0-9]*$//')
        PART_NUM=$(echo "$DATA_DEV" | sed 's/.*p//')
        ;;
    /dev/sd*[0-9])
        DISK_DEV=$(echo "$DATA_DEV" | sed 's/[0-9]*$//')
        PART_NUM=$(echo "$DATA_DEV" | sed 's/.*[a-z]//')
        ;;
    /dev/nvme*p*)
        DISK_DEV=$(echo "$DATA_DEV" | sed 's/p[0-9]*$//')
        PART_NUM=$(echo "$DATA_DEV" | sed 's/.*p//')
        ;;
    *)
        echo "ERROR: Unsupported device naming scheme: $DATA_DEV"
        exit 1
        ;;
esac

echo "Disk device: $DISK_DEV, partition number: $PART_NUM"

# Get current partition end and disk size
CURRENT_END=$(parted -s "$DISK_DEV" unit s print | grep "^ *$PART_NUM " | awk '{print $3}' | tr -d 's')
DISK_SIZE=$(parted -s "$DISK_DEV" unit s print | grep "^Disk $DISK_DEV" | awk '{print $3}' | tr -d 's')

# Leave a small margin at the end (34 sectors for GPT backup)
MAX_END=$((DISK_SIZE - 34))

echo "Current partition end: ${CURRENT_END}s, max end: ${MAX_END}s"

if [ "$CURRENT_END" -ge "$MAX_END" ]; then
    echo "Partition already at maximum size."
else
    # Grow the partition to fill remaining space
    # Use yes piped to parted with ---pretend-input-tty to handle "partition is in use" warning
    # Note: -s flag conflicts with ---pretend-input-tty, so we omit it
    echo "Growing partition to fill disk..."
    yes | parted ---pretend-input-tty "$DISK_DEV" resizepart "$PART_NUM" 100%

    # Inform kernel of partition table change
    partprobe "$DISK_DEV" || true
    sleep 1
fi

# Resize the ext4 filesystem
echo "Resizing filesystem..."
resize2fs "$DATA_DEV"

# Create marker file to prevent running again
echo "Resize completed at $(date -Iseconds)" > "$MARKER_FILE"
echo "Data partition resize complete."
