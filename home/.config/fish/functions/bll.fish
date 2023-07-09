function bll
    argparse -X0 'r' 'g' 'h/help' -- $argv
    or return

    set -l tm /etc/dnscrypt-proxy/dnscrypt-proxy.toml

    if set -q _flag_r
        grep -q '^blocked_ips_file =' $tm
        or begin
            printf \\n
            read -l -P '+ rebinding protection? (y/n) ' d_rbp
            if test "$d_rbp" = y
                set -l bp blocked-ips.txt
                doas sed -i "s|.*\(blocked_ips_file =\).*|\1 '$bp'|" $tm
                grep '' /etc/dnscrypt-proxy/blocked-ips.txt | less -necJ
                printf \\n
                read -lP 'restart dnscrypt-proxy? (y/n) ' res
                if test "$res" = y
                    doas rc-service -q dnscrypt-proxy restart
                    yes '' | sed 1q; read -lP 'execute test? (y/n) ' tst
                    if test "$tst" = y
                        yes '' | sed 1q; drill -Q4 net127.rebindtest.com
                    end
                end
                return 0
            end
            return 0
        end
        printf "\ndone already \u2193\n\n"
        grep '^blocked_ips_file.*txt' $tm
        return 1
    end

    if set -q _flag_g
        if not test -d ~/Temp
            mkdir ~/Temp
        end
        builtin cd ~/Temp
        or return 1
        set -l ftxt domains-allowlist.txt domains-time-restricted.txt
        set -l ftxt $ftxt domains-blocklist-local-additions.txt
        set -l fu generate-domains-blocklist.py domains-blocklist.conf
        for i in $ftxt
            if not test -e "$i"
                touch $ftxt
            end
        end
        if not test -e "$fu[1]" -a -e "$fu[2]"
            printf \\n
            read -l -P 'download script & config? (y/n)? ' dold
            printf \\n
            if test "$dold" = y
                set -l sho dnscrypt-proxy
                set -l url https://raw.githubusercontent.com/DNSCrypt/$sho
                wget -c $url/master/utils/generate-domains-blocklist/$fu[1]
                wget -c $url/master/utils/generate-domains-blocklist/$fu[2]
                if not test -x "$fu[1]"
                    chmod +x $fu[1]
                end
            else
                return 1
            end
        end
        if not grep -q '^blocked_names_file =' $tm
            printf \\n
            set -l nm blocklist.txt
            doas sed -i "s|.*\(blocked_names_file =\).*|\1 '$nm'|" $tm
        end
        while true
            printf \\n%s\\n edit: $ftxt $fu[2] "
            [a]llow / [r]estricted / [l]ocal / [c]onfig and/or [d]one?
            "
            read -lP 'choice: ' ed
            switch $ed
                case a
                    nvim $ftxt[1]
                case r
                    nvim $ftxt[2]
                case l
                    test -s "$ftxt[3]"
                    or printf %s\\n \*.reddit.com \*.googleusercontent.com \
                    | tee $ftxt[3] >/dev/null; nvim $ftxt[3] # opin. example
                case c
                    nvim $fu[2]
                case d
                    break
            end
        end
        printf \\n
        umask 022
        doas ./generate-domains-blocklist.py -c $fu[2] -o lst.tmp
        and begin
            doas mv -f lst.tmp /etc/dnscrypt-proxy/blocklist.txt
            printf \\n
            read -l -P 'take a look @ blocklist.txt? (y/n) ' chc
            if test "$chc" = y
                cat /etc/dnscrypt-proxy/blocklist.txt | less -mni
            end
            doas rc-service -s -q dnscrypt-proxy restart
            set -l dcb /etc/dnscrypt-proxy/blocklist.txt
            set -l cont (grep -vxEc '[ ]*([#].*)?' $dcb)
            echo -e '\nfile size' (du -h $dcb | cut -f1)
            echo -- "$cont entries"; umask 077; return 0
        end
        set -l fr (find $tm -mmin -1)
        if test -n "$fr"
            doas rc-service -s -q dnscrypt-proxy restart
        end
        printf \\n
        if test -e lst.tmp
            rm -iv lst.tmp
        end
        umask 077
        return 1
    end

    if set -q _flag_h
        echo '
        ( blocklist )

        dns-[r]ebinding-protection | [g]enerate blocklist

        $ bll -r
        $ bll -g
        ' | cut -c 9-
        return 0
    end

    return 1
end
