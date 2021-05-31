"""
    Coordinate Transformation
    Copyright (c) 2021 
	
	Authors: Ike Kunze, René Glebke, Jan Scheiper
	E-mail: inp@comsys.rwth-aachen.de
"""

FIX_POINT_EXPONENT = 25
keyShiftConstant = 2**FIX_POINT_EXPONENT
resultShiftConstant = 2**FIX_POINT_EXPONENT
BIT_SPLIT = 12

TABLE_KEY_OFFSET = 4
USE_QUARTER_TABLES = True

print("FIX_POINT_EXPONENT = " + str(FIX_POINT_EXPONENT))