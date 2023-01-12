function img
    if set -q argv[1]
        return 1
    end

    if test -d ~/Pictures
        imv -fr ~/Pictures >/dev/null 2>&1 <&1 & disown
    else
        echo "$HOME/Pictures does not exist"
    end
end
