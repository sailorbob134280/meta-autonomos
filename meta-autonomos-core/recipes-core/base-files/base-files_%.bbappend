# base-files bbappend for AutonomOS (platform-agnostic)
#
# 1. Changes root's default shell from /bin/sh to /bin/zsh for shellplus feature
# 2. Creates /data mount point for persistent storage
# 3. Installs core shell aliases and help system
#
# Note: Platform-specific fstab files are provided by platform layers
# (e.g., meta-autonomos-raspberrypi)

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "\
    file://autonomos-aliases.sh \
    file://halp \
    file://00-base.help \
"

# This runs at image creation time to modify /etc/passwd
# We change root's shell from /bin/sh to /bin/zsh
pkg_postinst:${PN}() {
    # Only change shell if zsh is installed (shellplus feature enabled)
    if [ -f "$D${base_bindir}/zsh" ] || grep -q "^zsh$" "$D${sysconfdir}/shells" 2>/dev/null; then
        # Change root's shell from /bin/sh to /bin/zsh
        if [ -f "$D${sysconfdir}/passwd" ]; then
            sed -i 's|^root:\([^:]*:[^:]*:[^:]*:[^:]*:[^:]*:\)/bin/sh$|root:\1/bin/zsh|' $D${sysconfdir}/passwd
        fi
    fi
}

# Add zsh to /etc/shells if not already present
pkg_postinst:${PN}:append() {
    if [ -f "$D${base_bindir}/zsh" ]; then
        if ! grep -q "^/bin/zsh$" "$D${sysconfdir}/shells" 2>/dev/null; then
            echo "/bin/zsh" >> "$D${sysconfdir}/shells"
        fi
    fi
}

do_install:append() {
    # Create /data mount point for persistent storage
    install -d ${D}/data

    # Core shell aliases (sourced by /etc/profile for all shells)
    install -d ${D}${sysconfdir}/profile.d
    install -m 0644 ${WORKDIR}/autonomos-aliases.sh ${D}${sysconfdir}/profile.d/

    # Help system infrastructure
    install -d ${D}${sysconfdir}/autonomos/help.d
    install -m 0644 ${WORKDIR}/00-base.help ${D}${sysconfdir}/autonomos/help.d/

    # halp command
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/halp ${D}${bindir}/
}

FILES:${PN} += "\
    ${sysconfdir}/profile.d/autonomos-aliases.sh \
    ${sysconfdir}/autonomos/help.d/* \
    ${bindir}/halp \
"
