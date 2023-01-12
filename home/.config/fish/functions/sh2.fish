function sh2
    if test (count $argv) -eq 1 -a -d "$argv"
        printf \\n
        echo "rsync /home/ to: $argv"
        printf \\n
        while true
            read -l -P '--exclude? (y/n) ' ch
            printf \\n
            switch $ch
                case y
                    read -l -a -P '--exclude: ' pat
                    printf \\n
                    if string match -r -q '[^\w.*/-]' -- $pat
                        set -l ma (string match -r '[^\w.*/-]' -- $pat)
                        echo -- "$ma is an invalid character for a list"
                        return 1
                    end
                    rsync -aAXv --delete --exclude-from=(string split ' ' -- $pat | psub) /home/ $argv
                    break
                case n
                    rsync -aAXv --delete /home/ $argv
                    break
            end
        end
    end
end
