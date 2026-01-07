SUMMARY = "Read-only rootfs configuration files"
DESCRIPTION = "Bind mounts, tmpfiles configuration, and journald settings for read-only rootfs"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "\
    file://data-structure.conf \
    file://data-machine-id.service \
    file://data-journal.service \
    file://data-ssh-keys.service \
    file://journald-persistent.conf \
    file://read-only-rootfs.sh \
    file://20-read-only-rootfs.help \
"

# Configurable journal settings (override in local.conf or KAS)
AUTONOMOS_JOURNAL_MAX_SIZE ?= "64M"
AUTONOMOS_JOURNAL_MAX_FILE_SIZE ?= "8M"
AUTONOMOS_JOURNAL_MAX_RETENTION ?= "1month"

inherit allarch

do_install() {
    # systemd-tmpfiles config for /data subdirectory structure
    install -d ${D}${sysconfdir}/tmpfiles.d
    install -m 0644 ${WORKDIR}/data-structure.conf ${D}${sysconfdir}/tmpfiles.d/

    # Install bind mount services
    install -d ${D}${sysconfdir}/systemd/system
    install -m 0644 ${WORKDIR}/data-machine-id.service ${D}${sysconfdir}/systemd/system/
    install -m 0644 ${WORKDIR}/data-journal.service ${D}${sysconfdir}/systemd/system/
    install -m 0644 ${WORKDIR}/data-ssh-keys.service ${D}${sysconfdir}/systemd/system/

    # Enable the services via symlinks (sysinit.target for proper ordering)
    install -d ${D}${sysconfdir}/systemd/system/sysinit.target.wants
    ln -sf ../data-machine-id.service ${D}${sysconfdir}/systemd/system/sysinit.target.wants/
    ln -sf ../data-journal.service ${D}${sysconfdir}/systemd/system/sysinit.target.wants/
    ln -sf ../data-ssh-keys.service ${D}${sysconfdir}/systemd/system/sysinit.target.wants/

    # Journald persistent configuration with size cap
    # Substitute configurable values into template
    install -d ${D}${sysconfdir}/systemd/journald.conf.d
    sed -e 's|@JOURNAL_MAX_SIZE@|${AUTONOMOS_JOURNAL_MAX_SIZE}|g' \
        -e 's|@JOURNAL_MAX_FILE_SIZE@|${AUTONOMOS_JOURNAL_MAX_FILE_SIZE}|g' \
        -e 's|@JOURNAL_MAX_RETENTION@|${AUTONOMOS_JOURNAL_MAX_RETENTION}|g' \
        ${WORKDIR}/journald-persistent.conf > ${D}${sysconfdir}/systemd/journald.conf.d/journald-persistent.conf
    chmod 0644 ${D}${sysconfdir}/systemd/journald.conf.d/journald-persistent.conf

    # Profile.d script to set XDG environment for read-only rootfs
    # Redirects cache directories to tmpfs to avoid write errors
    install -d ${D}${sysconfdir}/profile.d
    install -m 0644 ${WORKDIR}/read-only-rootfs.sh ${D}${sysconfdir}/profile.d/

    # Help snippet for halp command
    install -d ${D}${sysconfdir}/autonomos/help.d
    install -m 0644 ${WORKDIR}/20-read-only-rootfs.help ${D}${sysconfdir}/autonomos/help.d/
}

FILES:${PN} = "\
    ${sysconfdir}/tmpfiles.d/* \
    ${sysconfdir}/systemd/system/* \
    ${sysconfdir}/systemd/journald.conf.d/* \
    ${sysconfdir}/profile.d/* \
    ${sysconfdir}/autonomos/help.d/* \
"
