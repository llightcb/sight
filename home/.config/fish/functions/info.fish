function info
    set -l flgs y z t p d s k l c b w r m h/help

    argparse -X 0 $flgs -- $argv
    or return

    if set -q _flag_y
        set -l h_l (stat -c '%h' /sys/module)
        set -l v_e (ls -d /sys/module/* | wc -l)
        set -l h_c (math $h_l - $v_e - 2)

        if test "$h_c" -gt 0
            echo "/sys/modules has $h_c entries"
        end
    end

    if set -q _flag_z
        doas grep -R . /sys/kernel/debug/zswap/
    end

    if set -q _flag_t
        sh -c 'ta=$(cat /proc/sys/kern*/tainted)

        if test "$ta" = 0; then
            exit
        else
            echo "https://docs.kernel.org/admin\
            -guide/tainted-kernels.html
            " | sed \'s/ //g\'

            for i in $(seq 18); do
                echo $((i-1)) $((ta>>(i-1)&1)) \
                | grep -E \'[^ ]+ 1\b\' \
                | cut -d \' \' -f 1
            done
        fi'
    end

    if set -q _flag_p
        for i in /proc/*
            if not test -f "$i"/exe
                continue
            end
            if string match -q -- '*self*' -- $i
                continue
            end
            set -l par \
            (sed -n 's/^PPid:[[:space:]]*//p' \
            "$i/status")
            if test "$par" = 0
                continue
            end
            if not test -e /proc/"$par"/comm
                echo "
                $i has hidden parent pid: $par"
            end
        end
    end

    if set -q _flag_d
        less -mnSwi (doas dmesg | psub)
        return 0
    end

    if set -q _flag_s
        less -mnwi -S /var/log/messages
        return 0
    end

    if set -q _flag_k
        read -lP 'search for: ' sfo
        zcat /proc/config.gz \
        | grep -i $sfo | less -nicJ
        return 0
    end

    if set -q _flag_l
        lsmod | sort \
        | less -mnSwi
        return 0
    end

    if set -q _flag_c
        sysctl -a \
            | less -i
        return 0
    end

    if set -q _flag_b
        doas find / -perm /u=s,g=s -type f \
        2>/dev/null \
        | xargs -I {} stat -c '%A %n' {}
    end

    if set -q _flag_w
        doas find / -xdev -type f -perm -o+w \
        -o -perm -o+w -type d 2>/dev/null
    end

    if set -q _flag_r
        ls -la /proc/*/exe 2>/dev/null \
        | grep -i 'deleted'
    end

    if set -q _flag_m
        modprobe --showconfig \
        | grep -E 'blacklist|/bin/true' \
        | less -mnFwi
        return 0
    end

    if set -q _flag_h
        echo '
        info: [d]mesg [k]ernel conf [l]smod
        [s]yslog sys[c]tl [m]odprobe b-list
        suid/sgid [b]its [w]orld writetable
        [r]eveal deleted/replaced [t]ainted
        hidden s[y]s/module entries [z]swap
        hidden [p]arent pid |     tbc     |

        $ info -d
        $ info -k
        $ info -l
        $ info -s
        $ info -c
        $ info -m
        $ info -b
        $ info -w
        $ info -r
        $ info -t
        $ info -y
        $ info -z
        $ info -p
        $ info -bwrtypz  # "at-once" -flags
        ' | cut -c 9-
    end
end
