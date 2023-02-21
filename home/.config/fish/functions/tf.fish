function tf --description basic
    argparse -X 1 'u' -- $argv
    or return

    if set -q _flag_u
        printf \\n
        read -l -P 'max downloads: ' md
        read -l -P 'max days: ' dm; printf \\n
        curl -s -D - --upload-file "$argv[1]" \
        https://transfer.sh/(basename $argv[1]) \
        -H "Max-Downloads: $md" -H "Max-Days: $dm" \
        | grep -E -i 'transfer\.sh|x-url-delete' \
        | sort; printf \\n
    else
        echo '
        correct usage: $ tf -u <file_to_transfer>

        delete: $ curl -X DELETE <x-url-delete URL>

                    ↓ the recipient ↓

        redirect c.s. to STDOUT: $ curl -fsSL <URL>
        redirect c.s. to STDOUT: $ wget -qO - <URL>
        download: $ curl <URL> -o output.file.name
        download: $ wget -O output.file.name  <URl>
        download: $ curl <URL>
        download: $ wget <URL>

        https://github.com/dutchcoders/transfer.sh
        ' | cut -c9-
        return 1
    end
end
