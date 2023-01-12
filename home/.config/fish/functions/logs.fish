function logs
    argparse -X 0 'd' 's' 'l' 'h/help' -- $argv
    or return

    if set -q _flag_d
        less -mnSwei (doas dmesg | psub)
        return 0
    end

    if set -q _flag_s
        less -mnSwei /var/log/messages
        return 0
    end

    if set -q _flag_l
        lsmod | sort \
        | less -mnSwi
        return 0
    end

    if set -q _flag_h
        echo '
        (logs: [d]mesg [l]smod [s]yslog)

        $ logs -d
        $ logs -l
        $ logs -s
        ' | cut -c9-
        return 0
    end

    return 1
end
