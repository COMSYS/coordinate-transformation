"""
    Coordinate Transformation
    Copyright (c) 2021 
	
	Authors: Ike Kunze, René Glebke, Jan Scheiper
	E-mail: inp@comsys.rwth-aachen.de
"""

import math, threading, sys, socket, struct
from config import keyShiftConstant, resultShiftConstant, BIT_SPLIT
from RTEInterface import RTEInterface

def fixp_repr(x):
    return int(round(x * keyShiftConstant)) & (2**32-1)

def fixp_repr2(x):
    return int(round(x * keyShiftConstant))

def format_addr(a):
    return "{b0}.{b1}.{b2}.{b3}".format(b0=a >> 24, b1 = 0xff & (a >> 16), b2 = 0xff & (a >> 8), b3 = 0xff & a)

def matrixLoader():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(("", 16400))
    server.listen(10)

    print("Waiting for incoming connections\n")

    running = True

    while running:
        sock, addr = server.accept()

        print("Connection from " + addr[0])

        data = sock.recv(1024)

        if data[:4] == b"exit":
            running = False
            sock.send(b"ok")
            sock.close()
            break

        if len(data) < 100:
            print("Invalid packet {size} < 100".format(size=len(data)))
            continue

        ip_addr, a00, a01, a02, a10, a11, a12, a20, a21, a22, t0, t1, t2 = struct.unpack("!Idddddddddddd", data)

        print("Adding/updating transformation matrix for IP {addr}".format(addr=format_addr(ip_addr)))
        print("{a00:.3f}\t{a01:.3f}\t{a02:.3f}\t{t0:.3f}".format(a00=a00, a01=a01, a02=a02, t0=t0))
        print("{a10:.3f}\t{a11:.3f}\t{a12:.3f}\t{t1:.3f}".format(a10=a10, a11=a11, a12=a12, t1=t1))
        print("{a20:.3f}\t{a21:.3f}\t{a22:.3f}\t{t2:.3f}".format(a20=a20, a21=a21, a22=a22, t2=t2))

        index = ip_addr & 0xFF

        RTEInterface.Registers.Set("matrix_table_a00", [ "0x{:0x}".format(fixp_repr(a00)) ], index, 1)
        RTEInterface.Registers.Set("matrix_table_a01", [ "0x{:0x}".format(fixp_repr(a01)) ], index, 1)
        RTEInterface.Registers.Set("matrix_table_a02", [ "0x{:0x}".format(fixp_repr(a02)) ], index, 1)
        RTEInterface.Registers.Set("matrix_table_a10", [ "0x{:0x}".format(fixp_repr(a10)) ], index, 1)
        RTEInterface.Registers.Set("matrix_table_a11", [ "0x{:0x}".format(fixp_repr(a11)) ], index, 1)
        RTEInterface.Registers.Set("matrix_table_a12", [ "0x{:0x}".format(fixp_repr(a12)) ], index, 1)
        RTEInterface.Registers.Set("matrix_table_a20", [ "0x{:0x}".format(fixp_repr(a20)) ], index, 1)
        RTEInterface.Registers.Set("matrix_table_a21", [ "0x{:0x}".format(fixp_repr(a21)) ], index, 1)
        RTEInterface.Registers.Set("matrix_table_a22", [ "0x{:0x}".format(fixp_repr(a22)) ], index, 1)
        RTEInterface.Registers.Set("matrix_table_t0", [ "0x{:0x}".format(fixp_repr(t0)) ], index, 1)
        RTEInterface.Registers.Set("matrix_table_t1", [ "0x{:0x}".format(fixp_repr(t1)) ], index, 1)
        RTEInterface.Registers.Set("matrix_table_t2", [ "0x{:0x}".format(fixp_repr(t2)) ], index, 1)

        sock.send(b"ok")
        sock.close()

    server.close()

if __name__ == "__main__":
    RTEInterface.Connect("thrift", "localhost", 20206)

    matrixLoader()
