"""
    Coordinate Transformation
    Copyright (c) 2021 
	
	Authors: Ike Kunze, René Glebke, Jan Scheiper
	E-mail: inp@comsys.rwth-aachen.de
"""

def main():
    import math

    p4 = bfrt.transform_spherical_fastmp_split_multipipe_main.pipe

    FIX_POINT_EXPONENT = 25
    BIT_SPLIT = 14
    keyShiftConstant = 2**FIX_POINT_EXPONENT
    resultShiftConstant = 2**FIX_POINT_EXPONENT

    tables = [
        "phi",
        "theta",
    ]


    RANGE_UPPER_LIMIT = math.pi*2

    def generateTable(tableName, suffix, stepSizeExponent, maxValue):
        if not tableName + suffix + "Table" in dir(p4.Ingress):
            print(tableName + suffix + "Table is missing")
            return

        table = getattr(p4.Ingress, tableName + suffix + "Table")

        stepSize = int(2**stepSizeExponent)

        j = 1
        steps = (int(math.ceil(maxValue * keyShiftConstant)) + stepSize) / stepSize

        for i in range(0, int(math.ceil(maxValue * keyShiftConstant)) + stepSize, stepSize):
            value = float(i) / keyShiftConstant

            resultSin = math.sin(value)
            resultCos = math.cos(value)

            actionString = "trig" + suffix + ("Pos" if (resultSin >= 0) else "Neg") + ("Pos" if (resultCos >= 0) else "Neg")
            addFn = getattr(table, "add_with_" + actionString)

            if j % 100 == 0 or j == int(steps):
                print('{}/{}\r'.format(j, int(steps)), end=""),

            addFn(i >> stepSizeExponent, round(abs(resultSin) * resultShiftConstant), round(abs(resultCos) * resultShiftConstant))

            j += 1

        print()

    for tableName in tables:

        print("inserting " + tableName + "Lower")
        generateTable(tableName, "Lower", 0, float(2**BIT_SPLIT) / keyShiftConstant)
        print("inserting " + tableName + "Upper")
        generateTable(tableName, "Upper", BIT_SPLIT, RANGE_UPPER_LIMIT)

main()