"""
    Coordinate Transformation
    Copyright (c) 2021 
	
	Authors: Ike Kunze, René Glebke, Jan Scheiper
	E-mail: inp@comsys.rwth-aachen.de
"""

from scapy.all import *
from spherical_layer import SphericalHigh, SphericalHighTofino, DebugCounters
from timing_layer import TimingLayerCreator
from config import keyShiftConstant, resultShiftConstant
import sys, time, socket, argparse, struct

parser = argparse.ArgumentParser(description="Receive a specially crafted packet with transformed coordinates.")
parser.add_argument("-T", "--tofino", help="Target the tofino version of the code (i.e. send a tofino-specific packet)", action="store_true", dest="tofino_mode")
parser.add_argument("-N", "--netro", help="Target the Netronome version of the code (i.e. expect netro-specific timestamps)", action="store_true", dest="netro_mode")
parser.add_argument("--timing", help="Insert a special timing layer and use it for timing instead of the system clock", action="store_true", dest="timing_layer")
parser.add_argument("-a", metavar="bind_address", help="Address to bind to", type=str, required=True)
parser.add_argument("-l", "--log-file", help="Write receive times to this file", type=argparse.FileType("w"))
parser.add_argument("-w", "--result-file", help="Write received values to this file", type=argparse.FileType("w"))
parser.add_argument("--quiet", help="Suppress outputting most things", action="store_true")
parser.add_argument("--show-pkts", help="Show full packet content", dest="show_pkts", action="store_true")
parser.add_argument("--max-packets", metavar="count", dest="max_packets", type=int, help="Max number of packets")
parser.add_argument("-P", "--dport", metavar="port", dest="dport", default=10000, help="Destination port for spherical packets (Default: 10000)", type=int)
parser.add_argument("-TP", "--timing-dport", metavar="port", dest="t_dport", default=10001, help="Destination port for timing+spherical packets (Default: 10001)", type=int)
parser.add_argument("--counters", action="store_true", dest="use_counters", help="Append debug counters after the main payload")

args = parser.parse_args()

listen_addr = args.a

TimingLayer = TimingLayerCreator(2)

if args.tofino_mode:
    SphericalHigh = SphericalHighTofino

recv_port = args.t_dport if args.timing_layer else args.dport

bind_layers(UDP, TimingLayer, dport=args.t_dport)
bind_layers(TimingLayer, SphericalHigh)
bind_layers(UDP, SphericalHigh, dport=args.dport)

if args.use_counters:
    bind_layers(SphericalHigh, DebugCounters)

count = 1
keepRunning = True

def fix_ts(v):
    if math.isnan(v):
        return float("nan")
    return (int(v) >> 32) * 10**9 + (int(v) & 0xffffffff)

def disp(p):
    global count, keepRunning

    if args.log_file is not None and not args.timing_layer:
        args.log_file.write(str(time.time()) + "\n")

    print("Packet {} at {}:".format(count, time.time()))

    if args.show_pkts:
        p.show()
    
    try:
        result = (
            float(p[0][SphericalHigh].x) / resultShiftConstant, 
            float(p[0][SphericalHigh].y) / resultShiftConstant, 
            float(p[0][SphericalHigh].z) / resultShiftConstant
        )
        
        if args.result_file is not None:
            start_ts = p[0][SphericalHigh].start_ts
            end_ts = p[0][SphericalHigh].end_ts

            if args.netro_mode:
                start_ts = fix_ts(start_ts)
                end_ts = fix_ts(end_ts)

            args.result_file.write("{}, {}, {}, {}, {}\n".format(result[0], result[1], result[2], start_ts, end_ts))
            args.result_file.flush()

        if args.log_file is not None and args.timing_layer:
            args.log_file.write("{hop1}, {hop2}\n".format(hop1=p[0][TimingLayer].hop1, hop2=p[0][TimingLayer].hop2))

        if not args.quiet:
            print("Result:")
            print("\tx: " + str(result[0]))
            print("\ty: " + str(result[1]))
            print("\tz: " + str(result[2]))
            print("\tstart ts: " + str(p[0][SphericalHigh].start_ts))
            print("\tend ts: " + str(p[0][SphericalHigh].end_ts))
            print("\tcompute time: " + str(p[0][SphericalHigh].end_ts - p[0][SphericalHigh].start_ts) + "ns")
            if args.timing_layer:
                print("\tnetwork time: " + str(p[0][TimingLayer].hop2 - p[0][TimingLayer].hop1) + "ns")

            if p[0].haslayer(DebugCounters):
                print("\tCounters: in={c_in} out={c_out}".format(c_in=p[0][DebugCounters].counter_in, c_out=p[0][DebugCounters].counter_out))
    except:
        if not args.quiet:
            print("Not a spherical packet")

    if args.max_packets is not None:
        if count == args.max_packets:
            keepRunning = False

    count += 1

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind((listen_addr, recv_port))

while keepRunning:
    data, addr = sock.recvfrom(1024)

    if args.timing_layer:
        disp(TimingLayer(data))
    else:
        disp(SphericalHigh(data))
