function mpvl
    argparse -N 1 -- $argv
    or return

    mpv --profile=local-video $argv >/dev/null 2>&1 <&1 & disown
    and exit
end
