function man
    command man $argv | less -m -n -q -F -w -e -i
end
