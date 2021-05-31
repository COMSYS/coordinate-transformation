/*
    Coordinate Transformation
    Copyright (c) 2021 
	
	Authors: Ike Kunze, René Glebke, Jan Scheiper
	E-mail: inp@comsys.rwth-aachen.de
*/

table phiLowerTable {
	key = {
		meta.phiLower : exact;
	}
	actions = {
		phiLowerPosPos;
		phiLowerNegPos;
		phiLowerPosNeg;
		phiLowerNegNeg;
	}
    size = 100 + (1 << BIT_SPLIT);
}

table phiUpperTable {
	key = {
		meta.phiUpper : exact;
	}
	actions = {
		phiUpperPosPos;
		phiUpperNegPos;
		phiUpperPosNeg;
		phiUpperNegNeg;
	}
    size = 100 + (1 << (FIX_POINT_EXPONENT + 3 - BIT_SPLIT));
}

table thetaLowerTable {
	key = {
		meta.thetaLower : exact;
	}
	actions = {
		thetaLowerPosPos;
		thetaLowerNegPos;
		thetaLowerPosNeg;
		thetaLowerNegNeg;
	}
    size = 100 + (1 << BIT_SPLIT);
}

table thetaUpperTable {
	key = {
		meta.thetaUpper : exact;
	}
	actions = {
		thetaUpperPosPos;
		thetaUpperNegPos;
		thetaUpperPosNeg;
		thetaUpperNegNeg;
	}
    size = 100 + (1 << (FIX_POINT_EXPONENT + 3 - BIT_SPLIT));
}

