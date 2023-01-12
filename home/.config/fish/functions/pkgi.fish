function pkgi --description 'for starters'
    set -l opt f d r l lv s a p c e w h

    argparse -X1 $opt -- $argv
    or return

    if set -q _flag_f
        if set -q argv[1]
            apk info -a $argv[1]
        end
        return 0
    end

    if set -q _flag_d
        if set -q argv[1]
            apk info -R $argv[1]
        end
        return 0
    end

    if set -q _flag_r
        if set -q argv[1]
            apk info -r $argv[1]
        end
        return 0
    end

    if set -q _flag_l
        if not set -q argv[1]
            apk info | sort \
            | less -i
        end
        return 0
    end

    if set -q _flag_lv
        if not set -q argv[1]
            apk info -vv | sort \
            | less -i
        end
        return 0
    end

    if set -q _flag_s
        if not set -q argv[1]
            apk stats
        end
        return 0
    end

    if set -q _flag_a
        if not set -q argv[1]
            doas apk update
            printf \\n
            apk version -vl '<'
        end
        return 0
    end

    if set -q _flag_p
        if set -q argv[1]
            apk policy $argv[1]
        end
        return 0
    end

    if set -q _flag_c
        if set -q argv[1]
            apk -L info $argv[1]
        end
        return 0
    end

    if set -q _flag_e
        if set -q argv[1]
            apk -e info $argv[1]
        end
        return 0
    end

    if set -q _flag_w
        if set -q argv[1]
            apk info -d $argv[1]
        end
        return 0
    end

    if set -q _flag_h
        if not set -q argv[1]
            echo '
            pkgi ( package information )

            [a]vailable    $ pkgi -a          = $ apk version -vl \'<\'
            [l]ist ↓[v]    $ pkgi --lv        = $ apk info -vv
            [l]ist ↓ !v    $ pkgi -l          = $ apk info
            [s]ats full    $ pkgi -s          = $ apk stats
            [f]ull info    $ pkgi -f <pgk>    = $ apk info -a <pkg>
            [d]epends ←    $ pkgi -d <pkg>    = $ apk info -R <pkg>
            [r]required    $ pkgi -r <pkg>    = $ apk info -r <pkg>
            [c]ontains?    $ pkgi -c <pkg>    = $ apk -L info <pkg>
            [e]xamine ↓    $ pkgi -e <pkg>    = $ apk -e info <pkg>
            [p]olicy  →    $ pkgi -p <pkg>    = $ apk policy  <pkg>
            [w]hat is →    $ pkgi -w <pkg>    = $ apk info -d <pkg>
            ' | cut -c13-
        end
        return 0
    end

    return 1
end
