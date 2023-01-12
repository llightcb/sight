function fish_prompt
    set -l green (set_color -o green)
    set -l cyan (set_color -o cyan)
    set -l normal (set_color normal)

    set -l arrow_color "$green"
    set -l arrow "$arrow_color➜ "

    set -l cwd $cyan(basename (prompt_pwd))
    echo -n -s $arrow ' '$cwd $normal ' '
end
