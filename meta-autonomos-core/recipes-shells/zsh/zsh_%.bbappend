# Enable dynamic module loading for zsh
#
# The upstream recipe disables dynamic modules, but oh-my-zsh requires
# zsh/system and zsh/regex modules for full functionality.

EXTRA_OECONF:remove = "--disable-dynamic"
EXTRA_OECONF:append = " --enable-dynamic"

# Dynamic modules are installed to lib/zsh/<version>
FILES:${PN} += "${libdir}/zsh"
