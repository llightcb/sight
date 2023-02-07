function pv
    argparse -X 0 -- $argv
    or return

    pipe-viewer --order=relevance --ignore-av1 --prefer-m4a --prefer-mp4 \
    --player=mpv --append-arg="--profile=streamit --no-ytdl" --resolution=720p
end
