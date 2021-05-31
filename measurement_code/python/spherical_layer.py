"""
    Coordinate Transformation
    Copyright (c) 2021 
	
	Authors: Ike Kunze, René Glebke, Jan Scheiper
	E-mail: inp@comsys.rwth-aachen.de
"""

from scapy.all import *

class SignedLongField(Field):
    def __init__(self, name, default):
        Field.__init__(self, name, default, "q")

class SphericalHigh(Packet):
    name = "Spherical"
    fields_desc = [
        SignedIntField("radius", 0),
        IntField("phi", 0),
        IntField("theta", 0),
        SignedIntField("x", 0),
        SignedIntField("y", 0),
        SignedIntField("z", 0),
        LongField("start_ts", 0),
        LongField("end_ts", 0),
    ]

class SphericalHighDbg(Packet):
    name = "SphericalDebug"
    fields_desc = [
        SignedIntField("radius", 0),
        IntField("phi", 0),
        IntField("theta", 0),
        SignedIntField("x", 0),
        SignedIntField("y", 0),
        SignedIntField("z", 0),
        LongField("start_ts", 0),
        LongField("end_ts", 0),
        SignedLongField("dbg1", 0),
        SignedLongField("dbg2", 0),
        SignedLongField("dbg3", 0),
    ]

class SphericalHighTofino(Packet):
    name = "Spherical"
    fields_desc = [
        ShortField("recirc_count", 0),
        SignedIntField("radius", 0),
        SignedIntField("phi", 0),
        SignedIntField("theta", 0),
        SignedIntField("x", 0),
        SignedIntField("y", 0),
        SignedIntField("z", 0),
        BitField("start_ts", 0, 48),
        BitField("end_ts", 0, 48),
    ]

class SphericalHighTofinoDbg(Packet):
    name = "Spherical"
    fields_desc = [
        ShortField("recirc_count", 0),
        SignedIntField("radius", 0),
        SignedIntField("phi", 0),
        SignedIntField("theta", 0),
        SignedIntField("x", 0),
        SignedIntField("y", 0),
        SignedIntField("z", 0),
        BitField("start_ts", 0, 48),
        BitField("end_ts", 0, 48),
        ShortField("dbg1", 0),
        IntField("dbg2", 0),
        IntField("dbg3", 0),
        SignedIntField("dbg4", 0),
    ]

class DebugCounters(Packet):
    name = "DebugCounter"
    fields_desc = [
        IntField("counter_in", 0),
        IntField("counter_out", 0),
    ]
