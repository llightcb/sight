#!/bin/sh
# shellcheck disable=SC3043

    vech() {
        local IFS=" "
        printf %s "$*"
    }

    reivor() {
        setup-apkrepos
        exec "$0"
    }

    subs() {
        case $2 in
            *"$1"*)
                return 0 ;;
            *)
                return 1 ;;
        esac
    }

    clear

    echo "- preparation .."

    printf \\n

    # nuser
    if test "$(id -u)" != 0
    then
        exit 1
    fi

    usernt="$(grep -E 'x:[1-9]([0-9]){3}:' /etc/passwd | cut -d ':' -f1)"

    if test -n "$usernt"; then
        echo "don't create a user via the setup-alpine script: /$usernt/"
        exit 1
    fi

    # notice
    if subs light "$PWD"; then
        printf "\033[37;7merror\033[0m script executed from: %s\n" "$PWD"
        exit 1
    fi

    # notice
    apk add pciutils >/dev/null

    if lspci -k | grep -i -C 2 -E 'vga|3d' | grep -i -q -w 'nvidia'; then
        printf "\033[37;7msorry,\033[0m light does not support: nvidia\n"
        exit 1
    fi

    # apkr
    apk_repos=/etc/apk/repositories

    sed -E -i 's/^((#[ ]?(http(|s)|ftp))|ftp|http\>)/https/' "$apk_repos"

    if ! wget -q -T 5 --spider "$(grep -m 1 '^https' "$apk_repos")"; then
        true > "$apk_repos"; reivor
    fi

    sed -i '/edge/!s/^https/#&/;/testing/s/^https/@edtst &/' "$apk_repos"

    apk add -Uq --upgrade apk-tools

    # cuser
    printf "choose username: "
    read -r usn

    if test -z "$usn"; then
        exit 1
    fi

    adduser -h /home/"$usn" \
    -s /usr/bin/fish "$usn"

    if test "$?" -ne 0; then
        exit 1
    fi

    # ghome
    dir=/home/"$usn"

    mv light "$dir"

    cd "$dir" \
    || exit 1

    # fsbin
    sed -i -E 's/^tty(3|4|5|6)/#&/' /etc/inittab; apk upgrade --available

    # start
    while read -r pk; do
        apk add "$pk"
    done <<'THXTOALL'
    xdg-desktop-portal-wlr
    oath-toolkit-oathtool
    mesa-vdpau-gallium
    zathura-pdf-mupdf
    pipe-viewer@edtst
    autotiling@edtst
    mesa-dri-gallium
    mesa-va-gallium
    dnscrypt-proxy
    apk-tools-doc
    pipewire-alsa
    wireplumber
    iproute2-ss
    alsa-utils
    ttf-dejavu
    shellcheck
    pipewire
    iptables
    newsboat
    powertop
    chromium
    i3status
    xwayland
    wayland
    ncurses
    tcpdump
    nethogs
    python3
    plocate
    man-db
    neovim
    ffmpeg
    wipefs
    swaybg
    irssi
    lsblk
    rsync
    light
    seatd
    drill
    slurp
    fish
    less
    grim
    curl
    sway
    foot
    dbus
    doas
    inxi
    mpv
    imv
    nnn
    fzf
THXTOALL

    # itacc
    if lspci -k | grep -i -C2 -E 'vga|3d' | grep -i -q -w 'intel'; then
        apk add libva-intel-driver intel-media-driver
    fi

    # μcode
    if grep -i 'vendor' /proc/cpuinfo | uniq | grep -i -q 'intel'; then
        apk add intel-ucode
    fi

    # group
    adduser "$usn" wheel
    adduser "$usn" video
    adduser root audio
    adduser "$usn" seat
    adduser "$usn" input
    adduser "$usn" audio

    # loho
    hna="$(grep '' /etc/hostname)"

    if test "$hna" != localhost
    then
        cut -c9- <<EOF >/etc/hosts
        127.0.0.1 localhost.localdomain localhost $hna.localdomain $hna
        ::1       localhost.localdomain localhost $hna.localdomain $hna
