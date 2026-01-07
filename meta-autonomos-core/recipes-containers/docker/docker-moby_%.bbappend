FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "\
    file://docker-data.conf \
    file://30-containers.help \
"

do_install:append () {
    # Create symlink from /var/lib/docker to persistent storage
    install -d ${D}/var/lib
    ln -snf "/data/docker" ${D}/var/lib/docker

    # tmpfiles.d entry to create /data/docker at boot
    install -d ${D}${sysconfdir}/tmpfiles.d
    install -m 0644 ${WORKDIR}/docker-data.conf ${D}${sysconfdir}/tmpfiles.d/

    # Help snippet for halp command
    install -d ${D}${sysconfdir}/autonomos/help.d
    install -m 0644 ${WORKDIR}/30-containers.help ${D}${sysconfdir}/autonomos/help.d/
}

FILES:${PN} += "\
    ${sysconfdir}/tmpfiles.d/docker-data.conf \
    ${sysconfdir}/autonomos/help.d/30-containers.help \
"
