"""
    Coordinate Transformation
    Copyright (c) 2021 
	
	Authors: Ike Kunze, René Glebke, Jan Scheiper
	E-mail: inp@comsys.rwth-aachen.de
"""

import socket, struct

def ip_to_int(addr):
    return sum([int(b) << (24 - i*8) for i,b in enumerate(addr.split("."))])

def loadMatrix(tofino_addr, match_addr, mat3x4):
    packet = struct.pack("!Idddddddddddd",
        ip_to_int(match_addr),
        mat3x4[0], mat3x4[1], mat3x4[2],
        mat3x4[4], mat3x4[5], mat3x4[6],
        mat3x4[8], mat3x4[9], mat3x4[10],
        mat3x4[3], mat3x4[7], mat3x4[11]
    )

    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    sock.connect((tofino_addr, 16400))

    sock.send(packet)

    data = sock.recv(1024)

    if data != b"ok":
        print("Received unexpected response: " + str(data, "ascii"))

    sock.close()

def closeMatrixLoader(tofino_addr):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect((tofino_addr, 16400))

    sock.send(b"exit")

    data = sock.recv(1024)

    if data != b"ok":
        print("Received unexpected response: " + str(data, "ascii"))

    sock.close()