EOF
    rc-service -q hostname restart
    fi

    # serv
    rc-update -q add acpid default
    rc-update -q add crond default
    rc-update -q add alsa default
    rc-update -q add dbus default
    rc-update -q add seedrng boot
    rc-update -q add seatd default
    rc-update -q add local default

    # udev
    setup-devd udev >/dev/null 2>&1

    # rvcf
    cut -c 5- <<EOF \
    > /etc/resolv.conf
    nameserver 127.0.0.1
    options edns0
EOF

    # kern
    cut -c 5- <<EOF \
    >>/etc/sysctl.conf
    kernel.yama.ptrace_scope=3
    kernel.panic_on_oops=30
    vm.swappiness=30
    kernel.panic=30
    kernel.sysrq=0
    vm.panic_on_oom=1
    fs.protected_fifos=1
    fs.protected_regular=1
    vm.vfs_cache_pressure=90
EOF

    # netw
    cut -c 5- <<EOF \
    >>/etc/sysctl.conf
    net.ipv4.icmp_ignore_bogus_error_responses=1
    net.ipv4.conf.default.accept_redirects=0
    net.ipv4.conf.all.accept_source_route=0
    net.ipv4.conf.all.accept_redirects=0
    net.ipv4.tcp_syncookies=1
    net.ipv4.tcp_rfc1337=1
    net.ipv4.ip_forward=0
    net.ipv4.conf.all.rp_filter=1
    net.ipv4.conf.default.rp_filter=1
    net.ipv4.conf.all.secure_redirects=0
    net.ipv4.conf.default.secure_redirects=0
    net.ipv4.conf.default.send_redirects=0
    net.ipv4.conf.all.send_redirects=0
    net.ipv4.tcp_timestamps=1
    net.ipv6.conf.lo.disable_ipv6=1
    net.ipv6.conf.all.disable_ipv6=1
    net.ipv6.conf.eth0.disable_ipv6=1
    net.ipv6.conf.default.disable_ipv6=1
    net.ipv4.icmp_echo_ignore_broadcasts=1
    net.ipv4.conf.default.accept_source_route=0
EOF

    # dcvr
    dnst=/etc/dnscrypt-proxy/dnscrypt-proxy.toml

    # cron
    mkdir -p /etc/periodic/5min

    cut -c5- <<EOF | paste -s -d '\0' \
    >> /etc/crontabs/root
    */5     *       *       *       *
           run-parts /etc/periodic/5min
EOF

    # misc
    rc-update -qq del hwdrivers sysinit

    # dpms
     cut -c5- <<'EOF' \
     > light/home/.config/sway/odpms.sh
    #!/bin/sh
    #
        read -r lcd < /tmp/lcd

        if test "$lcd" -eq 0; then
            swaymsg "output * power on"
            echo 1 > /tmp/lcd
        else
            swaymsg "output * power off"
            echo 0 > /tmp/lcd
        fi
EOF
    chmod +x light/home/.config/sway/odpms.sh

    # wsdp
    cut -c5- <<'EOF' \
    > /etc/local.d/makeswaitsync.start
    #!/bin/sh
    #
        if rc-service -q chronyd status; then
            grep -i -q -o 'makestep' \
            /etc/chrony/chrony.conf \
            && chronyc waitsync 6
        fi

        exit 0
EOF
    chmod +x /etc/local.d/makeswaitsync.start

    # cdlv
    echo "rc_verbose=yes" > /etc/conf.d/local

    # wavm
    wdg="$(cat /proc/sys/kernel/nmi_watchdog)"

    if test "$wdg" -eq 1; then
        echo "kernel.nmi_watchdog=0" \
        | tee -a /etc/sysctl.conf > /dev/null
    fi

    # jinc
    mkdir -p /etc/udhcpc

    cut -c 5- <<EOF > /etc/udhcpc/udhcpc.conf
    RESOLV_CONF="no"
