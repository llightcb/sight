function esa -d 'basic'
    argparse -X 0 -- $argv
    or return

    if test -z (pgrep -f ssh-agent)
        eval (ssh-agent -c) >/dev/null
        ssh-add
        trap "
        kill $SSH_AGENT_PID
        " EXIT
    end
end
