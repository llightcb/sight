function info
    argparse -X 0 'd' 's' 'k' 'c' 'l' 'h/help' -- $argv
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

    if set -q _flag_h
        echo '
        info: [d]mesg [k]ernel [l]smod [s]yslog sys[c]tl

        $ info -d
        $ info -k
        $ info -l
        $ info -s
        $ info -c
        ' | cut -c9-
        return 0
    end

    return 1
end
