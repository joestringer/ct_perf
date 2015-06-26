#!/bin/bash
#
# Author: Joe Stringer <joestringer@nicira.com>
#
# Generate the gnuplot script to turn the processed data into graphs.

TYPE=""
OUTFILE=crr
STATS=""
COLOURS=""
GREY=0
CPU=0

usage()
{
    echo "usage: $0 [FLAGS] [TYPE] [POSTFIX]"
    echo
    echo "Generate graphs from the data."
    echo
    echo "Positional arguments:"
    echo "  FLAGS\t[ccgblms]; See description below"
    echo "  TYPE\tInfix for input filenames, ie bridge{TYPE}_CRR.*"
    echo "  POSTFIX\tAppend this to output name, ie crr{TYPE}_{POSTFIX}_N.png"
    echo
    echo "FLAGS:"
    echo -e "  b\tOutput baseline bridge results"
    echo -e "  l\tOutput linear results"
    echo -e "  i\tOutput iptables result as baseline"
    echo -e "  m\tOutput map-based results"
    echo -e "  s\tOutput simple (non-ct) results"
    echo -e "  1\tOutput bridge result as baseline"
    echo -e "  c\tAdd CPU cycles to the graph (second axis)"
    echo -e "  p\tAdd CPU percentage to the graph (second axis)"
    echo -e "  g\tRender simple in grey"
    echo -e "  h\tThis help/usage message"
    echo
    echo "No arguments is equivalent to \"$0 clms\""
    exit 1
}

parse_arg1()
{
    echo $1 | grep -q 'g'
    if [ $? -eq 0 ]; then
        GREY=1
    fi
    echo $1 | grep -q '1'
    if [ $? -eq 0 ]; then
        STATS="$STATS bridge"
        COLOURS="$COLOURS 22"
    fi
    echo $1 | grep -q 'b'
    if [ $? -eq 0 ]; then
        STATS="$STATS bridge"
        COLOURS="$COLOURS 23"
    fi
    echo $1 | grep -q 's'
    if [ $? -eq 0 ]; then
        STATS="$STATS bridge ovsl2"
        if [ $GREY -eq 0 ]; then
            COLOURS="$COLOURS 21 11"
        else
            COLOURS="$COLOURS 22 23"
        fi
    fi
    echo $1 | grep -q 'm'
    if [ $? -eq 0 ]; then
        STATS="$STATS ipset nfset nfmap ovsct"
        COLOURS="$COLOURS 13 18 16 10"
    fi
    echo $1 | grep -q 'i'
    if [ $? -eq 0 ]; then
        STATS="$STATS nft1k"
        COLOURS="$COLOURS 23"
    fi
    echo $1 | grep -q 'l'
    if [ $? -eq 0 ]; then
        STATS="$STATS ipt1k nft1k"
        if [ $GREY -eq 0 ]; then
            COLOURS="$COLOURS 14 17"
        else
            COLOURS="$COLOURS 22 23"
        fi
    fi
    echo $1 | grep -q 'p'
    if [ $? -eq 0 ]; then
        CPU=1
        TYPE="_p"
    fi
    echo $1 | grep -q 'c'
    if [ $? -eq 0 ]; then
        CPU=2
        TYPE="_c"
    fi
}

main()
{
    if [ $# -gt 0 ]; then
        echo $1 | grep -q 'h'
        if [ $? -eq 0 ]; then
            usage $@
        fi
        parse_arg1 $1

        if [ $# -gt 1 ]; then
            TYPE="_$2"
            OUTFILE="${OUTFILE}_${2}"
        fi
        if [ $# -gt 2 ]; then
            OUTFILE="${OUTFILE}_${3}"
        fi
    else
        CPU=0
        STATS=" bridge ovsl2 ipset nfset nfmap ovsct ipt1k nft1k"
        COLOURS=" 21 11 13 18 16 10 14 17"
    fi

    cat << EOF > ${OUTFILE}.gnu
# Basic parameters
set title 'TCP CRR performance against packet size'
set ylabel 'Connection/s'
set yrange [0:60000]
set xlabel 'payload length (B)'
set term pngcairo size 1600,900 font 'Verdana,18'
set key outside
EOF

    if [ $CPU -eq 1 ]; then
        cat << EOF >> ${OUTFILE}.gnu
set y2label 'CPU %'
set y2range [0:1600]
set y2tics 100
EOF
    elif [ $CPU -eq 2 ]; then
        cat << EOF >> ${OUTFILE}.gnu
set y2label 'CPU cycles'
set y2tics 1000000000
#set y2tics 1000000
EOF
    fi

    cat << EOF >> ${OUTFILE}.gnu
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

# Greys
set style line 22 linecolor rgb "#636363" pt 1 ps 1 lt 1 lw 2
set style line 23 linecolor rgb "#a9a9a9" pt 1 ps 1 lt 1 lw 2

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
plot 'bridge_CRR.csv' every ::1 u 0:(0):xticlabel(1) w l ls 32 title '', \\
EOF
        FILECOUNT=`echo $STATS | wc -w`
        if [ $CPU -ne 0 ]; then
            for i in `seq 1 $FILECOUNT`; do
                F=`echo $STATS | cut -d' ' -f $i`
                C=`echo $COLOURS | cut -d' ' -f $i`
                cat << EOF >> ${OUTFILE}.gnu
    '${F}${TYPE}_CRR.txt' u $column ls $C axes x1y2, \\
EOF
            done
        fi
        for i in `seq 1 $FILECOUNT`; do
            F=`echo $STATS | cut -d' ' -f $i`
            C=`echo $COLOURS | cut -d' ' -f $i`
            if [ $i -eq $FILECOUNT ]; then
                cat << EOF >> ${OUTFILE}.gnu
    '${F}_CRR.csv' u $column with linespoints ls ${C}
EOF
            else
                cat << EOF >> ${OUTFILE}.gnu
    '${F}_CRR.csv' u $column with linespoints ls ${C}, \\
EOF
            fi
        done
    done

    gnuplot ${OUTFILE}.gnu
}

main $@
