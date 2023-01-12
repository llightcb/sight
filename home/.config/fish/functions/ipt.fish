function ipt
    set -l opts sf 4 s4 sp st h

    set -l ipt /etc/iptables/

    argparse -X0 $opts -- $argv
    or return

    if set -q _flag_sf
        while true
            read -l -P 'setup a stateful firewall? (y/n) ' ch
            switch $ch
                case y
                    doas iptables -F
                    doas iptables -X
                    doas iptables -Z
                    doas iptables -P INPUT DROP
                    doas iptables -P FORWARD DROP
                    doas iptables -P OUTPUT ACCEPT
                    doas iptables -N TCP
                    doas iptables -N UDP
                    doas iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
                    doas iptables -A INPUT -i lo -j ACCEPT
                    doas iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
                    doas iptables -A INPUT -p icmp --icmp-type 8 -m conntrack --ctstate NEW -j ACCEPT
                    doas iptables -A INPUT -p udp -m conntrack --ctstate NEW -j UDP
                    doas iptables -A INPUT -p tcp -m tcp --syn -m conntrack --ctstate NEW -j TCP
                    doas iptables -A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable
                    doas iptables -A INPUT -p tcp -j REJECT --reject-with tcp-reset
                    doas iptables -A INPUT -j REJECT --reject-with icmp-proto-unreachable

                    doas rc-service iptables save; doas rc-update -q add iptables default
                    doas rc-service -s iptables restart; doas rc-service -N iptables start
                    return 0
                case n
                    return 0
                case '*'
                    echo "please answer with y (or n to exit)"
            end
        end
    end

    if set -q _flag_4
        less -m -n -S -w -e -i \
        (doas iptables -nvL | psub)
        return 0
    end

    if set -q _flag_s4
        doas iptables -S
        return 0
    end

    if set -q _flag_sp
        doas rc-service -s iptables stop
        return 0
    end

    if set -q _flag_st
        doas rc-service -N iptables start
        return 0
    end

    if set -q _flag_h
        echo '
        ipt ( iptables shortcuts )

        $ ipt --sf  = setup stateful
        $ ipt -4    = iptables -nvL
        $ ipt --s4  = iptables -S
        $ ipt --sp  = stop iptables
        $ ipt --st  = start iptables
        ' | cut -c9-
    end
end
