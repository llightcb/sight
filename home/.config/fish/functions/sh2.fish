function sh2
    if test (count $argv) -eq 1 -a -d "$argv"
        echo "
        rsync /home/ to: $argv
        "
        while true
            read -l -P '--exclude? (y/n) ' ch
            switch $ch
                case y
                    read -laP '--exclude: ' pt
                    set -l ma (string match -r '[^\w.*/-]' -- $pt)
                    if test -n "$ma"
                        set_color red
                        printf '\n%s\n\n' "$ma :invalid character for list"
                        return 1
                    end
                    rsync -aAXv --delete --exclude-from=(string split ' ' \
                        -- $pt | psub) /home/ $argv
                    return 0
                case n
                    rsync -aAXv --delete /home/ $argv
                    return 0
            end
        end
    else
        return 1
    end
end
