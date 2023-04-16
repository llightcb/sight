function gd
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1
        git diff --color $argv | diff-highlight | less -Riw
    else
        return 1
    end
end
