function cpu
    argparse -X 0 's' 't' 'h/help' -- $argv
    or return

    if set -q _flag_s
        mpstat -P ALL 5
        return 0
    end

    if set -q _flag_t
        top -b -n 1 | head -n12  | tail -n8
        return 0
    end

    if set -q _flag_h
        echo '
        ( cpu: mp[s]at [t]op )

        $ cpu -s
        $ cpu -t
        ' | cut -c 9-
        return 0
    end

    return 1
end
