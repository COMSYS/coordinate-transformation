/*
    Coordinate Transformation
    Copyright (c) 2021 
	
	Authors: Ike Kunze, René Glebke, Jan Scheiper
	E-mail: inp@comsys.rwth-aachen.de
*/

table matrix_row1_table {
    key = {
        hdr.ipv4.dst_addr : exact;
    }
    actions = {
        getMatrixRowPPP;
        getMatrixRowPPN;
        getMatrixRowPNP;
        getMatrixRowPNN;
        getMatrixRowNPP;
        getMatrixRowNPN;
        getMatrixRowNNP;
        getMatrixRowNNN;
    }
    default_action = getMatrixRowPPP(1 << FIX_POINT_EXPONENT, 0, 0);
} 

table matrix_row2_table {
    key = {
        hdr.ipv4.dst_addr : exact;
    }
    actions = {
        getMatrixRowPPP;
        getMatrixRowPPN;
        getMatrixRowPNP;
        getMatrixRowPNN;
        getMatrixRowNPP;
        getMatrixRowNPN;
        getMatrixRowNNP;
        getMatrixRowNNN;
    }
    default_action = getMatrixRowPPP(0, 1 << FIX_POINT_EXPONENT, 0);
} 

table matrix_row3_table {
    key = {
        hdr.ipv4.dst_addr : exact;
    }
    actions = {
        getMatrixRowPPP;
        getMatrixRowPPN;
        getMatrixRowPNP;
        getMatrixRowPNN;
        getMatrixRowNPP;
        getMatrixRowNPN;
        getMatrixRowNNP;
        getMatrixRowNNN;
    }
    default_action = getMatrixRowPPP(0, 0, 1 << FIX_POINT_EXPONENT);
} 