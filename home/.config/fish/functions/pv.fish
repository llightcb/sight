function pv
    if set -q argv[1]
        return 1
    end

    apk -eq info pipe-viewer
    or begin
        echo "@edge/testing"
        return 1
    end

    pipe-viewer --order=upload_date --ignore-av1 --prefer-m4a --prefer-mp4 \
    --player=mpv --append-arg="--profile=streamit --no-ytdl" --resolution=720p
end
