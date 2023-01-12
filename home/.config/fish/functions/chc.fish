function chc
    doas rc-service chronyd status

    if test "$status" -eq 0
        printf \\n
        doas chronyc -N 'sources -a -v'
        printf \\n
        doas chronyc activity
        printf \\n
        doas chronyc -N authdata
        printf \\n
        doas chronyc tracking
        printf \\n
        read -lP '+ ntpdata? (y/n) ' ch
        if test "$ch" = y
            doas chronyc ntpdata
        end
    end
end
