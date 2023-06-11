function si --description streamit
    # close input j.i.c. for nohup
    argparse -X0 -- $argv
    or return

    set -l config \
        $HOME/.newsboat/config

    if not grep -q 'mpv' $config
        read -l -P '
        configure newsboat in order
        to stream yt-channels (y/n)
        → ' mkchoice
        if not test "$mkchoice" = y
            return 0
        end
        echo "
        # macro
        macro y set browser \"nohup mpv --profile=streamit \
        --ytdl-format='bestvideo[height<=?720][fps<=?30][vcodec=vp9]+bestaudio/best' \
        -- %u </dev/null >/dev/null 2>&1 &\" ; open-in-browser ; set browser w3m" \
        | cut -c9- | sed '3s/\([[:blank:]]\{4,\}\)/ /g' | tee -a $config >/dev/null
        # w3m = dummy; open links in your browser using foot: ctrl+shift+u → jlabel
        echo "
        usage → type: , + y

        rss feed example: https://www.youtube.com/feeds/videos.xml?channel_id=xxxx"
        return 0
    else
        echo "
        macro already set!"
        return 1
    end
end
