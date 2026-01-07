FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "\
    file://k3s-data.conf \
    file://40-kubernetes.help \
"

do_install:append () {
    # Create symlinks from /var/lib to persistent storage on /data
    install -d ${D}/var/lib
    ln -snf "/data/k3s/rancher" ${D}/var/lib/rancher
    ln -snf "/data/k3s/kubelet" ${D}/var/lib/kubelet

    # tmpfiles.d entries to create directories at boot
    install -d ${D}${sysconfdir}/tmpfiles.d
    install -m 0644 ${WORKDIR}/k3s-data.conf ${D}${sysconfdir}/tmpfiles.d/

    # Help snippet for halp command
    install -d ${D}${sysconfdir}/autonomos/help.d
    install -m 0644 ${WORKDIR}/40-kubernetes.help ${D}${sysconfdir}/autonomos/help.d/
}

FILES:${PN} += "\
    ${sysconfdir}/tmpfiles.d/k3s-data.conf \
    ${sysconfdir}/autonomos/help.d/40-kubernetes.help \
"
