#!/bin/bash

# For each *.txt file in $SRC that start with $PREFIX, grep for "System"
# string and retrieve the CPU % from those files. Output in a better format.
#
# Expected input file has lines that match the following regex:
# System.*avg\. XYZ.AB%
#
# Results should be ordered by cores, then by packet size, ie:
# <result for 1 core, 64B>
# <result for 1 core, 128B>
# ...
#
# Outputs to a file in the format, with a title as the first line:
# CRR, TCP, CORENUM, PKT_SIZE, RESULT
#
# Output file has PREFIX and SUFFIX stripped from the filename.

AVG="graphs/avg.py -c 0"
CORES="1 4 8 16"
PKTS="64 128 512 1024 9000 64000"

# Drop these pieces from the output file name.
PREFIX="3node_e2e_"
SUFFIX="_CRR"

OUT_SUFFIX=_p

SRC=raw/

for result in `ls -1 ${SRC}/*_1.txt | sed 's/_1.txt//'`; do
    RESNAME=`basename ${result}`
    DSTNAME=`echo $RESNAME | sed -e "s/${PREFIX}//" -e "s/${SUFFIX}//" -e "s/.csv//"`${OUT_SUFFIX}
    for test_run in `ls *${result}*.txt`; do
        TESTNAME=`basename ${test_run}`
        echo "result" > $TESTNAME
        grep "System" $test_run | sed -e 's/^.*avg\. //' -e 's/%//' >> $TESTNAME
    done
    $AVG `ls ${RESNAME}*.txt` > ${RESNAME}.txt
    rm `ls ${RESNAME}_*.txt`

    echo "type, proto, cores, packet size" > ${DSTNAME}.txt
    for cores in $CORES; do
        for pkts in $PKTS; do
            echo "CRR, TCP, $cores, $pkts" >> ${DSTNAME}.txt
        done
    done
    paste -d ", " ${DSTNAME}.txt ${RESNAME}.txt > ${DSTNAME}.tmp
    mv ${DSTNAME}.tmp ${DSTNAME}.txt
    rm ${RESNAME}.txt
done
