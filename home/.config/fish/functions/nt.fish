function nt
    if test ! -d ~/.notes
        mkdir ~/.notes
        touch ~/.notes/nt
    end

    if not set -q argv[1]
        sed = ~/.notes/nt | sed 'N;s/\n/    /' \
        | less -S -m -n -i
        return 0
    end

    set -l opt b a s r h

    argparse $opt -- $argv
    or return

    if set -q _flag_a
        read -laP 'note: ' note
        if set -q note[1]
            printf %s\\n "$note" >> ~/.notes/nt
        end
        return 0
    end

    if set -q _flag_s
        if set -q argv[1]
            printf \\n
            grep -i -w -- "$argv[1]" ~/.notes/nt
            printf \\n
        end
        return 0
    end

    if set -q _flag_r
        if string match -rq '^[\d]+$' -- $argv[1]
            sed -i ''"$argv[1]"'d' ~/.notes/nt
            echo "note no. $argv[1] : removed"
        end
        return 0
    end

    if set -q _flag_b
        if not set -q argv[1]
            cp $HOME/.notes/nt $HOME/.notes/nt.bak
            printf ".notes/nt \u21B7 .notes/nt.bak"
        end
        return 0
    end

    if set -q _flag_h
        if not set -q argv[1]
            echo '
            nt ( [a]dd [s]earch [r]emove [b]ackup )

            $ nt
            $ nt -b
            $ nt -a
            $ nt -s <query>
            $ nt -r <number>
            ' | cut -c 13-
        end
        return 0
    end

    return 1
end
