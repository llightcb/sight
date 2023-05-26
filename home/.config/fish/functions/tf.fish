function tf
    # a basic example for: 0x0.st
    argparse -X1 'u' 'd' -- $argv
    or return

    if set -q _flag_d
        read -l -a -P '
        ⏎ space between
        token url: ' qq

        if not set -q qq[2]
            return 1
        end

        curl -Ftoken=$qq[1] -Fdelete= $qq[2]
        return 0
    end

    if set -q _flag_u
        read -l -P '
        expire in (h):
        → ' exp

        printf \\n

        if set -q argv[1]
            if test -f "$argv[1]"
                curl -4siF 'file=@-' \
                -Fexpires=$exp https://0x0.st < $argv[1] \
                | grep -E 'date|x-expires|x-token|0x0\.st'
                yes '' | sed 2q
                return 0
            else
                return 1
            end
        else
            read -lP 'cmd: ' cmdoutput
            command $cmdoutput | curl -4siF 'file=@-' \
            -Fexpires=$exp https://0x0.st </dev/stdin \
            | grep -E 'date|x-expires|x-token|0x0\.st'
            yes '' | sed 2q
            return 0
        end
    else
        echo '
        pb-service: https://0x0.st

        usage ↓

        $ tf -u <file_to_transfer>
        $ tf -u # .. enter command
        $ tf -d # ..   delete file


                    ↓ the recipient ↓

        redirect c.s. to STDOUT: $ curl -fsSL <URL>
        redirect c.s. to STDOUT: $ wget -qO - <URL>
        download: $ curl <URL> -o output.file.name
        download: $ wget -O output.file.name  <URl>
        download: $ wget <URL>     $ curl -LO <URL>
        ' | cut -c9-
        return 1
    end
end
