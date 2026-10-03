#!/bin/bash

output_file="metrics.csv"
echo 'ts,source,metric,value' > "$output_file"

root_src=$(findmnt -no SOURCE /)
disk=$(lsblk -no PKNAME "$root_src" 2>/dev/null)
disk=${disk:-$(basename "$root_src")}

while true; do
    ts=$(date '+%Y-%m-%d %H:%M:%S')

    awk -v ts="$ts" '
    /^cpu[0-9]+ / {
        split("user nice system idle iowait irq softirq steal", keys, " ")
        for (i = 1; i <= 8; i++)
            print ts ",cpu," $1 "." keys[i] "," $(i + 1)
    }
    ' /proc/stat >> "$output_file"

    awk -v ts="$ts" -v disk="$disk" '
    $3 == disk {
        print ts ",disk," disk ".reads_completed," $4
        print ts ",disk," disk ".reads_merged," $5
        print ts ",disk," disk ".sectors_read," $6
        print ts ",disk," disk ".time_reading," $7
    }
    ' /proc/diskstats >> "$output_file"

    awk -v ts="$ts" '
    /MemTotal:/ { mem_total = $2 }
    /MemAvailable:/ { mem_avail = $2 }
    /SwapTotal:/ { swap_total = $2 }
    /SwapFree:/ { swap_free = $2 }
    END {
        print ts ",mem,mem_total," mem_total
        print ts ",mem,mem_avail," mem_avail
        print ts ",mem,swap_total," swap_total
        print ts ",mem,swap_free," swap_free
    }
    ' /proc/meminfo >> "$output_file"

    sleep 1
done
