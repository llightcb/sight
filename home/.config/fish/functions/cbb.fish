function cbb
    argparse -N 1 -- $argv
    or return

    if set -q argv[1]
        ls -l -h (which $argv)
    end
end
