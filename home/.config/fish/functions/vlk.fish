function vlk --description 'vlock-screen'
    argparse -X 0 -- $argv
    or return

    set -l cr (cat /sys/devices/virt*/tty/tty0/active)

    if test "$cr" = tty1
        doas openvt -s -- doas -u (whoami) $SHELL -c \
        'printf "\033[9;1]"
        vlock -a; chvt 1; doas deallocvt'
        echo "welcome back"
    else
        return 1
    end
end
