SUMMARY = "AutonomOS Raspberry Pi machine-specific packages"
DESCRIPTION = "Machine-specific packages for Raspberry Pi platforms including mount FDIR."
LICENSE = "MIT"

inherit packagegroup

RDEPENDS:${PN} = "\
    mount-fdir \
"
