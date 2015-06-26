# ct_perf
Connection tracking benchmark scripts and data for one test.

## Topology

- Three nodes: Source, Device Under Test, Sink
- Each node is Intel Xeon E5-2650 @ 2.00GHz
- Netperf is run on source, pointed at sink
- DUT contains bridge/ovs/ipt/nft configuration
- DUT runs perf stat to gather CPU usage
- DUT has linux-4.0.5 vanilla from kernel.org installed.
-- Configured as per Ubuntu 3.13 kernel.

## Requirements

For running the tests:

On source and sink:
* Netperf (For generating connections)
* Python 2.7

On device under test:
* iptables
* ipset
* Recent nftables (NFWS2015 talk used git @ 2015-06-13)
* Open vSwitch with conntrack support
* Perf (For gathering CPU)

For generating the graphs:

* Python 2.7
* gnuplot 4.6 patchlevel 6
* make

## Data

raw/ contains two sets of data for the same test:

raw/*.txt includes the output of CPU gathering scripts
raw/*.csv includes the output of the netperf stats gathering

Baseline performance:
raw/*bridge* - Bridge configured to switch packets between Source and Sink.
raw/*ovsl2* - Equivalent OVS bridge configured with "NORMAL" l2 behaviour

Linear performance:
raw/*ipt1k* - Apply 1000 unrelated rules before one set of firewall rules
raw/*nft1k* - Equivalent policy using nftables

Map-based performance:
raw/*ovsct* - OpenFlow flows to implement the same policy
raw/nftmap - NFTables using maps
raw/nftset - NFTables using sets
raw/iptset - IPset

## Gathering data

The scripts in source/ must be placed on the node which you wish to perform
the netperf from. The variables at the top of those scripts, and at the top
of the scripts in dut/ may neeed updating for details such as IP addresses
of source, sink and locations of the scripts.

The scripts in dut/ are used from the device under test. The "suite.sh" script
will perform configuration for each test, remotely schedule the netperf test
to run on the source, gather local CPU usage for the duration of the test,
and fetch the data from the source after the test is run.

dut/tune.sh will tune various parameters. For the dataset in this repository,
this script was run on each server - source, dut and sink.

## Generating graphs

From root of git repository:

$ make

This will generate a variety of graphs using gnuplot and output an index.html
which includes all of the graphs.

For connection per sec, connections per sec per CPU %, higher is better.

For CPU % (Bars on some graphs), lower is better.
