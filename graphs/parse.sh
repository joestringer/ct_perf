#!/bin/sh
#
# Author: Joe Stringer <joestringer@nicira.com>

FMT="csv"
LABEL="cps"
TYPES="STREAM RR CRR"

if [ $# -lt 1 ]; then
    echo "usage: $0 <INPUT> [FORMAT] [LABEL]"
    echo
    echo "Rearranges <input> into <input>_CRR.{FORMAT} in gnuplot-friendly format."
    echo
    echo "Positional arguments:"
    echo "  INPUT\tInput file (Required)"
    echo "  FORMAT\tInput/output file suffix/extension (default: ${FMT})"
    echo "  LABEL\tLabel for graph legend (default: ${LABEL})"
    exit 1
fi

if [ $# -gt 1 ]; then
    FMT=$2
fi

if [ $# -gt 2 ]; then
    LABEL=$3
fi

if [ ! -e "${1}" ]; then
    echo "Can't find file ${1}!"
    exit 1
fi

TMP1=timeouts.tmp
TMP2=connections.tmp

IN=${1}
for TYPE in $TYPES; do
    cat $IN | grep -q "^$TYPE";
    if [ $? -eq 0 ]; then
        TESTNAME=`echo ${1} | sed "s/.${FMT}//"`
        OUT=${TESTNAME}_${TYPE}.${FMT}
        for N_CORES in `cat $IN | sed -e '/cores/d' -e '/%conntrack.*$/d' -e '/^$/d' | cut -d',' -f3 | sort | uniq`; do
            if [ x$N_CORES = "x1" ]; then
                echo "packet_size, ${TESTNAME}_${LABEL}_(${N_CORES}_threads)" > $OUT
                cat $IN | sed '/%conntrack.*$/d' | sed '/^$/d'| grep "^$TYPE" | grep ",.${N_CORES}," | cut -d',' -f4- >> $OUT
            else
                echo " ${TESTNAME}_${LABEL}_(${N_CORES}_threads)" > ${N_CORES}.tmp
                cat $IN | sed '/%conntrack.*$/d' | sed '/^$/d' | grep "^$TYPE" | grep ",.${N_CORES}," | cut -d',' -f5 >> ${N_CORES}.tmp
                paste -d ", " ${OUT} ${N_CORES}.tmp > ${OUT}.tmp
                mv ${OUT}.tmp ${OUT}
            fi
        done
    fi
done
