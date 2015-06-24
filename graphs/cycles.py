#!/usr/bin/env python2

import argparse
import numpy
import re
import sys

def main():
    '''From space-delimited input files, calculate the sum of every N
    columns for lines that do not contain the string "Sys" or "CPU".

    Input file format:
    <empty line>
    System....
    ...CPU...
    <result 1-1>
    <result 1-2>
    <result 1-3>
    System...
    ...CPU...
    <result 2-1>
    <result 2-2>
    ...

    Outputs one sum per line.
    '''
    parser = argparse.ArgumentParser(description=main.__doc__)
    parser.add_argument('-o', '--output', default='/dev/stdout',
                        help='output file (default: stdout)')
    parser.add_argument('-c', '--column', type=int, default=1,
                        help='column to sum')
    parser.add_argument('-a', '--average', default=False, action="store_true",
                        help='average the sum over the number of lines')
    parser.add_argument('input', nargs='+', help='Input files')
    args = parser.parse_args()

    output = ['result\n']
    data = []
    for infile in args.input:
        with open(infile, 'r') as f:
            # Latest ones have an empty line to begin.
            f.readline()

            d = []
            curr = None
            lines = 0
            for line in f:
                if line == '':
                    continue
                if re.match("^Sys.*", line):
                    if curr is not None:
                        if args.average:
                            d.append(curr / lines)
                        else:
                            d.append(curr)
                        curr = None
                        lines = 0
                    continue
                if re.match(" CPU ", line):
                    curr = float(0)
                    continue;
                l = line.split()
                curr = curr + float(l[args.column])
                lines = lines + 1
            if curr is not None:
                if args.average:
                    d.append(curr / lines)
                else:
                    d.append(curr)
            data.append(d)

    for l, line in enumerate(data[0]):
        output.append(str(line) + '\n')

    with open(args.output, 'w') as f:
        f.writelines(output)


if __name__ == '__main__':
    main()
