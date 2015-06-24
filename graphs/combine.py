#!/usr/bin/env python2

import argparse
import numpy
import sys

def main():
    '''Given two CSV input files, combine the zero-indexed Nth columns in each
    file by performing FINAL_RESULT = R1 * UNITS / R2.

    Output format is the same as the input format, with the first line copied
    from the first input file.
    '''
    parser = argparse.ArgumentParser(description=main.__doc__)
    parser.add_argument('-o', '--output', default='/dev/stdout',
                        help='output file (default: stdout)')
    parser.add_argument('-c', '--column', type=int, default=4,
                        help='column to average')
    parser.add_argument('-u', '--unit', type=int, default=1,
                        help='units (eg 1000 = out of 1K)')
    parser.add_argument('-r', '--reverse', default=False, action='store_true',
                        help='Reverse the variables for calculation')
    parser.add_argument('input', nargs='+', help='Input files')
    args = parser.parse_args()

    output = ['DEBUG: firstline']
    data = []
    for infile in args.input:
        with open(infile, 'r') as f:
            output[0] = f.readline()
            while (len(output[0]) == 0):
                output[0] = f.readline()

            d = []
            for line in f:
                if line == '':
                    continue
                l = line.split(',')
                d.append(l)
            data.append(d)

    for l, line in enumerate(data[0]):
        datapoint = []
        for f in data:
            d = f[l][args.column]
            datapoint.append(float(d))

        if args.reverse:
            conns = datapoint[0]
            cpu = datapoint[1]
        else:
            conns = datapoint[1]
            cpu = datapoint[0]
        result = conns * args.unit / cpu
        line[args.column] = ' ' + str(result)
        output.append(','.join(line) + '\n')

    with open(args.output, 'w') as f:
        f.writelines(output)


if __name__ == '__main__':
    main()
