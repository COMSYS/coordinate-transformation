/*
    Coordinate Transformation
    Copyright (c) 2021 
	
	Authors: Ike Kunze, René Glebke, Jan Scheiper
	E-mail: inp@comsys.rwth-aachen.de
*/

bit<8> sign = 0;
bit<64> result_bytes;

bit<32> a = (bit<32>)a_input;
bit<32> b = (bit<32>)b_input;

if (a >= 2147483648) {
    sign = sign + 1;
    a = (bit<32>)(-a_input);
}
if (b >= 2147483648) {
    sign = sign + 1;
    b = (bit<32>)(-b_input);
}

bit<32> temp1;
bit<32> temp2;
bit<32> temp3;

temp1 = (bit<32>)a[15:0] * (bit<32>)b[15:0];
result_bytes[15:0] = temp1[15:0];

temp2 = (bit<32>)a[31:16] * (bit<32>)b[15:0] + (bit<32>)a[15:0] * (bit<32>)b[31:16];

temp3 = temp2 + (bit<32>)temp1[31:16];
result_bytes[31:16] = temp3[15:0];

temp1 = (bit<32>)a[31:16] * (bit<32>)b[31:16];
temp1 = temp1 + (bit<32>)temp3[31:16];


result_bytes[63:32] = temp1;


int<64> result_int = (int<64>)result_bytes;

if (sign[0:0] == 1) {
    result_int = -result_int;
}

result_int = result_int >> FIX_POINT_EXPONENT;

res = (int<32>) result_int;