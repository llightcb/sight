function 2fa
    argparse -N 1 -- $argv
    or return

    oathtool -b --totp "$argv"
end
