# zsh-autosuggestions - Fish-like autosuggestions for zsh
#
# Suggests commands as you type based on history and completions.
# Press Alt+L (or Esc+L) to accept the suggestion.

SUMMARY = "Fish-like autosuggestions for zsh"
DESCRIPTION = "Suggests commands as you type based on history and completions"
HOMEPAGE = "https://github.com/zsh-users/zsh-autosuggestions"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=4772b272d69775eb16c54335cf3394d8"

SRC_URI = "git://github.com/zsh-users/zsh-autosuggestions.git;branch=master;protocol=https"
SRCREV = "85919cd1ffa7d2d5412f6d3fe437ebdbeeec4fc5"
PV = "0.7.1+git${SRCPV}"

S = "${WORKDIR}/git"

RDEPENDS:${PN} = "zsh"

inherit allarch

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    # Install to oh-my-zsh custom plugins directory
    install -d ${D}${sysconfdir}/oh-my-zsh/custom/plugins/zsh-autosuggestions
    install -m 0644 ${S}/zsh-autosuggestions.zsh ${D}${sysconfdir}/oh-my-zsh/custom/plugins/zsh-autosuggestions/
    install -m 0644 ${S}/zsh-autosuggestions.plugin.zsh ${D}${sysconfdir}/oh-my-zsh/custom/plugins/zsh-autosuggestions/

    # Install source files needed by the plugin
    cp -R ${S}/src ${D}${sysconfdir}/oh-my-zsh/custom/plugins/zsh-autosuggestions/
}

FILES:${PN} = "${sysconfdir}/oh-my-zsh/custom/plugins/zsh-autosuggestions"
