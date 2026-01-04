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
