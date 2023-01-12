function se
    set -l tpa (cat /sys/devices/platform/coretemp.0/hwmon/hwmon*/temp*_input | sed 's/...$/°C/')
    set -l tda (cat /sys/devices/platform/coretemp.0/hwmon/hwmon*/temp*_label)
    set -l tpb (cat /sys/class/thermal/thermal_zone*/temp | sed 's/...$/°C/')
    set -l tdb (cat /sys/class/thermal/thermal_zone*/type)

    paste (printf "%s\n" $tpa | psub) (printf "%s\n" $tda | psub)
    paste (printf "%s\n" $tpb | psub) (printf "%s\n" $tdb | psub)
end
