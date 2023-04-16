function cd
    if not test "$argv" = ''
        builtin cd $argv
        and ls -lh -A -p -X
    else
        builtin cd ~
    end
end
