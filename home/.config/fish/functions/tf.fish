function tf --description basic
    argparse -X 1 'u' -- $argv
    or return

    if set -q _flag_u
        if test -f "$argv[1]"
            seq 2 | tr -d -c \\n
            read -lP 'max downloads: ' md
            read -l -P 'max days: ' dm;
            printf \\n
            curl -4siF "file=@$argv[1]" \
            https://transfer.sh \
            -H "Max-Downloads: $md" \
            -H "Max-Days: $dm" \
            | grep -Ei \
            'transfer\.sh|x-url-delete' \
            | sort; yes '' | sed 2q
        else
            return 1
        end
    else
        echo '
        correct usage: $ tf -u <file_to_transfer>

        delete: $ curl -X DELETE <x-url-delete URL>

                    ↓ the recipient ↓

        redirect c.s. to STDOUT: $ curl -fsSL <URL>
        redirect c.s. to STDOUT: $ wget -qO - <URL>
        download: $ curl <URL> -o output.file.name
        download: $ wget -O output.file.name  <URl>
        download: $ wget <URL>     $ curl -LO <URL>

        https://github.com/dutchcoders/transfer.sh
        ' | cut -c9-
        return 1
    end
end
