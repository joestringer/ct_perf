#!/bin/sh

# From the paper "Netfilter Performance Testing"
#
#Jozsef Kadlecsik (KFKI RMKI) <kadlec@sunserv.kfki.hu>
#Gyorgy Pasztor (SZTE EK) <pasztor@linux.gyakg.u-szeged.hu>
#
# Minor updates for recent linux by Joe Stringer <joestringer@nicira.com>

# 4KB send buffer, 20,480 connections max at worst case
echo 83886080 > /proc/sys/net/core/wmem_max
echo 83886080 > /proc/sys/net/core/wmem_default

# 16KB receive buffer, 20,480 connections max at worst case
echo 335544320 > /proc/sys/net/core/rmem_max
echo 335544320 > /proc/sys/net/core/rmem_default

# Fast port recycling (TIME_WAIT)
echo 1 >/proc/sys/net/ipv4/tcp_tw_recycle
echo 1 >/proc/sys/net/ipv4/tcp_tw_reuse

# TIME_WAIT buckets increased
# JS: Default these days is 128K
#echo 65536 > /proc/sys/net/ipv4/tcp_max_tw_buckets

# FIN timeout decreased
echo 15 > /proc/sys/net/ipv4/tcp_fin_timeout

# SYN backlog increased
echo 65536 > /proc/sys/net/ipv4/tcp_max_syn_backlog

# SYN cookies enabled
echo 1 > /proc/sys/net/ipv4/tcp_syncookies

# Local port range maximized
echo "1024 65535" > /proc/sys/net/ipv4/ip_local_port_range

# Netdev backlog increased
echo 100000 > /proc/sys/net/core/netdev_max_backlog

# Interface transmit queuelen increased
# JS: Replace with ethtool equivalent?
#ifconfig eth0 txqueuelen 10000

# Conntrack limits
sysctl -w net.netfilter.nf_conntrack_max=16777216
sysctl -w net.netfilter.nf_conntrack_tcp_timeout_time_wait=1
