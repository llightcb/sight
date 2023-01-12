function cd
    if test ! "$argv" = ''
        builtin cd $argv
        and ls -l -h -A -X
    else
        builtin cd ~
    end
end
