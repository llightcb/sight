function mpc
    modprobe --showconfig | grep -E -- 'blacklist|/bin/true' | less -m -n -q -F -w -e -i
end
