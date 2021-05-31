"""
    Coordinate Transformation
    Copyright (c) 2021 
	
	Authors: Ike Kunze, René Glebke, Jan Scheiper
	E-mail: inp@comsys.rwth-aachen.de
"""

import math, threading, sys
from config import resultShiftConstant, BIT_SPLIT, TABLE_KEY_OFFSET, FIX_POINT_EXPONENT, USE_QUARTER_TABLES
from RTEInterface import RTEInterface

tables = {
    "phi": ("ingress::scalars.metadata@phiUpper", "ingress::scalars.metadata@phiLower"),
    "theta": ("ingress::scalars.metadata@thetaUpper", "ingress::scalars.metadata@thetaLower"),
}

THRIFT_API_LOCK = threading.Lock()

if not USE_QUARTER_TABLES:
    RANGE_UPPER_LIMIT = math.pi*2
else:
    RANGE_UPPER_LIMIT = math.pi*0.5

keyShiftConstant = 2**(FIX_POINT_EXPONENT - TABLE_KEY_OFFSET)

def generateTable(tableName, key, stepSizeExponent, maxValue):

    stepSize = int(2**stepSizeExponent)

    j = 0
    steps = (int(math.ceil(maxValue * keyShiftConstant)) + stepSize) / stepSize

    for i in range(0, int(math.ceil(maxValue * keyShiftConstant)) + stepSize, stepSize):
        value = float(i) / keyShiftConstant

        resultSin = math.sin(value)
        resultCos = math.cos(value)

        actionString = tableName + ("Pos" if (resultSin >= 0) else "Neg") + ("Pos" if (resultCos >= 0) else "Neg")
        
        match = '{ "%s": { "value": "%d" } }' % (key, i >> stepSizeExponent)
        actions = '{ "type": "ingress::%s", "data": { "sin": { "value": "%d" }, "cos": { "value": "%d" } } }' % (actionString, round(abs(resultSin) * resultShiftConstant), round(abs(resultCos) * resultShiftConstant))

        print '{}/{}\r'.format(j, steps),

        with THRIFT_API_LOCK:
            RTEInterface.Tables.AddRule("ingress::" + tableName + "Table", "%s_%s" % (actionString, i), False, match, actions)

        j += 1

    print ""

if __name__ == "__main__":
    RTEInterface.Connect("thrift", "localhost", 20206)

    for tableName, (keyUpper, keyLower) in tables.items():
        print("inserting " + tableName + "Lower")
        generateTable(tableName + "Lower", keyLower, 0, float(2**BIT_SPLIT) / keyShiftConstant)
        print("inserting " + tableName + "Upper")
        generateTable(tableName + "Upper", keyUpper, BIT_SPLIT, RANGE_UPPER_LIMIT)
