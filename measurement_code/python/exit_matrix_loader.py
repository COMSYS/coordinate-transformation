"""
    Coordinate Transformation
    Copyright (c) 2021 
	
	Authors: Ike Kunze, René Glebke, Jan Scheiper
	E-mail: inp@comsys.rwth-aachen.de
"""

import sys
from matrixLoader_interface import closeMatrixLoader

if len(sys.argv) < 2:
    print("Usage: exit_matrix_loader.py <address>")
    print()
    print("Send an exit signal to the matrix loader running on <address>")
    sys.exit(0)

closeMatrixLoader(sys.argv[1])