# Shared RAUC configuration for AutonomOS
#
# This class provides common RAUC variables used across all platforms.
# Platform layers should provide their own system.conf files.
#
# Projects can override keys by setting in local.conf or kas yaml:
#   AUTONOMOS_RAUC_KEY_DIR = "/path/to/keys"
#   AUTONOMOS_RAUC_KEYRING_FILE = "production.cert.pem"
#   AUTONOMOS_RAUC_KEY_FILE = "production.key.pem"
#   AUTONOMOS_RAUC_CERT_FILE = "production.cert.pem"

# RAUC status and data locations (on persistent /data partition)
AUTONOMOS_RAUC_STATUSFILE ?= "/data/rauc.status"
AUTONOMOS_RAUC_DATADIR ?= "/data/rauc"

# Compatible string format (platform layers may override)
AUTONOMOS_RAUC_COMPATIBLE ?= "autonomos-${MACHINE}"

# Key configuration - projects can override these
# Default: use development keys from meta-autonomos-core
AUTONOMOS_RAUC_KEY_DIR ?= ""
AUTONOMOS_RAUC_KEYRING_FILE ?= "development.cert.pem"
AUTONOMOS_RAUC_KEY_FILE ?= "development.key.pem"
AUTONOMOS_RAUC_CERT_FILE ?= "development.cert.pem"
