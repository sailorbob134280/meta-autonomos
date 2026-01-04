SUMMARY = "Resize data partition at first boot"
DESCRIPTION = "Systemd service to expand the data partition to fill available \
disk space on first boot. Uses parted and resize2fs."
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = "file://data-partition-resize.sh \
           file://data-partition-resize.service"

S = "${WORKDIR}"

inherit systemd

SYSTEMD_SERVICE:${PN} = "data-partition-resize.service"
SYSTEMD_AUTO_ENABLE = "enable"

# Runtime dependencies for the resize script
# parted: partition resizing
# e2fsprogs-resize2fs: ext4 filesystem resizing
# util-linux-findfs: finding device by label
RDEPENDS:${PN} = "parted e2fsprogs-resize2fs util-linux-findfs"

do_install() {
    # Install the resize script
    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/data-partition-resize.sh ${D}${sbindir}/data-partition-resize.sh

    # Install systemd service
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/data-partition-resize.service ${D}${systemd_system_unitdir}/
}

FILES:${PN} = "${sbindir}/data-partition-resize.sh \
               ${systemd_system_unitdir}/data-partition-resize.service"
