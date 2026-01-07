SUMMARY = "Mount FDIR - Fault Detection, Isolation, and Recovery for mounts"
DESCRIPTION = "Verifies critical mount points are available at boot, \
retrying if necessary. Designed for embedded systems where storage \
may be slow to initialize or occasionally flaky."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "\
    file://mount-fdir.sh \
    file://mount-fdir.conf \
    file://mount-fdir.service \
"

inherit allarch systemd

SYSTEMD_SERVICE:${PN} = "mount-fdir.service"
SYSTEMD_AUTO_ENABLE = "enable"

do_install() {
    # Install the FDIR script
    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/mount-fdir.sh ${D}${sbindir}/

    # Install configuration
    install -d ${D}${sysconfdir}
    install -m 0644 ${WORKDIR}/mount-fdir.conf ${D}${sysconfdir}/

    # Install systemd service
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/mount-fdir.service ${D}${systemd_system_unitdir}/
}

FILES:${PN} = "\
    ${sbindir}/mount-fdir.sh \
    ${sysconfdir}/mount-fdir.conf \
    ${systemd_system_unitdir}/mount-fdir.service \
"

RDEPENDS:${PN} = "util-linux-mountpoint"
