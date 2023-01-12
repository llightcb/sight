function tf
    if set -q argv[1]
        set -l tmpfile (mktemp -t transferXXXXXX)
        curl --progress-bar --upload-file "$argv[1]" https://transfer.sh/(basename $argv[1]) -H "Max-Downloads: 1" >>$tmpfile
        cat $tmpfile; command rm -f $tmpfile
    else
        echo 'usage: $ tf FILE_TO_TRANSFER'
    end
end