EOF

    # lbat
    cut -c5- <<'EOF' \
    | tee /etc/periodic/5min/lowbat >/dev/null
    #!/bin/sh
    #
    export XDG_RUNTIME_DIR=/tmp/1000-runtime-dir
    batt="$(ls -d /sys/class/power_supply/BAT*)"
    ac="$(cat /sys/class/power_supply/A*/online)"
    lev="$(cat "$batt"/capacity)"

    if test "$ac" -eq 1; then
        exit 0
    fi

    if test "$lev" -le 11 -a "$lev" -ge 8; then
        timeout 4 speaker-test -p 1024 \
        --frequency 400 -t sine >/dev/null 2>&1
    elif test "$lev" -le 7; then
        echo mem > /sys/power/state
    fi

    exit 0
EOF

    # lout
    key="$(grep '^KE' /etc/conf.d/loadkmap \
    | sed -e 's/.*map\/\(.*\)\.bmap.*/\1/')"

    swco=light/home/.config/sway/config

    if subs - "$key"; then
        lay="$(vech "$key" | cut -d '-' -f1)"
        vr="$(vech "$key" | cut -d '-' -f2-)"
        sed -i "s/xkb_layout/& $lay/" "$swco"
        sed -i "
        /xkb_la/a\ \txkb_variant $vr" "$swco"
    else
        sed -i "s/xkb_layout/& $key/" "$swco"
    fi

    # ftzv
    TZ="$(find /etc/zoneinfo/ | tail -n1 | cut -d '/' -f4-)"

    # fish
    p_dir=\$HOME/Pictures; mkdir -p /etc/fish

    cat <<'EOF' \
    | tee -a /etc/fish/config.fish >/dev/null

    if status is-login
        if test -z $XDG_RUNTIME_DIR
            set -gx XDG_RUNTIME_DIR /tmp/(id -u)-runtime-dir
            if not test -d $XDG_RUNTIME_DIR
                mkdir $XDG_RUNTIME_DIR
                chmod 0700 $XDG_RUNTIME_DIR
            end
        end
    end
EOF

    sed '11s/[[:blank:]]\{8,\}/ /2' <<EOF \
    | tee -a /etc/fish/config.fish >/dev/null

    if status is-login
        set -gx TZ $TZ
        set -gx EDITOR nvim
        set -gx ENV \$HOME/.ashrc
        set -gx LESSHISTFILE "-"
        set -gx HOSTNAME (hostname)
        set -gx XDG_SESSION_TYPE wayland
        set -gx XDG_CURRENT_DESKTOP sway
        set -gx GRIM_DEFAULT_DIR $p_dir
        fish_add_path -P /bin /usr/bin \
        /sbin /usr/sbin /usr/local/bin
    end
EOF

    cat <<'EOF' \
    | tee -a /etc/fish/config.fish >/dev/null

    if status is-login
        umask 077
    end
EOF

    cat <<'EOF' \
    | tee -a /etc/fish/config.fish >/dev/null

    if status is-login
        if test (tty) = /dev/tty1
            exec dbus-run-session -- sway
        end
    end
EOF

    # doas
    cut -c5- <<EOF >/etc/doas.d/doas.conf
    permit persist :wheel
    permit nopass keepenv root
    permit nopass :wheel cmd reboot
    permit nopass :wheel cmd poweroff
EOF

    # blc
    cut -c5- <<EOF \
    >>/etc/modprobe.d/blacklist.conf

    # additional
    install uvcvideo /bin/true
    install bluetooth /bin/true
EOF

    # idv
    chty="$(grep -E '8|9|10|14' \
    /sys/class/*/id/chassis_type)"

    # spl
    if test -n "$chty"; then
        mkdir -p /etc/acpi/LID
        cut -c9- <<EOF \
        > /etc/acpi/LID/00000080
        #!/bin/sh
        echo mem > /sys/power/state
EOF
    chmod +x /etc/acpi/LID/00000080
    fi

    # ash
    cat <<'EOF' \
    | tee "$dir"/.ashrc > /dev/null
    # funcs..
    rs() {
        tput reset
    }

    # alias..
    alias ll='ls -lhAX'
    alias src='source ~/.ashrc'
