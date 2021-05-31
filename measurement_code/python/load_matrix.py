"""
    Coordinate Transformation
    Copyright (c) 2021 
	
	Authors: Ike Kunze, René Glebke, Jan Scheiper
	E-mail: inp@comsys.rwth-aachen.de
"""

import argparse
from matrixLoader_interface import loadMatrix

def matrix_type(s):
    if s[0] != "(" or s[-1] != ")":
        raise argparse.ArgumentError("Invalid matrix argument. Must look like: (a00,a01,a02,a03,a10,a11,a12,a13,a20,a21,a22,a23)")

    s = s[1:-1]

    entries = tuple([ float(e.strip()) for e in s.split(",") ])
    if len(entries) == 12:
        return entries
    else:
        raise argparse.ArgumentError("Invalid matrix argument. Must look like: (a00,a01,a02,a03,a10,a11,a12,a13,a20,a21,a22,a23)")

parser = argparse.ArgumentParser(description="Load a matrix into a specified device")
parser.add_argument("-a", "-address", dest="address", metavar="address", help="Address to target the matrix to", type=str, required=True)
parser.add_argument("-t", "--transform", dest="transform_matrix", metavar="3x4 row-major matrix", help="Transform the converted coordinates with this matrix. You need to surround the argument with parentheses", required=True, type=matrix_type)
parser.add_argument("-m", "--loader-addr", dest="loader_addr", metavar="address", help="Address of the device running the matrixLoader script", required=True)

args = parser.parse_args()

print("Sending matrix to device...")

loadMatrix(args.loader_addr, args.address, args.transform_matrix)