#!/bin/sh
# shellcheck disable=SC3043

    sw_p() {
        grep -Ewq '(partition|file)' /proc/swaps
    }

    vech() {
        local IFS=" "
        printf %s "$*"
    }

    RV() {
        setup-apkrepos
        exec "$0"
    }

    vi_m() {
        virt-what \
        | grep -q ''
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

    # notice
    if subs sight "$PWD"; then
        printf "\033[37;7merror\033[0m script executed from: %s\n" "$PWD"
        exit 1
    fi

    # ruser
    rmuser="$(grep -E 'x:[1-9]([0-9]){3}:' /etc/passwd | cut -d ':' -f1)"

    if test -n "$rmuser"; then
        deluser \
        --remove-home "$rmuser"
    fi

    # notice
    apk add pciutils >/dev/null

    if lspci -k | grep -i -C 2 -E 'vga|3d' | grep -i -q -w 'nvidia'; then
        printf "\033[37;7msorry,\033[0m sight does not support: nvidia\n"
        exit 1
    fi

    # apkr
    repos=/etc/apk/repositories;sed -Ei 's/^(ftp|http\>)/https/' "$repos"

    ext="$(sed -n '/^[^#]/ { s|\(.*\)/v[0-9.]\+/.*$|\1|p; q }' "$repos")"

    cut -c 5- <<EOF > "$repos"
    ${ext}/edge/main
    ${ext}/edge/community
    @edtst ${ext}/edge/testing
EOF

    if ! wget -qY off -T5 --spider "$(grep -m 1 '^https' "$repos")"; then
        printf "\033[37;7merror\033[0m try another mirror - in 5 seconds"
        sleep 5; true >"$repos"; RV
    fi

    apk add -Uq --upgrade apk-tools

    # fsbin
    sed -Ei 's/^tty(3|4|5|6)/#&/' \
    /etc/inittab # at least : 1 + 2

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

    mv sight "$dir"

    cd "$dir" \
    || exit 1

    # start
    apk upgrade --available

    cut -c 5- <<'THX2ALL' \
    | xargs -n1 -t apk add
    xdg-desktop-portal-wlr oath-toolkit-oathtool doas
    mesa-vdpau-gallium zathura-pdf-mupdf inxi imv
    pcre2-tools autotiling@edtst mpv nnn ffplay
    mesa-dri-gallium mesa-va-gallium dbus zzz
    dnscrypt-proxy wireless-regdb foot
    pipewire-alsa wireplumber curl
    iproute2-ss alsa-utils sway
    ttf-dejavu shellcheck jq
    wl-clipboard py3-pip
    xdg-utils swayidle
    man-db doas-doc
    apk-tools-doc
    git-diff-highlight
    pipewire nftables shfmt
    newsboat powertop wayland
    chromium i3status xwayland
    virt-what yt-dlp tcpdump wipefs
    python3 plocate neovim neovim-doc
    light seatd drill slurp fish less grim
    nethogs swaybg hdparm irssi lsblk rsync
    qemu qemu-img qemu-system-x86_64 qemu-ui-gtk
    qemu-hw-display-virtio-gpu qemu-hw-display-qxl
    qemu-hw-display-virtio-gpu-pci fzf doasedit@edtst
THX2ALL

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
    adduser "$usn" qemu
    adduser root audio
    adduser "$usn" kvm
    adduser "$usn" seat
    adduser "$usn" input
    adduser "$usn" audio

    # udev
    setup-devd udev > /dev/null

    # loho
    hna="$(cat /etc/hostname)"

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

    # rvcf
    cut -c 5- <<EOF > /etc/resolv.conf
    nameserver 127.0.0.1
    options edns0
EOF

    # snet
    rc-service -sqq networking restart
    rc-service -q dnscrypt-proxy start

    # kepa
    if ! vi_m; then
        cut -c 9- <<EOF \
        >>/etc/sysctl.conf
        kernel.core_pattern=|/bin/true
        kernel.yama.ptrace_scope=3
        fs.protected_hardlinks=1
        fs.protected_symlinks=1
        fs.protected_fifos=1
        kernel.panic=30
        kernel.sysrq=0
        fs.suid_dumpable=0
        kernel.nmi_watchdog=0
        fs.protected_regular=1
        dev.tty.ldisc_autoload=0
        vm.oom_kill_allocating_task=1
EOF
    fi

    if sw_p \
    && test -d /sys/firmware/efi; then
        cut -c 9- <<EOF \
        >>/etc/sysctl.conf
        vm.swappiness=25
        vm.page-cluster=2
        vm.dirty_ratio=50
        vm.vfs_cache_pressure=50
        vm.dirty_background_ratio=20
EOF
    elif vi_m; then
        cut -c 9- <<EOF \
        >>/etc/sysctl.conf
        vm.swappiness=0
        vm.dirty_ratio=10
        vm.dirty_background_ratio=5
        vm.dirty_expire_centisecs=1500
EOF
    else
        : <<'NOTHING'
        ∴ lv default kernel parameters
NOTHING
    fi

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

    # noom
    cut -c5- <<'EOF' >/etc/local.d/60-mfr.start
    #!/bin/sh
    #
    MM="$(grep '^MemTotal:' /proc/meminfo \
    | tr -s ' ' | cut -d ' ' -f2)"

    if test "$MM" -lt 524288; then
        sysctl -q -w vm.min_free_kbytes=12800
    elif test "$MM" -lt 1048576; then
        sysctl -q -w vm.min_free_kbytes=64000
    elif test "$MM" -lt 2097152; then
        sysctl -q -w vm.min_free_kbytes=128000
    elif test "$MM" -lt 4194304; then
        sysctl -q -w vm.min_free_kbytes=256000
    elif test "$MM" -lt 8388608; then
        sysctl -q -w vm.min_free_kbytes=512000
    else
        sysctl -q -w vm.min_free_kbytes=1024000
    fi

    exit 0
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
    > sight/home/.config/sway/odpms.sh
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

    exit 0
EOF
    chmod +x sight/home/.config/sway/odpms.sh

    # wsdp
    cut -c5- <<'EOF' \
    >/etc/local.d/80-cwsync.start
    #!/bin/sh
    #
    if rc-service -q -q chronyd status; then
        grep -i -q 'makestep' \
        /etc/chrony/chrony.conf \
        && chronyc waitsync 6
    fi

    exit 0
EOF

    if rc-service -e chronyd; then
        sed -i 's/^\(ARGS\)=.*/\1="-4"/' \
        /etc/conf.d/chronyd
        chmod +x /etc/local.d/80-cwsync.start
    fi

    # cdlv
    echo "rc_verbose=yes" > /etc/conf.d/local

    # jinc
    mkdir -p /etc/udhcpc

    cut -c 5- <<EOF > /etc/udhcpc/udhcpc.conf
    RESOLV_CONF="no"
EOF

    # trim
    cut -c5- <<'EOF' \
    | tee /etc/periodic/weekly/trim >/dev/null
    #!/bin/sh
    #
    lsblk -o MOUNTPOINT,DISC-MAX,FSTYPE \
    | grep -E '^/.* [1-9]+.* ' \
    | cut -d ' ' -f1 | sort -u \
    | while IFS= read -r fsy; do
        fstrim "$fsy"
    done

    exit 0
EOF

    # lbat
    cut -c5- <<'EOF' \
    | tee /etc/periodic/5min/lowbat >/dev/null
    #!/bin/sh
    #
    export XDG_RUNTIME_DIR=/tmp/1000-runtime-dir
    batt="$(ls -d /sys/class/power_supply/BAT*)"
    ac="$(cat /sys/class/power_supply/A*/online)"
    lv="$(cat "$batt"/capacity)"

    if test "$ac" -eq 1; then
        exit 0
    fi

    if test "$lv" -ge 12; then
        exit 0
    elif test "$lv" -le 11 -a "$lv" -ge 8; then
        timeout 4 speaker-test -p 1024 \
        --frequency 400 -t sine >/dev/null 2>&1
    elif test "$lv" -le 7 -a "$lv" -ge 5; then
        timeout 20 speaker-test -p 1024 \
        --frequency 500 -t sine >/dev/null 2>&1
    else
        /sbin/poweroff -f # v sys-sleep-states↑
    fi

    exit 0
EOF

    # imvc
    mkdir -p sight/home/.config/imv

    cut -c5- <<'EOF' \
    > sight/home/.config/imv/config
    [binds]
    <x> = exec rm "$imv_current_file"; close
EOF

    # lout
    key="$(grep '^KE' /etc/conf.d/loadkmap \
    | sed -e 's/.*map\/\(.*\)\.bmap.*/\1/')"

    swco=sight/home/.config/sway/config

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

    # bfqs
    cut -c5- <<'EOF' \
    > /etc/local.d/50-schedr-bfq.start
    #!/bin/sh
    #
    lsblk -I8 -d -n --output NAME | while IFS= read -r d; do
        echo bfq > /sys/block/"$d"/queue/scheduler
        #grep -q 0 /sys/block/"$d"/queue/rotational \
        #&& echo 0 >/sys/block/"$d"/queue/iosched/slice_idle
    done

    exit 0
EOF
    chmod +x /etc/local.d/50-schedr-bfq.start

    # scrc
    cut -c5- <<EOF > sight/home/.shellcheckrc
    # example
    disable=SC3043
EOF

    # fish
    p_dir=\$HOME/Pictures; mkdir -p /etc/fish

    cat <<'EOF' \
    | tee -a /etc/fish/config.fish >/dev/null

    if status is-login
        if test -z "$XDG_RUNTIME_DIR"
            set -gx XDG_RUNTIME_DIR /tmp/(id -u)-runtime-dir
            if not test -d "$XDG_RUNTIME_DIR"
                mkdir $XDG_RUNTIME_DIR
                chmod 0700 $XDG_RUNTIME_DIR
            end
        end
    end
EOF

    sed '14s/[[:blank:]]\{8,\}/ /2' <<EOF \
    | tee -a /etc/fish/config.fish >/dev/null

    if status is-login
        set -gx TZ $TZ
        set -gx EDITOR nvim
        set -gx LANG C.UTF-8
        set -gx LC_CTYPE C.UTF-8
        set -gx LESSHISTFILE "-"
        set -gx ENV \$HOME/.ashrc
        set -gx PAGER less -mnwic
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

    # elp
    cut -c 5- <<'OPDOAS' > /etc/doas.conf
    permit persist :wheel
    permit nopass keepenv root
    permit nopass :wheel cmd reboot
    permit nopass :wheel cmd poweroff
OPDOAS

    # blc
    cut -c5- <<EOF \
    >>/etc/modprobe.d/blacklist.conf

    # additional
    install firewire-core /bin/true
    install uvcvideo /bin/true
    install bluetooth /bin/true
    install thunderbolt /bin/true
EOF

    # nbb
    mkdir -p sight/home/.newsboat

    cut -c5- <<'EOF' \
    > sight/home/.newsboat/config
    # general
    max-items 20

    # unbind
    unbind-key j
    unbind-key k
    unbind-key J
    unbind-key K

    # bind
    bind-key k up
    bind-key j down
EOF

    # conf
    lsmod | grep -wq '^configs' \
    || echo configs >>/etc/modules

    # idv
    chty="$(grep -E '8|9|10|14' \
    /sys/class/*/id/chassis_type)"

    # spl
    if test -n "$chty"; then
        mkdir -p /etc/acpi/LID
        cut -c9- <<EOF \
        > /etc/acpi/LID/00000080
        #!/bin/sh
        exec /usr/sbin/zzz -z # str
EOF
    chmod +x /etc/acpi/LID/00000080
    fi

    # ash
    cat <<'EOF' > sight/home/.ashrc
    # example function
    mcd() {
        mkdir -p $1; cd $1
    }

    # example aliases
    alias sora='source ~/.ashrc'
    alias rs='printf "\033c"'
    alias ll='ls -l -h -A -p -X'
EOF

    # grub
    if test -d /sys/firmware/efi
    then
        pa='page_alloc.shuffle=1 '
        prc=/proc/swaps
        zs='zswap.enabled=1 zswap.zpool=zsmalloc zswap.compressor=zstd '
        swp="$(grep -E -w '(partition|file)' $prc)"
        sed -i "s/LINUX_DEFAULT=\"/&$pa${swp:+$zs}/" /etc/default/grub
        grub-mkconfig --output=/boot/grub/grub.cfg
    fi

    # sbsh
    echo "export TZ='$TZ'" | tee /etc/profile.d/timezone.sh >/dev/null

    # plug
    shrt=raw.githubusercontent.com

    curl -fLs -o sight/home/.local/share/nvim/site/autoload/plug.vim \
    --create-dirs -4 https://"$shrt"/junegunn/vim-plug/master/plug.vim

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

    fc-cache -f; mkdir -p sight/home/.config/i3status

    # ibar
    cut -c 5- <<'EOF' \
    > sight/home/.config/i3status/config
    general {
            colors = false
            interval = 5
    }

    order += "wireless _first_"
    order += "ethernet _first_"
    order += "battery all"
    order += "tztime local"

    wireless _first_ {
            format_up = "W: (%quality at %essid) %ip"
            format_down = "W: down"
    }

    ethernet _first_ {
            format_up = "E: %ip (%speed)"
            format_down = "E: down"
    }

    battery all {
            format = "%status %percentage %remaining"
            last_full_capacity = true
    }

    tztime local {
            format = " %a %d-%m %H:%M "
    }
EOF

    # tPrc
    planck=/etc/rc.conf

    sed -i 's|^#\(rc_parallel=\).*|\1"YES"|' "$planck"

    # mime
    cut -c 5- <<EOF > sight/home/.config/mimeapps.list
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

    # vfoo
    if vi_m; then
        sed -i 's/^font=mon.*/font=monospace:size=12/' \
           sight/home/.config/foot/foot.ini
    fi

    # lbco
    if test -n "$chty" -a -n "$batt" -a -n "$adap"; then
        chmod +x /etc/periodic/5min/lowbat
    fi

    # nvmr
    if ! vi_m; then
        chmod +x /etc/local.d/60-mfr.start
        rc-update -qq add nftables default
    fi

    # a/mc
    set -- \
        quad9-dnscrypt-ip4-filter-pri doh-crypto-sx

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

    # foot
    p_cores="$(grep '^cpu cores' /proc/cpuinfo \
    | rev | sort -ub | cut -d' ' -f1)"

    sed -i "s/^#workers=/&$p_cores/" \
    sight/home/.config/foot/foot.ini

    # rmfd
    find /etc/fish/* -type d -delete

    # perm
    chmod +x /etc/periodic/weekly/trim
    chmod go-rwx /lib/modules /boot
    chmod 400 /etc/doas.conf # mr47141

    # cacp
    shift $#; cp -rT sight/home "$dir"

    # user
    chown -RP "${usn}":"${usn}" "$dir"

    chmod go-rwx "$dir"
    chmod -R g-s "$dir"

    # tend
    seq 3 | tr -d -c \\n

    getent passwd "$usn"

    printf \\n"
    \033[37;7mdone!\n reboot:\033[0m "
