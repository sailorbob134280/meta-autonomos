# base-files bbappend for AutonomOS Raspberry Pi platforms
#
# 1. Provides custom fstab for our 4-partition A/B layout (overrides meta-rauc-raspberrypi)
# 2. Changes root's default shell from /bin/sh to /bin/zsh for shellplus feature
# 3. Creates /data mount point for persistent storage

# Ensure our fstab takes precedence over meta-rauc-raspberrypi's
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

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

# Create /data mount point for persistent storage
do_install:append() {
    install -d ${D}/data
}
