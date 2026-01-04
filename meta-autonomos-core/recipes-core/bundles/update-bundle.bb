# AutonomOS RAUC Update Bundle
# Generates a signed RAUC bundle containing the rootfs image
#
# Build with: bitbake update-bundle
# Output: tmp-<machine>/deploy/images/<machine>/update-bundle-<machine>.raucb
#
# To use custom signing keys, set in local.conf or kas yaml:
#   AUTONOMOS_RAUC_KEY_DIR = "/path/to/keys"
#   AUTONOMOS_RAUC_KEY_FILE = "signing.key.pem"
#   AUTONOMOS_RAUC_CERT_FILE = "signing.cert.pem"

inherit bundle autonomos-rauc

RAUC_BUNDLE_COMPATIBLE = "${AUTONOMOS_RAUC_COMPATIBLE}"
RAUC_BUNDLE_VERSION = "${DISTRO_VERSION}"
RAUC_BUNDLE_DESCRIPTION = "AutonomOS Update Bundle"
RAUC_BUNDLE_FORMAT = "verity"

RAUC_BUNDLE_SLOTS = "rootfs"
RAUC_SLOT_rootfs = "autonomos-devel"
RAUC_SLOT_rootfs[fstype] = "ext4"

# Signing keys - use project-configured keys or default development keys
RAUC_KEY_FILE = "${@d.getVar('AUTONOMOS_RAUC_KEY_DIR') + '/' + d.getVar('AUTONOMOS_RAUC_KEY_FILE') if d.getVar('AUTONOMOS_RAUC_KEY_DIR') else d.getVar('THISDIR') + '/../../files/rauc-example-keys/' + d.getVar('AUTONOMOS_RAUC_KEY_FILE')}"
RAUC_CERT_FILE = "${@d.getVar('AUTONOMOS_RAUC_KEY_DIR') + '/' + d.getVar('AUTONOMOS_RAUC_CERT_FILE') if d.getVar('AUTONOMOS_RAUC_KEY_DIR') else d.getVar('THISDIR') + '/../../files/rauc-example-keys/' + d.getVar('AUTONOMOS_RAUC_CERT_FILE')}"
