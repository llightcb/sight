function pw
    set -l opts 'v' 'e' 'd' 'h'

    argparse -X1 $opts -- $argv
    or return

    set -f iter 500000

    if set -q _flag_v
        if test -e "$argv[1]"
            if string match -q '*.enc' -- $argv[1]
                set -l if_r $argv[1]
                read -slP 'pwd: ' pr
                set -l hasr (echo -n -- $pr | openssl dgst -sha256)
                less -m -n -q -S -w -i (openssl enc -aes-256-cbc -salt -md sha256 -pbkdf2 \
                -iter $iter -a -d -in $if_r -pass file:(printf %s $hasr | psub) | psub)
            else
                return 1
            end
        else
            return 1
        end
        return 0
    end

    if set -q _flag_e
        if test -e "$argv[1]"
            if string match -vq '*.enc' -- $argv[1]
                set -l if_e $argv[1]
                set -l of_e {$if_e}.enc
                read -slP 'pwd: ' pe; read -slP 'repeat pwd: ' pse
                if test "$pe" != "$pse"
                    echo "error: pwd doesn't match"
                    return 1
                end
                set -l hase (echo -n -- $pe | openssl dgst -sha256)
                openssl enc -aes-256-cbc -salt -md sha256 -pbkdf2 -iter $iter -a -in $if_e \
                -out $of_e -pass file:(printf %s "$hase" | psub)
                printf \\n; echo ".... encoded file: $PWD/$of_e"
                while true
                    read -l -P "remove file: \"$if_e\" (y/n) " ch
                    switch $ch
                        case y
                            shred -z -u -- $if_e
                            return 0
                        case n
                            return 0
                    end
                end
            else
                return 1
            end
        else
            return 1
        end
        return 0
    end

    if set -q _flag_d
        if test -e "$argv[1]"
            if string match -q '*.enc' -- $argv[1]
                set -l if_d $argv[1]
                set -l of_d (string sub -e -4 -- $if_d)
                read -slP 'pwd: ' pd
                set -l hasd (echo -n -- $pd | openssl dgst -sha256)
                openssl enc -aes-256-cbc -salt -md sha256 -pbkdf2 -iter $iter -a -d -in $if_d \
                -pass file:(printf %s "$hasd" | psub) -out $of_d
                and /bin/rm -i -v -- $if_d
                echo ".. decoded file: $PWD/$of_d"
            else
                return 1
            end
        else
            return 1
        end
        return 0
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
        return 0
    end

    return 1
end
