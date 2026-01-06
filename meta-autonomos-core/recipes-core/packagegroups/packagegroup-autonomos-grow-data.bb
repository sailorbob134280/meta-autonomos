SUMMARY = "Grow data partition at first boot"
DESCRIPTION = "Packagegroup for automatic data partition expansion to fill available disk space."
LICENSE = "MIT"

inherit packagegroup

PACKAGEGROUP_PACKAGES = "\
    data-partition-resize \
"

RDEPENDS:${PN} = "${PACKAGEGROUP_PACKAGES}"
