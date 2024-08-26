function nt
    if test ! -d ~/.notes
        mkdir ~/.notes
        touch ~/.notes/nt
    end

    if not set -q argv[1]
        sed = ~/.notes/nt | sed 'N;s/\n/    /' \
        | less +G -S -m -n -i
        return 0
    end

    set -l opt e s r b a h

    argparse $opt -- $argv
    or return

    if set -q _flag_e
        if not set -q argv[1]
            nvim ~/.notes/nt
        else
            return 1
        end
        return 0
    end

    if set -q _flag_s
        if set -q argv[1]
            printf \\n
            grep -i -w -- "$argv[1]" ~/.notes/nt
            printf \\n
        else
            return 1
        end
        return 0
    end

    if set -q _flag_r
        if string match -rq '^[1-9]\d*$' -- $argv[1]
            set -l total_lines (wc -l < ~/.notes/nt)
            if test "$argv[1]" -le "$total_lines"
                sed -i ''"$argv[1]"'d' ~/.notes/nt
                echo "note no. $argv[1] : removed"
                return 0
            else
                echo "
                valid range is: 1 to $total_lines
                "
                return 1
            end
        else
            echo "
             invalid. provide a valid note number
             "
            return 1
        end
    end

    if set -q _flag_b
        if not set -q argv[1]
            cp $HOME/.notes/nt $HOME/.notes/nt.bak
            printf ".notes/nt \u21B7 .notes/nt.bak"
        else
            echo "
            backup failed
            "
            return 1
        end
        return 0
    end

    if set -q _flag_a
        if not set -q argv[1]
            read -laP 'note: ' note
            if set -q note[1]
                printf %s\\n "$note" >> ~/.notes/nt
                return 0
            else
                echo "
                no note added
                "
                return 1
            end
        else
            echo '
            invalid usage. valid usage: $ nt -a + ↵
            '
            return 1
        end
    end

    if set -q _flag_h
        if not set -q argv[1]
            echo '
            $ nt

            [b]ackup [e]dit [a]dd [s]earch [r]emove

            $ nt
            $ nt -b
            $ nt -e
            $ nt -a  enter
            $ nt -s <query>
            $ nt -r <number>
            ' | cut -c 13-
        else
            return 1
        end
        return 0
    end
end
