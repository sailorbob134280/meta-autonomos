SUMMARY = "Better shell experience"
DESCRIPTION = "Packagegroup for a better shell experience with oh-my-zsh."
LICENSE = "MIT"

inherit packagegroup

PACKAGEGROUP_PACKAGES = "\
    zsh \
    tmux \
    vim \
    oh-my-zsh \
    zsh-autosuggestions \
    zsh-syntax-highlighting \
"

RDEPENDS:${PN} = "${PACKAGEGROUP_PACKAGES}"
