# zsh-syntax-highlighting - Fish shell-like syntax highlighting for Zsh
#
# Provides syntax highlighting for the shell zsh. It enables highlighting
# of commands whilst they are typed at a zsh prompt into an interactive terminal.

SUMMARY = "Fish shell-like syntax highlighting for Zsh"
DESCRIPTION = "Syntax highlighting for the shell zsh"
HOMEPAGE = "https://github.com/zsh-users/zsh-syntax-highlighting"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://COPYING.md;md5=6b68a3be44eb63fbb43b432b64139138"

SRC_URI = "git://github.com/zsh-users/zsh-syntax-highlighting.git;branch=master;protocol=https"
SRCREV = "5eb677bb0fa9a3e60f0eff031dc13926e093df92"
PV = "0.8.0+git${SRCPV}"

S = "${WORKDIR}/git"

RDEPENDS:${PN} = "zsh"

inherit allarch

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    # Install to oh-my-zsh custom plugins directory
    install -d ${D}${sysconfdir}/oh-my-zsh/custom/plugins/zsh-syntax-highlighting

    # Install main plugin files
    install -m 0644 ${S}/zsh-syntax-highlighting.zsh ${D}${sysconfdir}/oh-my-zsh/custom/plugins/zsh-syntax-highlighting/
    install -m 0644 ${S}/zsh-syntax-highlighting.plugin.zsh ${D}${sysconfdir}/oh-my-zsh/custom/plugins/zsh-syntax-highlighting/
    install -m 0644 ${S}/.revision-hash ${D}${sysconfdir}/oh-my-zsh/custom/plugins/zsh-syntax-highlighting/ || true
    install -m 0644 ${S}/.version ${D}${sysconfdir}/oh-my-zsh/custom/plugins/zsh-syntax-highlighting/ || true

    # Install highlighters
    cp -R ${S}/highlighters ${D}${sysconfdir}/oh-my-zsh/custom/plugins/zsh-syntax-highlighting/
}

FILES:${PN} = "${sysconfdir}/oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
