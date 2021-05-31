"""
    Coordinate Transformation
    Copyright (c) 2021 
	
	Authors: Ike Kunze, René Glebke, Jan Scheiper
	E-mail: inp@comsys.rwth-aachen.de
"""

import socket, sys, time, argparse
from scapy.all import *
from spherical_layer import SphericalHigh, SphericalHighTofino, DebugCounters
from timing_layer import TimingLayerCreator
from math import floor, cos, sin
from calculator import toCartesian, matrixVectorMultiply3x4
from matrixLoader_interface import loadMatrix
from config import keyShiftConstant, resultShiftConstant
from pyroute2 import IPRoute

def matrix_type(s):
    if s[0] != "(" or s[-1] != ")":
        raise argparse.ArgumentError("Invalid matrix argument. Must look like: (a00,a01,a02,a03,a10,a11,a12,a13,a20,a21,a22,a23)")

    s = s[1:-1]

    entries = tuple([ float(e.strip()) for e in s.split(",") ])
    if len(entries) == 12:
        return entries
    else:
        raise argparse.ArgumentError("Invalid matrix argument. Must look like: (a00,a01,a02,a03,a10,a11,a12,a13,a20,a21,a22,a23)")

parser = argparse.ArgumentParser(description="Send a specially crafted packet with spherical coordinates to a calculating device.")
parser.add_argument("-T", "--tofino", help="Target the tofino version of the code (i.e. send a tofino-specific packet)", action="store_true", dest="tofino_mode")
parser.add_argument("--timing", help="Insert a special timing layer and use it for timing instead of the system clock", action="store_true", dest="timing_layer")
parser.add_argument("-s", metavar="send_address", help="Address to send the packet from", default=None, type=str)
parser.add_argument("-a", metavar="address", help="Address to send the packet to", type=str, required=True)
parser.add_argument("-r", "--radius", help="Radius coordinate", type=float, required=True)
parser.add_argument("-p", "--phi", help="Phi coordinate", type=float, required=True)
parser.add_argument("-t", "--theta", help="Theta coordinate", type=float, required=True)
parser.add_argument("-l", "--log-file", help="Write send times to this file", type=argparse.FileType("w"))
parser.add_argument("-w", "--value-file", help="Append sent values to this file", type=argparse.FileType("a"))
parser.add_argument("--quiet", help="Suppress outputting most things", action="store_true")
parser.add_argument("--verbose", help="Output more things", action="store_true")
parser.add_argument("-P", "--dport", metavar="port", dest="dport", default=10000, help="Destination port for spherical packets (Default: 10000)", type=int)
parser.add_argument("-TP", "--timing-dport", metavar="port", dest="t_dport", default=10001, help="Destination port for timing+spherical packets (Default: 10001)", type=int)
parser.add_argument("-SP", "--sport", metavar="port", dest="sport", help="Sending port (Default: None)", type=int)
parser.add_argument("--counters", action="store_true", dest="use_counters", help="Append debug counters after the main payload")
parser.add_argument("--transform", dest="transform_matrix", metavar="3x4 row-major matrix", help="Transform the converted coordinates with this matrix. You need to surround the argument with parentheses", default=None, type=matrix_type)
parser.add_argument("-m", "--loader-addr", dest="loader_addr", metavar="address", help="Address of the Tofino running the matrixLoader bfrt script", default=None)
parser.add_argument("--target-self", dest="target_self", action="store_true", help="Assume that the target device is designed to send the results back to us", default=False)

args = parser.parse_args()

send_addr = args.s
addr = args.a
radius = args.radius
theta = args.theta
phi = args.phi

do_output = not args.quiet or args.verbose

TimingLayer = TimingLayerCreator(2)

if args.tofino_mode:
    SphericalHigh = SphericalHighTofino

    if do_output:
        print("Sending a TOFINO packet")
elif do_output:
    print("Sending a NORMAL packet")

dest_port = args.t_dport if args.timing_layer else args.dport

bind_layers(UDP, TimingLayer, dport=args.t_dport)
bind_layers(TimingLayer, SphericalHigh)
bind_layers(UDP, SphericalHigh, dport=args.dport)

print("radius={}, theta={}, phi={}".format(radius, theta, phi))

# use debug version
# SphericalHigh = SphericalHighDbg

p = SphericalHigh(radius = int(math.floor(radius * resultShiftConstant)), theta = int(math.floor(theta * keyShiftConstant)), phi = int(math.floor(phi * keyShiftConstant)))

if args.timing_layer:
    p = TimingLayer() / p

if args.use_counters:
    bind_layers(SphericalHigh, DebugCounters)
    p /= DebugCounters()

if args.verbose:
    p.show()

if args.loader_addr is not None and args.transform_matrix is not None:
    if do_output:
        print("Sending matrix to Tofino...")

    if args.target_self:
        if send_addr is not None:
            loadMatrix(args.loader_addr, send_addr, args.transform_matrix)
        else: # try to lookup the route ourselves
            with IPRoute() as ipr:
                route = ipr.route("get", dst=addr)[0]
                src_addr = None

                for attr in route["attrs"]:
                    if attr[0] == "RTA_PREFSRC":
                        src_addr = attr[1]
                        break

                if src_addr is not None:
                    loadMatrix(args.loader_addr, src_addr, args.transform_matrix)
                else:
                    print("Could not find source address to reach the dest address")
    else:
        loadMatrix(args.loader_addr, addr, args.transform_matrix)

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

if send_addr is not None:
    sock.bind((send_addr, 10002 if args.sport is None else args.sport))

data = bytes(p)

if do_output:
    print("Sending at ", time.time())

sendTime = time.time()

sock.sendto(data, (addr, dest_port))

if args.log_file is not None and not args.timing_layer:
    args.log_file.write("{}, {}\n".format(sendTime, time.time()))

if do_output:
    print("Finished sending at ", time.time())

exactResult = toCartesian(radius, phi, theta)

if args.value_file is not None:
    args.value_file.write("{}, {}, {}, {}, {}, {}\n".format(radius, theta, phi, exactResult[0], exactResult[1], exactResult[2]))

if do_output:

    if args.transform_matrix is None:
        print("Exact result:")
        print("\tx: " + str(exactResult[0]))
        print("\ty: " + str(exactResult[1]))
        print("\tz: " + str(exactResult[2]))
    else:
        print("Exact result including transform:")

        exactResult = matrixVectorMultiply3x4(args.transform_matrix, (*exactResult, 1))

        print("\tx: " + str(exactResult[0]))
        print("\ty: " + str(exactResult[1]))
        print("\tz: " + str(exactResult[2]))

    