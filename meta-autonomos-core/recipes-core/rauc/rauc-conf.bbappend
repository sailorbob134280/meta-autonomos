# AutonomOS RAUC configuration (core/platform-agnostic)
#
# Provides keyring from development keys by default.
# Platform layers (e.g., meta-autonomos-raspberrypi) must provide
# machine-specific system.conf files.
#
# Projects can override keys by setting AUTONOMOS_RAUC_KEY_DIR in local.conf

inherit autonomos-rauc

# Add the key directory to the search path
# If AUTONOMOS_RAUC_KEY_DIR is set, use it; otherwise use default development keys
FILESEXTRAPATHS:prepend := "${@d.getVar('AUTONOMOS_RAUC_KEY_DIR') + ':' if d.getVar('AUTONOMOS_RAUC_KEY_DIR') else ''}${THISDIR}/../../files/rauc-example-keys:"

# Use the keyring file from configuration
RAUC_KEYRING_FILE = "${AUTONOMOS_RAUC_KEYRING_FILE}"

# Always install keyring as keyring.pem for consistent system.conf references
# Also substitute the compatible string to allow per-project customization
do_install:append() {
    # Rename the keyring file to keyring.pem if it has a different name
    if [ "${RAUC_KEYRING_FILE}" != "keyring.pem" ] && [ -f ${D}${sysconfdir}/rauc/${RAUC_KEYRING_FILE} ]; then
        mv ${D}${sysconfdir}/rauc/${RAUC_KEYRING_FILE} ${D}${sysconfdir}/rauc/keyring.pem
    fi

    # Substitute compatible string to allow per-project/deployment customization
    # Default is autonomos-${MACHINE}, but can be overridden via AUTONOMOS_RAUC_COMPATIBLE
    sed -i "s/^compatible=.*/compatible=${AUTONOMOS_RAUC_COMPATIBLE}/" ${D}${sysconfdir}/rauc/system.conf
}
