#!/bin/bash
#
# Author: Joe Stringer <joestringer@nicira.com>
#
# Runs various conntrack tests.
#
# Connects to remote hosts to run netperf_suite, and runs local CPU gathering
# via netperf stat. Gathers all of the results into the current directory.

# Local configurations
IP="172.31.1.26/24"
PORTS="p3p1 p2p1 p2p2" # p2p1 = 125, p2p2 = 127, p3p1 = 135
OVS_PATH=~joe/ovs/
TEST_PREFIX=3node_e2e
OUTDIR=raw/
RULES=rules/

# Remote hosts
NETPERF=~joe/bin/netperf_suite
S1=10.114.97.235

LBR=linux-br0
OBR=ovs-br0
OVS_DEV=$OVS_PATH/utilities/ovs-dev.py
OVS_KMOD=$OVS_PATH/_build-gcc/datapath/linux/openvswitch.ko

NAP=30
NOOP=0
N_TESTS=3

`$OVS_DEV env`

run_test()
{
    if [ $NOOP -ne 0 ]; then
        read -p "Test '$1' is ready to run. [Enter] to fake it."
    else
        echo "$NETPERF ${TEST_PREFIX}_$1 $N_TESTS" > test.sh
        chmod +x test.sh
        scp test.sh root@${S1}:~
        ssh root@${S1} "bash ./test.sh" &
        > ${TEST_PREFIX}_$1.txt

        # Five tests: adjust based on netperf_suite on dst servers
        for i in `seq 1 $N_TESTS`; do
            for i in `seq 1 5`; do
                sleep 2; # corresponds to delay at beginning of super_netperf
                ~/bin/perfstat.py -d 30 >> $OUTDIR/${TEST_PREFIX}_$1.txt
            done
        done
    fi

    conntrack -F
}

start_bridge()
{
    brctl addbr ${LBR}
    ip link set dev ${LBR} up
    ip addr add dev ${LBR} ${IP}
    for p in ${PORTS}; do
        brctl addif ${LBR} ${p}
        ip link set dev $p up
    done
}

stop_bridge()
{
    ip addr del dev ${LBR} ${IP}
    for p in ${PORTS}; do
        brctl delif ${LBR} ${p}
    done
    ip link set dev ${LBR} down
    brctl delbr ${LBR}
}

start_ovs()
{
    insmod $OVS_KMOD
    $OVS_DEV run

    ovs-vsctl add-br ${OBR}
    ip link set dev ${OBR} up
    ip addr add dev ${OBR} ${IP}
    for p in ${PORTS}; do
        ovs-vsctl add-port ${OBR} ${p}
    done
    ovs-vsctl set int p3p1 ofport_request=1
    ovs-vsctl set int p2p1 ofport_request=2
    ovs-vsctl set int p2p2 ofport_request=3
}

stop_ovs()
{
    ip addr del dev ${OBR} ${IP}
    for p in ${PORTS}; do
        ovs-vsctl del-port ${OBR} ${p}
    done
    ovs-vsctl del-br ${OBR}

    $OVS_DEV kill
    rmmod openvswitch
}

bridge_tests()
{
    start_bridge $@

    run_test bridge $@

    sleep $NAP
    modprobe br_netfilter
    modprobe nf_conntrack_ipv4
    sysctl -w net.netfilter.nf_conntrack_tcp_timeout_time_wait=1
    sysctl -w net.netfilter.nf_conntrack_max=16777216

    iptables-restore $RULES/ipt-1000rules
    run_test ipt1k $@
    iptables -F

    sleep $NAP
    ipset restore -f $RULES/ipset-sets
    iptables-restore $RULES/ipset-iptrules
    run_test ipset $@
    iptables -F
    ipset destroy set1k
    for mod in xt_set ip_set_hash_ip ip_set; do
        rmmod $mod
    done

    sleep $NAP
    nft -f $RULES/nft-1000rules
    run_test nft1k $@
    nft delete table filter

    sleep $NAP
    nft -f $RULES/nft-set
    run_test nfset $@
    nft delete table filter

    sleep $NAP
    nft -f $RULES/nft-map
    nft -f $RULES/nft-map2
    run_test nfmap $@
    nft delete table filter

    stop_bridge $@
    for mod in nft_hash nft_rbtree nft_ct nft_meta nf_tables_ipv4 nf_tables nf_log_ipv4 nf_log_common br_netfilter ; do
        rmmod $mod
    done
}

ovs_tests()
{
    start_ovs

    # Assumes that OVS with no configuration does L2.
    run_test ovsl2 $@

    sleep $NAP
    ovs-ofctl add-flows ${OBR} $RULES/ovs-1000rules
    ovs-ofctl add-flow ${OBR} "in_port=3,actions=resubmit(2,0)"

    run_test ovsct $@

    stop_ovs
}

main_suite()
{
    bridge_tests $@
    ovs_tests $@

    conntrack -F
    sleep $NAP
    for mod in nf_conntrack_netlink nfnetlink xt_connlabel xt_conntrack; do
        rmmod $mod
    done

    echo
    echo "Not removing nf_conntrack_ipv* nf_conntrack"

    if [ $NOOP -eq 0 ]; then
        mkdir $OUTDIR/s1
        scp root@${S1}:/root/${TEST_PREFIX}* $OUTDIR/s1/
    fi
}

main_suite $@