EOF

    # grub
    if test -d /sys/firmware/efi
    then
        lake="$(find /boot -name 'config-*' -maxdepth 1)"
        conf="$(grep -i '^config_shuffle_page_allocator.*y' "$lake")"
        para="$(grep -i y /sys/module/page_alloc/parameters/shuffle)"
        if ! grep -o -q 'page_alloc.shuffle' /etc/default/grub; then
            if test -n "$conf" -a -z "$para"; then
                sed -i 's/LINUX_DEFAULT="/&page_alloc.shuffle=1 /' \
                /etc/default/grub; grub-mkconfig -o /boot/grub/grub.cfg
            fi
        fi
    fi

    # sbsh
    echo "export TZ='$TZ'" | tee /etc/profile.d/timezone.sh >/dev/null

    # lobv
    if test -n "$chty"; then
        batt="$(ls -d /sys/class/power_supply/BAT* | cut -d '/' -f 5)"
        adap="$(ls -d /sys/class/power_supply/A* | cut -d '/' -f 5)"
    fi

    # fcon
    uca=/usr/share/fontconfig/conf.avail; ecd=/etc/fonts/conf.d/

    ln -s "$uca"/10-scale-bitmap-fonts.conf "$ecd" >/dev/null 2>&1
    ln -s "$uca"/11-lcdfilter-default.conf "$ecd" >/dev/null 2>&1
    ln -s "$uca"/10-hinting-slight.conf "$ecd" >/dev/null 2>&1
    ln -s "$uca"/10-sub-pixel-rgb.conf "$ecd" >/dev/null 2>&1
    ln -s "$uca"/70-no-bitmaps.conf "$ecd" >/dev/null 2>&1
    ln -s "$uca"/45-latin.conf "$ecd" >/dev/null 2>&1

    fc-cache -f

    # mime
    cut -c 5- <<EOF > light/home/.config/mimeapps.list
    [Default Applications]
    text/x-shellscript=nvim.desktop
    image/svg+xml=imv.desktop
    text/plain=nvim.desktop
    text/xml=nvim.desktop
    image/png=imv.desktop
    image/gif=imv.desktop
    image/bmp=imv.desktop
    image/jpeg=imv.desktop
    image/tiff=imv.desktop
    application/pdf=org.pwmt.zathura-pdf-mupdf.desktop
EOF

    # rcco
    echo "rc_need=udev-settle" >> /etc/conf.d/networking

    # wgmo
    if ! lsmod | grep -i -w -q '^wireguard'; then
        echo wireguard | tee -a /etc/modules > /dev/null
    fi

    # lbco
    if test -n "$chty" -a -n "$batt" -a -n "$adap"; then
        chmod a+x /etc/periodic/5min/lowbat
    fi

    # dcpp
    set -- scaleway-ams cloudflare-security

    sed -Ei \
    -e "s/('scaleway-fr',).*/\1 '${1}', '${2}']/" \
    -e "s/^#?[ ]?use_syslog.*/use_syslog = true/" \
    -e "s/^#?[ ]?log_level.*/log_level = 1/" \
    -e "s/^#?[ ]?block_ipv6.*/block_ipv6 = true/" \
    -e "s/^#[ ]?server_names/server_names/" "$dnst"

    # odrp
    cut -c5- <<EOF | sed -E 's/[[:blank:]]+/\n/g' \
    > /etc/dnscrypt-proxy/blocked-ips.txt
    0.0.0.0 127.0.0.* #1918 10.* 172.16.* 172.17.*
    172.18.* 172.19.* 172.20.* 172.21.* 172.22.*
    172.23.* 172.24.* 172.25.* 172.26.* 172.27.*
    172.28.* 172.29.* 172.30.* 172.31.* 192.168.*
EOF

    rc-update --quiet add dnscrypt-proxy default

    # perm
    chmod 600 /etc/doas.d/doas.conf
    chmod go-rwx /lib/modules /boot

    # rmfd
    find /etc/fish/* -type d -delete

    # cpco
    cp -r -T light/home "$dir"

    # user
    chown -R "${usn}":"${usn}" "${dir}"

    chmod go-rwx "$dir"
    chmod -R g-s "$dir"

    printf \\n

    printf "\033[37;7m# reboot \033[0m"
