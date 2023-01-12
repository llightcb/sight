function qv
    if test (count $argv) -eq 1
        if set -q $argv
            echo -- "$argv $$argv"
        else
            echo -- "$argv not set"
        end
    end
end
