function esa -d 'basic'
    if test -z (pgrep -f ssh-agent)
        eval (ssh-agent -c) >/dev/null
        ssh-add
        trap "
        kill $SSH_AGENT_PID
        " EXIT
    end
end
