function grin
    if test (id -u) != 0
        echo '
        you must be root
        run → $ doas -s
        '
        return 1
    end

    if efibootmgr | grep -iq 'grub'
        set -f ARCH (arch)
    else
        echo "
        no need to run grub-install
        "
        return 0
    end

    read -l -P '
    run grub-install (n/y)
    : ' ch

    if not test "$ch" = y
        return 0
    end

    switch $ARCH
        case riscv64
            set -f target riscv64-efi
            set -f fwa riscv64
        case x86_64
            set -f target x86_64-efi
            set -f fwa x64
        case x86
            set -f target i386-efi
            set -f fwa ia32
        case 'arm*'
            set -f target arm-efi
            set -f fwa arm
        case aarch64
            set -f target arm64-efi
            set -f fwa aa64
    end

    echo "
    cross-check → ARCH: $ARCH
    target: $target fwa: $fwa
    "

    read -lP 'continue? (n/y)
    : ' choic

    if not test "$choic" = y
        return 0
    end

    set -f efid (awk '$2 ~ /boot/ && $3 ~ /fat|msdos/ { print $2 }' /proc/mounts)

    if not test -e \
        "$efid"/EFI/alpine/grub"$fwa".efi -a -e "$efid"/EFI/boot/boot"$fwa".efi
        echo "err: paths do not match"
        return 1
    end

    printf \\n

    umask 0022

    grub-install --target=$target --efi-directory=$efid --bootloader-id=alpine \
    --boot-directory=/boot --no-nvram

    install -D $efid/EFI/alpine/grub$fwa.efi $efid/EFI/boot/boot$fwa.efi

    printf \\n

    update-grub

    echo "
    fin. reboot
    "

    umask 0077
end
