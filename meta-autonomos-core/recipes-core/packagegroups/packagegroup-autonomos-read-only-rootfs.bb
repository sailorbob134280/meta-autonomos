SUMMARY = "Read-only rootfs configuration"
DESCRIPTION = "Persistent bind mounts and volatile storage configuration for read-only rootfs."
LICENSE = "MIT"

inherit packagegroup

RDEPENDS:${PN} = "read-only-rootfs-config"
