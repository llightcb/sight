if status is-interactive
    # Commands to run in interactive sessions can go here
    abbr -a gl 'git log --graph --decorate --oneline'
    abbr -a gpf 'git push --force-with-lease'
    abbr -a gp 'git push'
    abbr -a gm 'git merge'
    abbr -a gba 'git branch -a'
    abbr -a gc 'git commit -m'
    abbr -a ga 'git add'
    abbr -a gco 'git checkout'
    abbr -a 2fa ' 2fa'
    abbr -a fhd ' fhd'
    abbr -a gri 'git rebase -i'
    abbr -a gs 'git status'
    abbr -a nt ' nt'
    abbr -a pdf 'zathura --fork'
    abbr -a pw ' pw'
    abbr -a rca 'rc-status -a'
    abbr -a rm ' rm  -v -r --'
    abbr -a fp 'fish --private'

    function mcd
        echo cd (string repeat -n (math (string length -- $argv[1]) - 1) ../)
    end
    abbr -a dotdot --regex '^\.\.+$' --function mcd
end
