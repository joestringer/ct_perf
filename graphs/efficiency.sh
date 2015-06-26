#!/bin/bash
#
# Author: Joe Stringer <joestringer@nicira.com>
#
# Generate the gnuplot script to turn the processed data into graphs.

TYPE=_x # Alternatives: x - CPU %; c - kilocycles
YLABEL="Connections per CPU %"
FILETYPE=csv

if [ $# -gt 0 ]; then
    if [ x$1 = "x_c" ]; then
        TYPE="_c"
        YLABEL="Connections per megacycle"
    elif [ x$1 = "x_p" ]; then
        TYPE="_p"
        FILETYPE=txt
        echo
    elif [ x$1 != "x_x" ]; then
        echo "usage $0 {_x | _c }"
        exit 1
    fi
fi
OUTFILE=crr${TYPE}.gnu

cat << EOF > ${OUTFILE}.gnu
# Basic parameters
set title 'CPU efficiency against packet size'
set ylabel '${YLABEL}'
set xlabel 'payload length (B)'
set term pngcairo size 1600,900 font 'Verdana,18'
set key outside

# Better colours
set style line 1 linecolor rgb "#a6cee3" pt 1 ps 1 lt 1 lw 2 # --- light blue
set style line 2 linecolor rgb "#1f78b4" pt 2 ps 1 lt 1 lw 2 # --- dark blue
set style line 3 linecolor rgb "#b2df8a" pt 3 ps 1 lt 1 lw 2 # --- light green
set style line 4 linecolor rgb "#33a02c" pt 4 ps 1 lt 1 lw 2 # --- dark green
set style line 5 linecolor rgb "#fb9a99" pt 5 ps 1 lt 1 lw 2 # --- light red
set style line 6 linecolor rgb "#e31a1c" pt 6 ps 1 lt 1 lw 2 # --- dark red
set style line 7 linecolor rgb "#fdbf6f" pt 7 ps 1 lt 1 lw 2 # --- light orange
set style line 8 linecolor rgb "#ff7f00" pt 8 ps 1 lt 1 lw 2 # --- dark orange

# Grey
set style line 9 linecolor rgb "#636363" pt 1 ps 1 lt 1 lw 2

# Blues
set style line 10 linecolor rgb "#6baed6" pt 2 ps 1 lt 1 lw 2
set style line 11 linecolor rgb "#3182bd" pt 3 ps 1 lt 1 lw 2
set style line 12 linecolor rgb "#08519c" pt 4 ps 1 lt 1 lw 2

# Greens
set style line 13 linecolor rgb "#74c476" pt 5 ps 1 lt 1 lw 2
set style line 14 linecolor rgb "#31a354" pt 6 ps 1 lt 1 lw 2
set style line 15 linecolor rgb "#006d2c" pt 7 ps 1 lt 1 lw 2

# Oranges
set style line 16 linecolor rgb "#fd8d3c" pt 8 ps 1 lt 1 lw 2
set style line 17 linecolor rgb "#e6550d" pt 9 ps 1 lt 1 lw 2
set style line 18 linecolor rgb "#a63603" pt 10 ps 1 lt 1 lw 2

# Purples
set style line 19 linecolor rgb "#9e9ac8" pt 11 ps 1 lt 1 lw 2
set style line 20 linecolor rgb "#756bb1" pt 12 ps 1 lt 1 lw 2
set style line 21 linecolor rgb "#54278f" pt 13 ps 1 lt 1 lw 2

# Prettier borders
set style line 31 lc rgb "#808080" lt 1
set border 11 back ls 31
set tics nomirror

# Shinier grid
set style line 32 lc rgb "#808080" lt 0 lw 1
set grid back ls 32

# Histogram styling
set auto x
set style data histogram
set style histogram cluster gap 1
set style fill solid border -1
set key autotitle columnhead
EOF

for column in `seq 2 5`; do
cat << EOF >> ${OUTFILE}.gnu
set output '${OUTFILE}_${column}.png'
plot 'bridge${TYPE}_CRR.${FILETYPE}' every ::1 u 0:(0):xticlabel(1) w l ls 32 title '', \\
    'bridge${TYPE}_CRR.${FILETYPE}' u $column with linespoints ls 21, \\
     'ovsl2${TYPE}_CRR.${FILETYPE}' u $column with linespoints ls 11, \\
     'ipset${TYPE}_CRR.${FILETYPE}' u $column with linespoints ls 13, \\
     'nfmap${TYPE}_CRR.${FILETYPE}' u $column with linespoints ls 18, \\
     'nfset${TYPE}_CRR.${FILETYPE}' u $column with linespoints ls 16, \\
     'ovsct${TYPE}_CRR.${FILETYPE}' u $column with linespoints ls 10, \\
     'ipt1k${TYPE}_CRR.${FILETYPE}' u $column with linespoints ls 14, \\
     'nft1k${TYPE}_CRR.${FILETYPE}' u $column with linespoints ls 17
EOF
done

gnuplot ${OUTFILE}.gnu
