function iso
    argparse -X 0 -- $argv
    or return

    printf "usb device \u2193\n\n"

    for dev in /dev/disk/by-id/usb*
        set -f dev (readlink -f $dev)
    end

    if test -z "$dev"
        echo "no usb"
        return 1
    end

    set -l usb (string replace -ra '\d' '' -- $dev)

    if set -q usb
        echo -- "$usb"
    else
        return 1
    end

    printf \\n

    read -l -P 'cross check? (y/n) ' cck

    if test "$cck" = y
        printf \\n
        lsblk -no model,name
        printf \\n
        while true
            read -l -P 'okay? (y/n) ' ok
            switch $ok
                case n
                    return 1
                case y
                    break
            end
        end
    end

    set -l mpo (df 2>/dev/null | cut -d ' ' -f -1 \
    | grep "$usb")

    if test -n "$mpo"
        printf \\n
        doas umount $mpo
        or return 1
    end

    printf \\n

    while true
        read -l -P 'wipe usb drive? (y/n) ' wpd
        switch $wpd
            case y
                printf \\n
                doas wipefs --all --quiet --noheadings $usb
                doas dd if=/dev/zero of=$usb bs=512 count=1
                printf \\n
                read -l -P 'shred entire disk? (n/y) ' disk
                if test "$disk" = y
                    echo ".. this could take a while .."
                    doas dd if=/dev/zero of=$usb bs=1M \
                    oflag=direct
                end
                printf \\n
                echo "creating primary partition.."
                printf 'n\np\n1\n\n\nt\nb\na\n1\nw' \
                | doas fdisk $usb > /dev/null
                printf \\n
                doas fdisk -l $usb | tail -n2
                set -l par {$usb}1
                printf \\n
                doas mkfs.vfat -F 32 $par
                break
            case n
                break
        end
    end

    printf \\n

    while true
        read -lP 'write image @ usb? (y/n) ' img
        switch $img
            case y
                printf \\n
                find /home -type f -name '*.iso'
                printf \\n
                read -lP 'copy/paste path: ' iso
                if test -f "$iso"
                    doas dd bs=4M if=$iso of=$usb \
                    conv=fsync
                    and sleep 1
                    printf \\n
                    lsblk -o model,name,size,fstype,label
                    break
                else
                    printf \\n
                    printf "\033[5merror\033[0m $iso"
                    return 1
                end
            case n
                printf \\n
                lsblk -o model,name,size,fstype,label
                return 0
        end
    end
end
