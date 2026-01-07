# oh-my-zsh - A delightful community-driven framework for managing zsh configuration
#
# This recipe installs oh-my-zsh system-wide to /etc/oh-my-zsh, making it
# available to all users. Each user can customize their experience by
# creating ~/.zshrc that sources the system configuration.
#
# The system-wide zshrc is installed to /etc/zshrc and provides
# sensible defaults with commonly used plugins.

SUMMARY = "Oh My Zsh - framework for managing zsh configuration"
DESCRIPTION = "A delightful community-driven framework for managing your zsh configuration"
HOMEPAGE = "https://ohmyz.sh/"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=032ae621cb533d73f6e84b6f9ee8a056"

SRC_URI = "git://github.com/ohmyzsh/ohmyzsh.git;branch=master;protocol=https \
           file://zshrc \
           file://10-shellplus.help \
          "
SRCREV = "a79b37b95461ea2be32578957473375954ab31ff"
PV = "1.0+git${SRCPV}"

S = "${WORKDIR}/git"

# Runtime dependencies
RDEPENDS:${PN} = "zsh"
RRECOMMENDS:${PN} = "zsh-autosuggestions zsh-syntax-highlighting"

# No compilation needed
inherit allarch

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    # Install oh-my-zsh framework to /etc/oh-my-zsh
    install -d ${D}${sysconfdir}/oh-my-zsh

    # Copy core framework files
    cp -R ${S}/lib ${D}${sysconfdir}/oh-my-zsh/
    cp -R ${S}/themes ${D}${sysconfdir}/oh-my-zsh/
    cp -R ${S}/plugins ${D}${sysconfdir}/oh-my-zsh/
    cp -R ${S}/templates ${D}${sysconfdir}/oh-my-zsh/
    cp -R ${S}/tools ${D}${sysconfdir}/oh-my-zsh/
    cp ${S}/oh-my-zsh.sh ${D}${sysconfdir}/oh-my-zsh/

    # Create custom plugins directory for external plugins
    install -d ${D}${sysconfdir}/oh-my-zsh/custom/plugins

    # Install system-wide zshrc to /etc/zshrc (where zsh looks for it)
    install -m 0644 ${WORKDIR}/zshrc ${D}${sysconfdir}/zshrc

    # Help snippet for halp command
    install -d ${D}${sysconfdir}/autonomos/help.d
    install -m 0644 ${WORKDIR}/10-shellplus.help ${D}${sysconfdir}/autonomos/help.d/
}

FILES:${PN} = "${sysconfdir}/oh-my-zsh ${sysconfdir}/zshrc ${sysconfdir}/autonomos/help.d/10-shellplus.help"

# Ensure proper permissions
pkg_postinst:${PN}() {
    # Make oh-my-zsh files readable by all users
    chmod -R a+rX $D${sysconfdir}/oh-my-zsh || true
}
