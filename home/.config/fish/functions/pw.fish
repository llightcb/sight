function pw
    set -l opts v e d h/help

    argparse -X1 $opts -- $argv
    or return

    set -l iter 500000

    if set -q _flag_v
        if test -e "$argv[1]"
            if string match -q '*.enc' -- $argv[1]
                less -m -n -q -S -w -e -i (openssl enc -aes-256-cbc -salt -md sha256 -pbkdf2 \
                -iter $iter -a -d -in $argv[1] -pass file:(read -s -P 'pwd: ' | psub) | psub)
            end
        end
        return
    end

    if set -q _flag_e
        if test -f "$argv[1]"
            if string match -vq '*.enc' -- $argv[1]
                read -slP 'pwd: ' pf; read -slP 'repeat pwd: ' pse
                if test "$pf" != "$pse"
                    echo "error: pwd doesn't match"
                    return 1
                end
                openssl enc -aes-256-cbc -salt -md sha256 -pbkdf2 -iter $iter -a -in $argv[1] \
                -out pass.enc -pass file:(printf %s "$pf" | psub)
                printf \\n; echo ".. encoded file: $PWD/pass.enc"
                while true
                    read -lP "remove file: \"$argv[1]\" (y/n) " ch
                    switch $ch
                        case y
                            shred -z -u -- $argv[1]
                            return 0
                        case n
                            return 0
                    end
                end
            end
        end
        return
    end

    if set -q _flag_d
        if test -e "$argv[1]"
            if string match -q '*.enc' -- $argv[1]
                openssl enc -aes-256-cbc -salt -md sha256 -pbkdf2 -iter $iter -a -d -in $argv[1] \
                -pass file:(read -s -P 'pwd: ' | psub) -out pass
                and /bin/rm -i -v -- $argv[1]
                echo "decoded file: $PWD/pass"
            end
        end
        return
    end

    if set -q _flag_h
        if not set -q argv[1]
            echo '
            pw ( [v]iew [e]ncode [d]ecode )

            $ pw -v <file>
            $ pw -e <file>
            $ pw -d <file>
            ' | cut -c13-
        end
        return
    end

    return 1
end
