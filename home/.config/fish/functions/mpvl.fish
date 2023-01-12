function mpvl
    if not set -q argv[1]
        return 1
    end

    mpv --profile=local-video $argv >/dev/null 2>&1 <&1 & disown
    and exit
end
