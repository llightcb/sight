function si
    # just a basic example
    argparse -X 0 -- $argv
    or return

    read -f -P '
    search for:

    playlist (p)
    subfile  (s)
    channel  (c)
    video    (v)
    all      (a)

    → ' choice

    switch $choice
        case s
            if not test -e \
            ~/.config/ytfzf/subscriptions
                return 1
            end
        case p
            set -f sepy playlist
        case c
            set -f sepy channel
        case v
            set -f sepy video
        case a
            set -f sepy all
        case '*'
            return 1
    end

    set -f opt \
    --type="$sepy" \
    --search-again \
    --loop \
    --url-handler-opts=--profile=streamit \
    --ytdl-pref='bestvideo[height<=?720][fps<=?30][vcodec=vp9]+bestaudio/best' \
    --skip-thumb-download \
    --sort-by=relevance \
    --sort-by=upload_date

    if string match --quiet --regex -- 'c|p' $choice
        ytfzf $opt[1..3] --submenu-opts="$opt[4..7]"
        return 0
    else if test "$choice" = s
        set -e opt[7] # u_date
        # invidious only: -cSI
        ytfzf -cS $opt[3..7]
        return 0
    else
        ytfzf $opt[1..7]
        return 0
    end
end
