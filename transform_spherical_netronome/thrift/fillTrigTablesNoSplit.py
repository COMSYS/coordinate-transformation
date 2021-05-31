"""
    Coordinate Transformation
    Copyright (c) 2021 
	
	Authors: Ike Kunze, René Glebke, Jan Scheiper
	E-mail: inp@comsys.rwth-aachen.de
"""

import math, threading, sys
from config import keyShiftConstant, resultShiftConstant
from RTEInterface import RTEInterface

tables = {
    "phi": ("spherical.phi"),
    "theta": ("spherical.theta"),
}

THRIFT_API_LOCK = threading.Lock()

inputAverage = True # calculate the result for the average of the range start and end instead of of the start value
RANGE_UPPER_LIMIT = math.pi*2

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

    for tableName, (key) in tables.items():
        print("inserting " + tableName )
        generateTable(tableName, key, 0, RANGE_UPPER_LIMIT)