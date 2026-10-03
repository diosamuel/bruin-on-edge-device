#!/bin/bash

output_file="project/system_metrics/metrics.csv"

root_src=$(findmnt -no SOURCE /)
disk=$(lsblk -no PKNAME "$root_src" 2>/dev/null)
disk=${disk:-$(basename "$root_src")}

cores=$(nproc)

header="ts"
for ((i = 0; i < cores; i++)); do
    for key in user nice system idle iowait irq softirq steal; do
        header+=",cpu${i}.${key}"
    done
done
header+=",disk.reads_completed,disk.reads_merged,disk.sectors_read,disk.time_reading"
header+=",mem.mem_total,mem.mem_avail,mem.swap_total,mem.swap_free"
echo "$header" > "$output_file"

while true; do
    ts=$(date '+%Y-%m-%d %H:%M:%S')

    cpu_vals=$(awk '
    /^cpu[0-9]+ / {
        for (i = 2; i <= 9; i++)
            s = s (s == "" ? "" : ",") $i
    }
    END { print s }
    ' /proc/stat)

    disk_vals=$(awk -v disk="$disk" '
    $3 == disk { print $4 "," $5 "," $6 "," $7 }
    ' /proc/diskstats)

    mem_vals=$(awk '
    /MemTotal:/ { mem_total = $2 }
    /MemAvailable:/ { mem_avail = $2 }
    /SwapTotal:/ { swap_total = $2 }
    /SwapFree:/ { swap_free = $2 }
    END { print mem_total "," mem_avail "," swap_total "," swap_free }
    ' /proc/meminfo)

    echo "$ts,$cpu_vals,$disk_vals,$mem_vals" >> "$output_file"

    sleep 1
done
