function cfn
    for f in *
        if string match -r -q '[^\w.-]' -- $f
            set -l fn (string replace -r -a '[^\w.-]' '' -- $f)
            mv -- $f $fn
            echo -- "$fn"
        end
    end
end
