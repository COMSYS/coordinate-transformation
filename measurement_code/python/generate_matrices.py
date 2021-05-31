"""
    Coordinate Transformation
    Copyright (c) 2021 
	
	Authors: Ike Kunze, René Glebke, Jan Scheiper
	E-mail: inp@comsys.rwth-aachen.de
"""

import sys, math, random

if len(sys.argv) < 2:
    print("Usage: generate_matrices.py <rows>")
    exit()

rows = int(sys.argv[1])

random.seed()

def randrange(low, high):
    return low + random.random() * (high - low)

for i in range(rows):
    matrix = [
        randrange(-1, 1), randrange(-1, 1), randrange(-1, 1), randrange(0, 10),
        randrange(-1, 1), randrange(-1, 1), randrange(-1, 1), randrange(0, 10),
        randrange(-1, 1), randrange(-1, 1), randrange(-1, 1), randrange(0, 10),
    ]

    print(",".join(str(x) for x in matrix))