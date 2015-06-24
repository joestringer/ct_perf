#!/bin/bash

AVG=graphs/avg.py
SRC=raw/

# Drop these pieces from the output file name.
PREFIX="3node_e2e_"
SUFFIX="_CRR"

# For files foo_1, foo_2, foo_3... average the results and output as foo.csv
for result in `ls -1 ${SRC}/*_1.csv | sed 's/_1.csv//'`; do
    $AVG `ls *${result}*.csv` > `basename ${result}`.csv
done

for i in `ls ${PREFIX}*`; do
    mv $i `echo $i | sed -e "s/${PREFIX}//" -e "s/${SUFFIX}//"`;
done
