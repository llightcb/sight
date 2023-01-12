function rcl
    if not set -q argv[1]
        set -l dir /etc/rc.conf
        if grep -i -q '^#rc_logger=' -- $dir
            read -l -P 'enable rc-logger? (y/n) ' cho
            if test "$cho" = y
                rc-service devfs status >/dev/null
                or doas rc-update add devfs sysinit
                doas sed -i '
                s/^#rc_logger=.*/rc_logger="YES"/' $dir
                printf \\n
                sed -n '/^rc_logger=/p' $dir
                printf \\n
            end
        else
            read -l -P 'disable rc-logger? (y/n) ' chc
            if test "$chc" = y
                doas sed -i 's/^rc_logger=/#&/' $dir
                printf \\n
                sed -n '/^#rc_logger=/p' $dir
                printf \\n
            end
        end
        return 0
    end

    set -l options v d h/help

    argparse -X0 $options -- $argv
    or return

    if set -q _flag_v
        if test -e /var/log/rc.log
            cat /var/log/rc.log | less -mnSwi
        else
            echo "file not found"
        end
        return 0
    end

    if set -q _flag_d
        if test -e /var/log/rc.log
            doas /bin/rm -i -- /var/log/rc.log
        else
            echo "file not found"
        end
        return 0
    end

    if set -q _flag_h
        echo '
        enable / disable openrc logging daemon
        rcl ( + [v]iew rc.log [d]elete rc.log )

        $ rcl
        $ rcl -v
        $ rcl -d
        ' | cut -c9-
    end
end
