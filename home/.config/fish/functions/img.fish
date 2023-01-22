function img
    argparse -X0 -- $argv
    or return

    if test -d ~/Pictures
        imv -fr ~/Pictures >/dev/null 2>&1 <&1 & disown
    else
        echo "$HOME/Pictures does not exist"
    end
end
