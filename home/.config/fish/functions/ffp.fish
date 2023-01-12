function ffp
    argparse -X1 't' 'l' 's' 'h/help' -- $argv
    or return

    if string length -q -- $_flag_t $_flag_l
        if set -q argv[1]
            if pgrep ffplay >/dev/null
                pkill ffplay
                or return 1
            end
        else
            return 1
        end
    end

    if set -q _flag_t
        if string match -q '*.txt' -- $argv[1]
            return 1
        end
        ffplay -volume 100 -vn -nodisp -hide_banner -nostats -loglevel fatal \
        -autoexit -noinfbuf -i $argv[1] >/dev/null 2>&1 <&1 & disown
        return 0
    end

    if set -q _flag_l
        if string match -vq '*.txt' -- $argv[1]
            return 1
        end
        ffplay -f concat -safe 0 -volume 100 -vn -nodisp -hide_banner -nostats \
        -loglevel fatal -autoexit -noinfbuf -i $argv[1] >/dev/null 2>&1 <&1 & disown
        return 0
    end

    if set -q _flag_s
        pkill ffplay
        and return 0
    end

    if set -q _flag_h
        echo '
        ( ffplay )

        play [t]rack [l]list
        [s]top

        $ ffp -t onetrack.mp3
        $ ffp -l playlist.txt
        $ ffp -s (stop)
        ' | cut -c 9-
        return 0
    end

    return 1
end
