function info
    set -l \
        fl v y z t p d s q k l c u b w r m h/help

    argparse -X 0 $fl -- $argv
    or return

    if set -q _flag_v
        set -l vuln \
        /sys/devices/system/cpu/vulnerabilities/*

        paste -d' ' \
        (printf %s\\n (basename -a $vuln) \
        | psub) (grep -h '' $vuln | psub)
        return 0
    end

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

    if set -q _flag_q
        set -l pids (ps -o pid,args \
        | grep '\\[' | grep -v grep \
        | awk '{print $1}')

        for i in $pids
            set -l sha_sum (sha1sum \
            /proc/$i/exe 2>/dev/null)
            if test -n "$sha_sum"
                echo "\
                suspicious PID: $i" \
                | cut -c17-
            end
        end
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

    if set -q _flag_u
        set -l pco (grep '^cpu cores' \
        /proc/cpuinfo | rev \
        | sort -u -b | cut -d ':' -f 1)

        command ls -A \
        | xargs -rn1 -P(math $pco - 1) -I{} \
        du -s -h {} 2>/dev/null | sort -h -r
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
        hidden [p]arent pid d[u] size d/f .
        [v]ulnerability status mas[q]uerade

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
        $ info -u
        $ info -v
        $ info -q
        ' | cut -c 9-
    end
end
