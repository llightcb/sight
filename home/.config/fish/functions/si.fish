function si --description streamit
    argparse -X0 -- $argv
    or return

    set -l nbco \
        $HOME/.newsboat/config

    if not grep -q 'mpv' $nbco
        read -l -P '
        configure newsboat in order
        to stream audio/video (y/n)
        → ' mkchoice
        if not test "$mkchoice" = y
            return 0
        end
        echo "
        # macro 1
        macro p set browser \"foot mpv --profile=streamit \
        -- %u &\" ; one ; set browser w3m

        # macro 2
        macro y set browser \"nohup mpv --profile=streamit \
        --ytdl-format='bestvideo[height<=?720][fps<=?30][vcodec^=vp09]+bestaudio/best' \
        -- %u </dev/null >/dev/null 2>&1 &\" ; open-in-browser ; set browser w3m" \
        | cut -c9- | sed '3,6s/\([[:blank:]]\{4,\}\)/ /g' | tee -a $nbco >/dev/null
        # w3m = dummy; open links in your browser using foot: ctrl+shift+u → jlabel
        echo '
        usage → type: , + p | , + y

        rss - feed example: https://www.youtube.com/feeds/videos.xml?channel_id=<ch-id>'
        return 0
    else
        echo "
        macros already set"
        return 1
    end
end
