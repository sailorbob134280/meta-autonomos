# base-files bbappend for AutonomOS
#
# Changes root's default shell from /bin/sh to /bin/zsh for a better
# interactive experience when shellplus feature is enabled.

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
