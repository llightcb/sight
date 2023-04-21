function 2s # bitwise h
    set -l flgs c d f h

    argparse -X 0 $flgs -- $argv
    or return

    set -l ma (getconf LONG_BIT)

    if set -q _flag_d
        while true
            read -lP '
            done: (d)
            enter 2s:
            → ' br
            switch $br
                case d
                    return 0
                case '*'
                    set_color red
                    echo -- "
                    $(printf 'n=%d; ibase=2; v=%s; v-2^n*(v/2^(n-1))\n' \
                    "$ma" "$br" | bc)" | cut -c6-
            end
        end
    end

    if set -q _flag_c
        while true
            read -lP '
            done: (d)
            enter dec:
            → ' dec
            switch $dec
                case d
                    return 0
                case '*'
                    set_color red
                    echo -- "
                    $(printf 'obase=2; 2^%d+%d\n' "$ma" "$dec[1]" \
                    | bc | sed -E "s/.*(.{$ma})\$/\1/")" | cut -c6-
            end
        end
    end

    if set -q _flag_f
        for i in (seq 1 2)
            read -lP 'enter 2s: ' br
            set -f bk[$i] $br
        end
        yes '' | sed 1q
        git diff --color --no-index \
        (echo -- $bk[1] | psub) \
        (echo -- $bk[2] | psub) \
        | diff-highlight \
        | sed '6,7!d;$a\\'
        return 0
    end

    if set -q _flag_h
        echo '
        ( two\'s complement
            ←→ decimal no. )

        dec → 2s [c]omplement
        2s complement → [d]ec
        dif[f] 2s complements

        $ 2s -c
        $ 2s -d
        $ 2s -f
        ' | cut -c 9-
        return 0
    end

    return 1
end
