function mpc
    argparse -X 0 -- $argv
    or return

    modprobe --showconfig \
    | grep -E -- 'blacklist|/bin/true' \
    | less -m -n -q -F -w -e -i
end
