function vol -d 'set volume and suppress annoying rtkit errors'
    argparse -N1 -- $argv
    or return

    wpctl set-volume @DEFAULT_AUDIO_SINK@ $argv[1] 2>/dev/null
end
