# Read-only rootfs environment configuration

# Cache is volatile - redirect to tmpfs
# This prevents errors from shells and applications trying to write to ~/.cache
if [ -z "$XDG_CACHE_HOME" ]; then
    export XDG_CACHE_HOME="/tmp/.cache-${USER:-root}"
    mkdir -p "$XDG_CACHE_HOME" 2>/dev/null
fi

# Read-only rootfs helpers
alias write-enable='mount -o remount,rw / && echo "Root filesystem is now writable"'
alias write-disable='mount -o remount,ro / && echo "Root filesystem is now read-only"'
