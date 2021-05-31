"""
    Coordinate Transformation
    Copyright (c) 2021 
	
	Authors: Ike Kunze, René Glebke, Jan Scheiper
	E-mail: inp@comsys.rwth-aachen.de
"""

import sys, math, random

if len(sys.argv) < 2:
    print("No row count given")
    exit()

rows = int(sys.argv[1])

random.seed()

for i in range(rows):
    radius = round(random.random() * 20, 9)
    phi = round(random.random() * math.pi * 2, 9)
    theta = round(random.random() * math.pi * 2, 9)

    print("{}, {}, {}".format(radius, phi, theta))