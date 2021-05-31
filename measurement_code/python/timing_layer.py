"""
    Coordinate Transformation
    Copyright (c) 2021 
	
	Authors: Ike Kunze, René Glebke, Jan Scheiper
	E-mail: inp@comsys.rwth-aachen.de
"""

from scapy.all import *

def TimingLayerCreator(hops):
    class TimingLayer(Packet):
        name = "TimingLayer"
        fields_desc = [ ByteField("hops", 0) ] + list(LongField("hop{i}".format(i=i+1), 0) for i in range(hops))

    return TimingLayer