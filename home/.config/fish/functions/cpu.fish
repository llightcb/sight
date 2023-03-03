function cpu
    argparse -X0 's' 't' 'i' 'h/help' -- $argv
    or return

    if set -q _flag_s
        mpstat -P ALL 5
        return 0
    end

    if set -q _flag_t
        top -b -n 1 | head -n 12  | tail -n 8
        return 0
    end

    if set -q _flag_i
        iostat -tc 5 5
        return 0
    end

    if set -q _flag_h
        echo '
        ( cpu: mp[s]at [t]op [i]ostat )

        $ cpu -s
        $ cpu -t
        $ cpu -i
        ' | cut -c 9-
        return 0
    end

    return 1
end
