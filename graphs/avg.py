#!/usr/bin/env python2

import argparse
import numpy
import sys

def main():
    '''Average the nth (default:4) zero-indexed column in the given
    input CSV files'''
    parser = argparse.ArgumentParser(description=main.__doc__)
    parser.add_argument('-o', '--output', default='/dev/stdout',
                        help='output file (default: stdout)')
    parser.add_argument('-c', '--column', type=int, default=4,
                        help='column to average')
    parser.add_argument('input', nargs='+', help='Input files')
    args = parser.parse_args()

    output = ['DEBUG: firstline']
    data = []
    for infile in args.input:
        with open(infile, 'r') as f:
            # Latest ones have an empty line to begin.
            output[0] = f.readline()
            while not output[0].strip():
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

        line[args.column] = ' ' + str(float(numpy.mean(datapoint)))
        output.append(','.join(line) + '\n')

    with open(args.output, 'w') as f:
        f.writelines(output)


if __name__ == '__main__':
    main()
