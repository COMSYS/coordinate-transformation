/*
    Coordinate Transformation
    Copyright (c) 2021 
	
	Authors: Ike Kunze, René Glebke, Jan Scheiper
	E-mail: inp@comsys.rwth-aachen.de
*/

@pragma entries_with_ranges(0)
table phiLowerTable {
	key = {
		meta.trigLower : exact;
	}
	actions = {
		trigLowerPosPos;
		trigLowerNegPos;
		trigLowerPosNeg;
		trigLowerNegNeg;
	}
    size = 100 + (1 << BIT_SPLIT);
}

@pragma entries_with_ranges(0)
table phiUpperTable {
	key = {
		meta.trigUpper : exact;
	}
	actions = {
		trigUpperPosPos;
		trigUpperNegPos;
		trigUpperPosNeg;
		trigUpperNegNeg;
	}
    size = 100 + (1 << (FIX_POINT_EXPONENT + 3 - BIT_SPLIT));
}

@pragma entries_with_ranges(0)
table thetaLowerTable {
	key = {
		meta.trigLower : exact;
	}
	actions = {
		trigLowerPosPos;
		trigLowerNegPos;
		trigLowerPosNeg;
		trigLowerNegNeg;
	}
    size = 100 + (1 << BIT_SPLIT);
}

@pragma entries_with_ranges(0)
table thetaUpperTable {
	key = {
		meta.trigUpper : exact;
	}
	actions = {
		trigUpperPosPos;
		trigUpperNegPos;
		trigUpperPosNeg;
		trigUpperNegNeg;
	}
    size = 100 + (1 << (FIX_POINT_EXPONENT + 3 - BIT_SPLIT));
}