function cbb
    if set -q argv[1]
        ls -l -h (which $argv)
    end
end
