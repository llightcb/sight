function lm
    argparse -X0 -- $argv
    or return

    if test -z "$OPENAI_API_KEY"
        read -l -P 'do you have an an OpenAI API key? (n/y) ' nkey
        switch $nkey
            case n
                echo 'website: https://platform.openai.com/signup'
                return 0
            case y
                read -slP 'enter key: ' ykey
                set -Ux OPENAI_API_KEY $ykey
            case '*'
                return 1
        end
    end

    set -l pyv ~/ShellGPT

    if not test -d "$pyv"
        mkdir -p $pyv
    end

    if not test -d "$pyv"/shellgpt_cli
        python3 -m venv $pyv/shellgpt_cli
        source $pyv/shellgpt_cli/bin/activate.fish
        if ! grep -q 'shell-gpt' (pip list | psub)
            pip install shell-gpt; and sgpt --help
        end
    else
        source $pyv/shellgpt_cli/bin/activate.fish
        set -l pk shell-gpt
        set -l iv (pip show $pk | grep '^Version' | cut -d ' ' -f 2)
        set -l lv \
        (curl -s -L --compressed -4 https://pypi.org/pypi/$pk/json \
        | jq '.releases | to_entries | sort_by(.value[].upload_time)
        | .[-1].key' | tr -d '"')
        if test "$iv" != "$lv"
            read -l -P "upgrade $pk-$iv to $pk-$lv ? (y/n) " mchoice
            switch $mchoice
                case y
                    printf \\n; pip install --upgrade $pk; pip check
                case n
                    return 0
                case '*'
                    return 1
            end
        end
    end

    # useful: pipdeptree
end
