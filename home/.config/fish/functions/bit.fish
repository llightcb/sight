function bit
    argparse -X 0 -- $argv
    or return

    doas find / -perm /u=s,g=s -type f 2>/dev/null \
    | xargs -I {} stat -c '%A %n' {}
end
