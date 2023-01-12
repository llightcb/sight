function gd
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1
        git diff --color=always $argv | less -R -i -w
    end
end
