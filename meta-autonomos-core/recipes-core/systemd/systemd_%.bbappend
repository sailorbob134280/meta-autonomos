# AutonomOS systemd configuration

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://networkd-wait-online-any.conf"

# Install drop-in to make networkd-wait-online succeed when ANY interface is online
# This prevents boot delays when some interfaces have no carrier
do_install:append() {
    install -d ${D}${systemd_system_unitdir}/systemd-networkd-wait-online.service.d
    install -m 0644 ${WORKDIR}/networkd-wait-online-any.conf \
        ${D}${systemd_system_unitdir}/systemd-networkd-wait-online.service.d/any.conf
}

FILES:${PN} += "${systemd_system_unitdir}/systemd-networkd-wait-online.service.d/any.conf"
