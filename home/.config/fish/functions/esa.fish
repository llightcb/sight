function esa --description 'basic ssh'
    argparse -X 0 -- $argv
    or return

    if test -z "$SSH_AGENT_PID"
        if ! pgrep ssh-agent >/dev/null
            read -l -P \
            'lifetime in minutes: ' cho
            test -n "$cho"; or return 1
            function nf --on-signal INT
                echo "esa: cleaned up!"
                wtype -k return # lazy?
            end
            set -l mn (math $cho \* 60)
            eval $(ssh-agent -t $mn -c)
            ssh-add; trap '
            set -e SSH_AUTH_SOCK
            kill $SSH_AGENT_PID
            set -e SSH_AGENT_PID
            trap - INT TERM EXIT
            functions -e nf
            ' INT TERM EXIT
            return 0 # builtin trap = ↓
        else
            echo "
            → another session is active
            "; return 1
        end
    else
        set --show \
            SSH_AUTH_SOCK SSH_AGENT_PID
        return 0
    end
end
