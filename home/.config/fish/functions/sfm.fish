function sfm
    argparse -X0 'p' 's' 'h' -- $argv
    or return

    if set -q _flag_p
        if pgrep ffplay >/dev/null
            pkill ffplay
            or return 1
        end
        function reformat
            jq -r '
                .channels[] |
                [
                    "\u001b[36m" + .id + "\u001b[0m",
                    "\u001b[1m" + .title + "\u001b[0m",
                    "\u001b[33m" + .genre + "\u001b[0m",
                    .listeners,
                    (.playlists[] | select((.format == "aac" or .format == "aacp") and .quality == "low") | .url),
                    .description
                ] |
                @tsv
            '
        end
        function choose
            fzf \
                --reverse \
                --delimiter '\t' \
                --ansi \
                --tabstop=23 \
                --with-nth '2,1,3' \
                --preview 'echo {2} "  " "("{1}")"; echo Genre: {3}; echo; echo {6}; echo; echo {5}; echo Currently {4} listeners.' \
                --bind "enter:execute(
                    set -f url (curl -sf4 '{5}' | grep -im1 '^file1=' | cut -d '=' -f2-);
                    ffplay -volume 100 -vn -nodisp -hide_banner -nostats -loglevel fatal -infbuf -i \$url >/dev/null 2>&1 <&1 & disown;
                )+accept"
        end
        curl -sf4 https://somafm.com/channels.json | reformat | choose
        printf \\n
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
