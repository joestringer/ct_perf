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
