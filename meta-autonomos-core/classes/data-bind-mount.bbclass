# data-bind-mount.bbclass
#
# Provides a simple way to create persistent bind mounts from /data.
# Mounts are created at boot with graceful fallback if /data is unavailable.
#
# Usage:
#   inherit data-bind-mount
#
#   DATA_BIND_MOUNTS = "\
#       /data/app/myapp/config:/etc/myapp \
#       /data/app/myapp/state:/var/lib/myapp \
#   "
#
# Format: "source:target" where source is under /data and target is the mount point.
#
# The class:
#   - Creates target directories at build time (for read-only rootfs support)
#   - Generates a systemd service that creates source dirs on /data at boot
#   - Only executes if /data is mounted (ConditionPathIsMountPoint)
#

DATA_BIND_MOUNTS ?= ""

# Service name based on recipe
DATA_BIND_MOUNT_SERVICE = "data-bind-${PN}.service"

python do_generate_bind_mount_service() {
    import os

    mounts = d.getVar('DATA_BIND_MOUNTS') or ""
    mounts = mounts.split()

    if not mounts:
        return

    # Parse mount specifications
    mount_specs = []
    for mount in mounts:
        if ':' not in mount:
            bb.fatal(f"Invalid DATA_BIND_MOUNTS entry '{mount}': must be 'source:target'")
        source, target = mount.split(':', 1)
        if not source.startswith('/data'):
            bb.fatal(f"Invalid DATA_BIND_MOUNTS source '{source}': must start with /data")
        mount_specs.append((source, target))

    if not mount_specs:
        return

    # Generate ExecStartPre lines for source directory creation only
    # Target directories are created at build time for read-only rootfs support
    exec_pre_lines = []
    exec_start_lines = []
    for source, target in mount_specs:
        exec_pre_lines.append(f"ExecStartPre=/bin/mkdir -p {source}")
        exec_start_lines.append(f"ExecStart=/bin/mount --bind {source} {target}")

    pn = d.getVar('PN')
    service_name = d.getVar('DATA_BIND_MOUNT_SERVICE')

    # Build service file content
    service_content = f"""[Unit]
Description=Bind mounts for {pn}
DefaultDependencies=no
After=mount-fdir.service
ConditionPathIsMountPoint=/data

[Service]
Type=oneshot
RemainAfterExit=yes
{chr(10).join(exec_pre_lines)}
{chr(10).join(exec_start_lines)}

[Install]
WantedBy=sysinit.target
"""

    # Write to workdir for installation
    workdir = d.getVar('WORKDIR')
    service_path = os.path.join(workdir, service_name)
    with open(service_path, 'w') as f:
        f.write(service_content)

    # Store mount specs for do_install to create target directories
    d.setVar('DATA_BIND_MOUNT_SPECS', ' '.join([f"{s}:{t}" for s, t in mount_specs]))
}

addtask generate_bind_mount_service before do_install after do_compile

# Create target directories at build time (required for read-only rootfs)
python do_install_bind_mount_dirs() {
    import os

    mounts = d.getVar('DATA_BIND_MOUNTS') or ""
    mounts = mounts.split()

    if not mounts:
        return

    destdir = d.getVar('D')

    for mount in mounts:
        if ':' not in mount:
            continue
        source, target = mount.split(':', 1)
        # Create target directory in the image
        target_path = os.path.join(destdir, target.lstrip('/'))
        os.makedirs(target_path, exist_ok=True)
}

do_install[postfuncs] += "do_install_bind_mount_dirs"

do_install:append() {
    if [ -n "${DATA_BIND_MOUNTS}" ]; then
        install -d ${D}${sysconfdir}/systemd/system
        install -m 0644 ${WORKDIR}/${DATA_BIND_MOUNT_SERVICE} ${D}${sysconfdir}/systemd/system/

        # Enable the service
        install -d ${D}${sysconfdir}/systemd/system/sysinit.target.wants
        ln -sf ../${DATA_BIND_MOUNT_SERVICE} ${D}${sysconfdir}/systemd/system/sysinit.target.wants/
    fi
}

# Include target directories and systemd files in package
python populate_packages:prepend() {
    import os

    mounts = d.getVar('DATA_BIND_MOUNTS') or ""
    mounts = mounts.split()

    if not mounts:
        return

    pn = d.getVar('PN')
    files = d.getVar(f'FILES:{pn}') or ""

    # Add target directories to FILES
    for mount in mounts:
        if ':' not in mount:
            continue
        source, target = mount.split(':', 1)
        files += f" {target}"

    # Add systemd files
    sysconfdir = d.getVar('sysconfdir')
    files += f" {sysconfdir}/systemd/system/*"

    d.setVar(f'FILES:{pn}', files)
}
