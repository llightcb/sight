function trim
    argparse -X0 -- $argv
    or return

    doas fstrim -v /
end
