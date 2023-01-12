function sfm
    argparse -X0 'p' 's' 'h' -- $argv
    or return

    if set -q _flag_p
        if pgrep ffplay >/dev/null
            pkill ffplay
            or return 1
        end
        while true
            read -l -P 'ambient, drone, chill, n5md, live, loud, defcon, u80s, jazz, or exit? (a/d/c/n/v/l/f/u/j/x) ' choice
            switch $choice
                case a
                    set -f url (curl --silent 'https://somafm.com/deepspaceone32.pls' 2>&1 | grep -i '^file1' | cut -d '=' -f 2-)
                    break
                case d
                    set -f url (curl --silent 'https://somafm.com/dronezone32.pls' 2>&1 | grep -i '^file1' | cut -d '=' -f2-)
                    break
                case c
                    set -f url (curl -s 'https://somafm.com/spacestation32.pls' 2>&1 | grep -i '^file1' | cut -d '=' -f2-)
                    break
                case n
                    set -f url (curl --silent 'https://somafm.com/n5md32.pls' 2>&1 | grep -i '^file1' | cut -d '=' -f 2-)
                    break
                case v
                    set -f url (curl --silent 'https://somafm.com/live32.pls' 2>&1 | grep -i '^file1' | cut -d '=' -f 2-)
                    break
                case l
                    set -f url (curl --silent 'https://somafm.com/metal32.pls' 2>&1 | grep -i '^file1' | cut -d '=' -f2-)
                    break
                case f
                    set -f url (curl --silent 'https://somafm.com/defcon32.pls' 2>&1 | grep -i '^file1' | cut -d '=' -f2-)
                    break
                case u
                    set -f url (curl --silent 'https://somafm.com/u80s32.pls' 2>&1 | grep -i '^file1' | cut -d '=' -f 2-)
                    break
                case j
                    set -f url (curl --silent 'https://somafm.com/sonicuniverse32.pls' 2>&1 | grep -i '^file1' | cut -d '=' -f2-)
                    break
                case x
                    return 0
            end
        end
        ffplay -volume 100 -vn -nodisp -hide_banner -nostats -loglevel fatal -infbuf -i $url[1] >/dev/null 2>&1 <&1 & disown
        return 0
    end

    if set -q _flag_s
        pkill ffplay
        and return 0
    end

    if set -q _flag_h
        echo '
        ( somafm )

        [p]lay [s]top

        $ sfm -p
        $ sfm -s
        ' | cut -c 9-
        return 0
    end

    return 1
end
