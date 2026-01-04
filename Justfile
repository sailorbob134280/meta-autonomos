# AutonomOS Build and Deployment Commands
#
# This Justfile provides convenience commands for building AutonomOS images,
# managing RAUC OTA updates, and deploying to devices.
#
# Quick start:
#   just build              # Build the image
#   just flash /dev/sdX     # Flash to SD card
#   just rauc-status <ip>   # Check device RAUC status

set dotenv-load := true

# Default machine target
machine := env('MACHINE', 'raspberrypi5')

# Kas configuration
config := env('KAS_CONFIG', 'reference.yaml')

default: help

# Print this help message
help:
    @just --list

# === Build ===

# Build the AutonomOS image using kas-container
[group('build')]
build:
    kas-container build {{config}}

# Open a shell in the build environment
[group('build')]
shell:
    kas-container shell {{config}}

# === Clean ===

# Clean the build environment
[group('clean')]
clean:
    kas-container purge {{config}}

# Remove all build artifacts, sources, and start fresh
[group('clean')]
spotless: clean
    rm -rf build/
    rm -rf sources/

# === Flash/Deploy ===

# Flash WIC image to SD card
[group('deploy')]
[script('bash')]
flash device:
    IMAGE="build/tmp-{{machine}}/deploy/images/{{machine}}/autonomos-devel-{{machine}}.rootfs.wic.bz2"
    if [ ! -b "{{device}}" ]; then
        echo "Error: Device not found or not a block device: {{device}}"
        exit 1
    fi
    if [ ! -f "$IMAGE" ]; then
        echo "Error: Image not found: $IMAGE"
        echo "Did you run 'just build' first?"
        exit 1
    fi
    echo "Flashing $IMAGE to {{device}}..."
    echo "WARNING: This will overwrite all data on {{device}}!"
    read -p "Continue? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
    if command -v bmaptool &> /dev/null; then
        BMAP="${IMAGE%.bz2}.bmap"
        if [ -f "$BMAP" ]; then
            sudo bmaptool copy --bmap "$BMAP" "$IMAGE" {{device}}
        else
            echo "Warning: bmap file not found, bmaptool will be slower"
            sudo bmaptool copy "$IMAGE" {{device}}
        fi
    else
        echo "bmaptool not found, falling back to dd (slower)..."
        bzcat "$IMAGE" | sudo dd of={{device}} bs=4M status=progress conv=fsync,sparse
    fi
    sync
    echo "Done. Safe to eject {{device}}."

# === RAUC/OTA ===

# Directory for RAUC bundles
rauc-bundle-dir := "build/bundles"

# Development signing keys (override RAUC_CERT and RAUC_KEY for production)
rauc-cert := env('RAUC_CERT', 'meta-autonomos-core/files/rauc-example-keys/development.cert.pem')
rauc-key := env('RAUC_KEY', 'meta-autonomos-core/files/rauc-example-keys/development.key.pem')

# Convert RAUC bundle to casync format for delta updates
[group('ota')]
[script('bash')]
rauc-to-casync bundle:
    mkdir -p {{rauc-bundle-dir}}
    rauc convert \
        --cert={{rauc-cert}} \
        --key={{rauc-key}} \
        {{bundle}} \
        {{rauc-bundle-dir}}/$(basename {{bundle}} .raucb).caibx
    echo "Created casync bundle at {{rauc-bundle-dir}}/$(basename {{bundle}} .raucb).caibx"

# List new chunks between two casync stores (for delta upload)
[group('ota')]
[script('bash')]
casync-diff old-store new-store:
    comm -23 \
        <(ls {{new-store}}/default.castr/ 2>/dev/null | sort) \
        <(ls {{old-store}}/default.castr/ 2>/dev/null | sort)

# Copy only new chunks to staging directory for upload
[group('ota')]
[script('bash')]
casync-stage-delta old-store new-store staging-dir:
    mkdir -p {{staging-dir}}/default.castr
    NEW_CHUNKS=$(just casync-diff {{old-store}} {{new-store}})
    for chunk in $NEW_CHUNKS; do
        cp {{new-store}}/default.castr/$chunk {{staging-dir}}/default.castr/
    done
    echo "Staged $(ls {{staging-dir}}/default.castr 2>/dev/null | wc -l) new chunks"

# Show casync chunk store statistics
[group('ota')]
[script('bash')]
casync-stats store:
    CHUNKS=$(ls {{store}}/default.castr/ 2>/dev/null | wc -l)
    SIZE=$(du -sh {{store}}/default.castr/ 2>/dev/null | cut -f1)
    echo "Chunks: $CHUNKS"
    echo "Size: $SIZE"

# === Device Commands ===

# Show RAUC status on a running device
[group('device')]
rauc-status host:
    ssh root@{{host}} "rauc status"

# Install RAUC bundle on a running device
[group('device')]
[script('bash')]
rauc-install host bundle:
    echo "Copying bundle to device..."
    scp {{bundle}} root@{{host}}:/tmp/update.raucb
    echo "Installing bundle..."
    ssh root@{{host}} "rauc install /tmp/update.raucb && rm /tmp/update.raucb"
    echo "Done. Reboot device to boot into new slot."

# Reboot a device
[group('device')]
reboot host:
    ssh root@{{host}} "reboot"

# Show system status on a running device
[group('device')]
[script('bash')]
status host:
    echo "=== RAUC Status ==="
    ssh root@{{host}} "rauc status" || true
    echo ""
    echo "=== Disk Usage ==="
    ssh root@{{host}} "df -h" || true
    echo ""
    echo "=== Uptime ==="
    ssh root@{{host}} "uptime" || true
