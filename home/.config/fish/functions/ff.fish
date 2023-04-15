function ff
    argparse -X 0 'h' 'x' 'r' 'e' 'help' -- $argv
    or return

    if set -q _flag_h
        find /home -maxdepth 10 -type f | sort \
        | fzf --reverse --color=bw --preview 'head -150 {}' \
        --bind '!:toggle-preview,?:execute(nvim {1})' --preview-window=:hidden --exact
        return 0
    end

    if set -q _flag_x
        find /home -maxdepth 10 -executable -type f | sort \
        | fzf --reverse --color=bw --preview 'head -150 {}' \
        --bind '!:toggle-preview,?:execute(nvim {1})' --preview-window=:hidden
        return 0
    end

    if set -q _flag_r
        find / -path /home -prune -o -maxdepth 10 -type f -print 2>/dev/null | sort \
        | fzf --reverse --color=bw --preview 'head -150 {}' \
        --bind '!:toggle-preview,?:execute(nvim {1})' --preview-window=:hidden --exact
        return 0
    end

    if set -q _flag_e
        find / -path /home -prune -o -maxdepth 10 -type f -print 2>/dev/null | sort \
        | fzf --reverse --color=bw --preview 'head -150 {}' \
        --bind '!:toggle-preview,enter:become(doasedit {})' --preview-window=:hidden -e
        return 0
    end

    if set -q _flag_help
        echo '
        ff: find file

        ( [h]ome e[x]ecutables [r]oot [e]dit: / )

        $ ff -h
        $ ff -x
        $ ff -r
        $ ff -e → ... → ⏎

        toggle preview: !
        open in neovim: ?
        ' | cut -c9-
        return 0
    end

    return 1
end
