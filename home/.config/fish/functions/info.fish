function info
    set -l flgs d s k c l m h/help

    argparse -X 0 $flgs -- $argv
    or return

    if set -q _flag_d
        less -mnSwei (doas dmesg | psub)
        return 0
    end

    if set -q _flag_s
        less -mnSwei /var/log/messages
        return 0
    end

    if set -q _flag_k
        read -lP 'search for: ' sfo
        zcat /proc/config.gz \
        | grep -i $sfo | less -nicJ
        return 0
    end

    if set -q _flag_l
        lsmod | sort \
        | less -mnSwi
        return 0
    end

    if set -q _flag_c
        sysctl -a \
        | less -i
        return 0
    end

    if set -q _flag_m
        modprobe --showconfig \
        | grep -E 'blacklist|/bin/true' \
        | less -mnFwi
        return 0
    end

    if set -q _flag_h
        echo '
        info: [d]mesg [k]ernel [l]smod
        [s]yslog sys[c]tl [m]odprobe b

        $ info -d
        $ info -k
        $ info -l
        $ info -s
        $ info -c
        $ info -m
        ' | cut -c9-
        return 0
    end

    return 1
end
