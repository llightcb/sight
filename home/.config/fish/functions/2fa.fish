function 2fa
    argparse -X 0 -- $argv
    or return

    read -lsP 'enter key: ' ky

    if test -z "$ky"
        return 1
    end

    oathtool -b --totp -- $ky \
    | wl-copy -n

    echo '
    result copied to clipboard!
    '
end
