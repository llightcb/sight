function tf
    # delete: $ curl -X DELETE <x-url-delete URL>

    if set -q argv[1]
        curl -s -D - --upload-file "$argv[1]" \
        https://transfer.sh/(basename $argv[1]) \
        -H "Max-Downloads: 1" \
        | grep -Ei 'transfer\.sh|x-url-delete' \
        | sort
    else
        echo 'usage: $ tf FILE_TO_TRANSFER'
    end
end
