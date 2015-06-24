#!/bin/bash

OUTFILE=index.html

# Gather performance, CPU percentages from raw data
graphs/cpu.sh
graphs/avg_all.sh

# Convert to gnuplot-friendly format
for i in bridge ipset ipt1k nfmap nfset nft1k ovsct ovsl2; do
    graphs/parse.sh ${i}.csv # Conn/sec
    graphs/parse.sh ${i}_p.txt txt cpu # Conn/sec + % CPU
    graphs/combine.py ${i}_p.txt ${i}.csv > ${i}_x.csv;
    graphs/parse.sh ${i}_x.csv csv cpcp # conn/sec/cpu %
done

# Generate graphs/
graphs/crr.sh s "" l2
graphs/crr.sh 1l "" linear
graphs/crr.sh 1mi "" map
graphs/crr.sh
graphs/crr.sh 1mip p
graphs/efficiency.sh

# Generate a nice webpage with all the graphs
cat << EOF > ${OUTFILE}
<html>
<body>
EOF

echo $PWD

echo "<pre>" >> ${OUTFILE}
cat README.md >> ${OUTFILE}
echo "</pre>" >> ${OUTFILE}

for file in *2.png; do
    PREFIX=`echo $file | sed "s/2.png//"`
    echo "<h3>${PREFIX}</h3>" >> ${OUTFILE}
    for i in `seq 2 5`; do
        echo "<img src=\"${PWD}/${PREFIX}${i}.png\" />" >> ${OUTFILE}
    done
    echo "" >> ${OUTFILE}
done

cat << EOF >> ${OUTFILE}
</body>
</html>
EOF
