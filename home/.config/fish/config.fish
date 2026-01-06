if status is-interactive
    ## theme
    set -g fish_pager_color_selected_background --background=FF9940
    set -g fish_pager_color_progress brwhite --background=cyan
    set -g fish_pager_color_prefix normal --bold --underline
    set -g fish_color_search_match --background=FF9940
    set -g fish_color_selection --background=FF9940
    set -g fish_pager_color_description B3A06D
    set --global fish_color_status red
    set --global fish_color_end ED9366
    set --global fish_color_cwd 399EE6
    set --global fish_color_host normal
    set --global fish_color_user brgreen
    set --global fish_color_match F07171
    set --global fish_color_cwd_root red
    set --global fish_color_param 575F66
    set --global fish_color_quote 86B300
    set --global fish_color_error F51818
    set --global fish_color_escape 4CBF99
    set --global fish_color_normal 575F66
    set --global fish_color_command 55B4D4
    set --global fish_color_comment ABB0B6
    set --global fish_color_operator FF9940
    set --global fish_color_cancel --reverse
    set --global fish_color_host_remote yellow
    set --global fish_color_redirection A37ACC
    set --global fish_color_autosuggestion 8A9199
    set --global fish_color_history_current --bold
    set --global fish_color_valid_path --underline
    set --global fish_pager_color_completion normal

    ## abbr
    abbr -a fa 'unshare -rn -- fastfetch -c all -l small'
    abbr -a gl 'git log --graph --decorate --oneline'
    abbr -a gpf 'git push --force-with-lease'
    abbr -a hdc ' history delete --contains'
    abbr -a rs 'command printf "\033c"'
    abbr -a gri 'git rebase -i HEAD~'
    abbr -a gba 'git branch -a'
    abbr -a gco 'git checkout'
    abbr -a gc 'git commit -m'
    abbr -a gs 'git status'
    abbr -a gm 'git merge'
    abbr -a gp 'git push'
    abbr -a ga 'git add'
    abbr -a pw ' pw'
    abbr -a nt ' nt'
    abbr -a vi 'nvim'
    abbr -a de 'doasedit'
    abbr -a ll 'ls -lhApX'
    abbr -a nnn 'nnn -CHUide'
    abbr -a lc 'plocate -l80'
    abbr -a rm ' rm -v -r --'
    abbr -a rca 'rc-status -a'
    abbr -a fp 'fish --private'
    abbr -a cc 'wl-copy --clear'
    abbr -a pdf 'zathura --fork'

    ## misc
    set --global fish_greeting ""

    ## bind
    set -g fish_key_bindings fish_default_key_bindings

    bind ctrl-x 'wl-copy --clear'
    bind \el "commandline --insert 'less -mnwic '"

    ## func
    function mcd
        echo cd (string repeat -n \
        (math (string length -- $argv[1]) - 1) ../)
    end
    abbr -a dotdot --regex '^\.\.+$' --function mcd
end
