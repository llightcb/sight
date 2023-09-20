function pw
    set -l opts 'v' 'e' 'd' 'h'

    argparse -X1 $opts -- $argv
    or return

    set -f iter 1000000
    set -f -x LESSSECURE 1
    set -f algo aes-256-cbc

    if set -q _flag_v
        if test -e "$argv[1]"
            if string match -q '*.enc' -- $argv[1]
                set -l if_r $argv[1]
                read -slP 'pwd: ' pr
                set -l hasr (echo -n -- $pr | openssl dgst -sha256)
                set -l decrypt_cont (openssl enc -{$algo} -salt -md sha256 -pbkdf2 \
                -iter $iter -a -d -in $if_r -pass file:(printf %s $hasr | psub) 2>&1)
                if not test "$status" -eq 0
                    echo "error: wrong password. decryption failed"
                    return 1
                else
                    less -RnSic (printf %s\\n $decrypt_cont | psub)
                    return 0
                end
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
                openssl enc -{$algo} -salt -md sha256 -pbkdf2 -iter $iter -a -in $if_e \
                -out $of_e -pass file:(printf %s "$hase" | psub)
                if not test "$status" -eq 0
                    return 1
                end
                printf \\n; echo ".... encoded file: $PWD/$of_e"
                while true
                    read -l -P "remove file: \"$if_e\" (y/n) " ch
                    switch $ch
                        case y
                            /bin/rm -v -- $if_e
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
                openssl enc -{$algo} -salt -md sha256 -pbkdf2 -iter $iter -a -d -in $if_d \
                -pass file:(printf %s "$hasd" | psub) -out $of_d
                if test "$status" -eq 0
                    /bin/rm -iv -- $if_d
                    echo ".. decoded file: $PWD/$of_d"
                else
                    /bin/rm -- $of_d
                    return 1
                end
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
