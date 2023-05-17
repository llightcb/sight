function fwn
    set -l op sf l1 l2 l3 l4 sp st h

    argparse -X0 $op -- $argv
    or return

    if set -q _flag_sf
        while true
            read -l -P 'setup a stateful firewall? (y/n) : ' yourchoice
            switch $yourchoice
                case y
                    umask 022

                    set -l cdn /etc/conf.d/nftables

                    if not grep -q '^rules_file=.*nftables\.d.*statel' $cdn
                        echo 'rules_file="/etc/nftables.d/stateless.nft"' \
                        | doas tee -a $cdn >/dev/null
                    end

                    echo "\
                    #!/usr/sbin/nft -f

                    flush ruleset

                    table inet filter {
                            chain input {
                                    type filter hook input priority filter; policy drop;
                                    ct state established,related accept
                                    iif lo accept
                                    ct state invalid drop
                                    meta l4proto { ipv6-icmp, icmp } accept
                                    ip protocol igmp accept
                                    meta l4proto udp ct state new jump udp_chain
                                    meta l4proto tcp tcp flags & (fin|syn|rst|ack) \
                                    == syn ct state new jump tcp_chain
                                    meta l4proto udp reject
                                    meta l4proto tcp reject with tcp reset
                                    counter reject with icmpx type port-unreachable
                            }

                            chain forward {
                                    type filter hook forward priority filter; policy drop;
                            }

                            chain output {
                                    type filter hook output priority filter; policy accept;
                            }

                            chain tcp_chain {
                                    tcp dport 53 accept
                            }

                            chain udp_chain {
                                    udp dport 53 accept
                            }
                    }

                    include \"/var/lib/nftables/*.nft\"" | cut -c 21- \
                        | sed '14s/[[:blank:]]\{16,\}/ /2' \
                    | doas tee /etc/nftables.d/stateless.nft >/dev/null

                    doas rc-service -s nftables restart; doas rc-service -N nftables start

                    printf \\n

                    set_color red

                    doas nft list ruleset

                    read -lP '
                    check validity? (y/n)
                    → ' cck

                    if test "$cck" = y
                        doas nft -c -f /etc/nftables.d/stateless.nft
                    end

                    umask 077

                    return 0
                case n
                    return 0
                case '*'
                    echo "please answer with y[es], or [n]o to exit"
            end
        end
    end

    if set -q _flag_l1
        doas nft list ruleset
        return 0
    end

    if set -q _flag_l2
        doas nft -a list ruleset
        return 0
    end

    if set -q _flag_l3
        doas nft -n list ruleset
        return 0
    end

    if set -q _flag_l4
        doas nft -na list ruleset
        return 0
    end

    if set -q _flag_sp
        doas rc-service -s nftables stop
        return 0
    end

    if set -q _flag_st
        doas rc-service -N nftables start
        return 0
    end

    if set -q _flag_h
        echo '
        fwn ( nftables setup/shortcut )

        $ fwn --sf  = setup stateful fw
        $ fwn --l1   = nft list ruleset
        $ fwn --l2    = nft -a   — „ —
        $ fwn --l3    = nft -n   — „ —
        $ fwn --l4    = nft -na  — „ —
        $ fwn --sp    = stop  nftables
        $ fwn --st    = start nftables
        ' | cut -c9-
        return 0
    end

    return 1
end
