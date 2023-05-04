if status is-interactive
    # commands to run in interactive sessions can go here
    abbr -a gl 'git log --graph --decorate --oneline'
    abbr -a gpf 'git push --force-with-lease'
    abbr -a hdc ' history delete --contains'
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
    abbr -a rs 'tput reset'
    abbr -a nnn 'nnn -CHUide'
    abbr -a lc 'plocate -l80'
    abbr -a rm 'rm  -v -r --'
    abbr -a rca 'rc-status -a'
    abbr -a fp 'fish --private'
    abbr -a pdf 'zathura --fork'

    bind \el "commandline --insert 'less -mnJwic '"

    function mcd
        echo cd (string repeat -n \
        (math (string length -- $argv[1]) - 1) ../)
    end
    abbr -a dotdot --regex '^\.\.+$' --function mcd
end
