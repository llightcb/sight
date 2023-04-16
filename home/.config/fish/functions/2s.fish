function 2s
    argparse -X 0 'c' 'd' 'f' 'h'  -- $argv

    set -l ma (getconf LONG_BIT)

    if set -q _flag_d
        read -l -P 'enter 2s: ' br
        printf 'n=%d; ibase=2; v=%s; v-2^n*(v/2^(n-1))\n' "$ma" "$br[1]" | bc
        return 0
    end

    if set -q _flag_c
        read -l -P 'enter dec: ' dec
        printf 'obase=2; 2^%d+%d\n' \
        "$ma" "$dec[1]" | bc \
        | sed -E "s/.*(.{$ma})\$/\1/"
        return 0
    end

    if set -q _flag_f
        printf \\n
        read -l -P 'enter 2s a: ' br_1
        read -l -P 'enter 2s b: ' br_2
        yes '' | sed 2q
        git diff --color --no-index (echo $br_1 | psub) (echo $br_2 | psub) \
        | diff-highlight | sed '6,7!d'
        yes '' | sed 2q
        return 0
    end

    if set -q _flag_h
        echo '
        ( two\'s complement ←→ decimal no. )

        dec → 2s [c]omplement
        2s complement → [d]ec
        dif[f] 2s complements

        $ 2s -c
        $ 2s -d
        $ 2s -f
        ' | cut -c 9-
    end
end
