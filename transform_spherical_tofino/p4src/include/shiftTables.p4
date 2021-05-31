/*
    Coordinate Transformation
    Copyright (c) 2021 
	
	Authors: Ike Kunze, René Glebke, Jan Scheiper
	E-mail: inp@comsys.rwth-aachen.de
*/

action shiftMultiply1_0() {
	meta.multAddValue = hdr.calculation.reg1 << 0;
}

action shiftMultiply1_1() {
	meta.multAddValue = hdr.calculation.reg1 << 1;
}

action shiftMultiply1_2() {
	meta.multAddValue = hdr.calculation.reg1 << 2;
}

action shiftMultiply1_3() {
	meta.multAddValue = hdr.calculation.reg1 << 3;
}

action shiftMultiply1_4() {
	meta.multAddValue = hdr.calculation.reg1 << 4;
}

action shiftMultiply1_5() {
	meta.multAddValue = hdr.calculation.reg1 << 5;
}

action shiftMultiply1_6() {
	meta.multAddValue = hdr.calculation.reg1 << 6;
}

action shiftMultiply1_7() {
	meta.multAddValue = hdr.calculation.reg1 << 7;
}

action shiftMultiply1_8() {
	meta.multAddValue = hdr.calculation.reg1 << 8;
}

action shiftMultiply1_9() {
	meta.multAddValue = hdr.calculation.reg1 << 9;
}

action shiftMultiply1_10() {
	meta.multAddValue = hdr.calculation.reg1 << 10;
}

action shiftMultiply1_11() {
	meta.multAddValue = hdr.calculation.reg1 << 11;
}

action shiftMultiply1_12() {
	meta.multAddValue = hdr.calculation.reg1 << 12;
}

action shiftMultiply1_13() {
	meta.multAddValue = hdr.calculation.reg1 << 13;
}

action shiftMultiply1_14() {
	meta.multAddValue = hdr.calculation.reg1 << 14;
}

action shiftMultiply1_15() {
	meta.multAddValue = hdr.calculation.reg1 << 15;
}

action shiftMultiply1_16() {
	meta.multAddValue = hdr.calculation.reg1 << 16;
}

action shiftMultiply1_17() {
	meta.multAddValue = hdr.calculation.reg1 << 17;
}

action shiftMultiply1_18() {
	meta.multAddValue = hdr.calculation.reg1 << 18;
}

action shiftMultiply1_19() {
	meta.multAddValue = hdr.calculation.reg1 << 19;
}

action shiftMultiply1_20() {
	meta.multAddValue = hdr.calculation.reg1 << 20;
}

action shiftMultiply1_21() {
	meta.multAddValue = hdr.calculation.reg1 << 21;
}

action shiftMultiply1_22() {
	meta.multAddValue = hdr.calculation.reg1 << 22;
}

action shiftMultiply1_23() {
	meta.multAddValue = hdr.calculation.reg1 << 23;
}

action shiftMultiply1_24() {
	meta.multAddValue = hdr.calculation.reg1 << 24;
}

action shiftMultiply1_25() {
	meta.multAddValue = hdr.calculation.reg1 << 25;
}

action shiftMultiply1_26() {
	meta.multAddValue = hdr.calculation.reg1 << 26;
}

action shiftMultiply1_27() {
	meta.multAddValue = hdr.calculation.reg1 << 27;
}

action shiftMultiply1_28() {
	meta.multAddValue = hdr.calculation.reg1 << 28;
}

action shiftMultiply1_29() {
	meta.multAddValue = hdr.calculation.reg1 << 29;
}

action shiftMultiply1_30() {
	meta.multAddValue = hdr.calculation.reg1 << 30;
}

action shiftMultiply1_31() {
	meta.multAddValue = hdr.calculation.reg1 << 31;
}

table shiftMultiply1_Table {
	key = {
		hdr.calculation.multBit : exact;
	}
	actions = {
		shiftMultiply1_0;
		shiftMultiply1_1;
		shiftMultiply1_2;
		shiftMultiply1_3;
		shiftMultiply1_4;
		shiftMultiply1_5;
		shiftMultiply1_6;
		shiftMultiply1_7;
		shiftMultiply1_8;
		shiftMultiply1_9;
		shiftMultiply1_10;
		shiftMultiply1_11;
		shiftMultiply1_12;
		shiftMultiply1_13;
		shiftMultiply1_14;
		shiftMultiply1_15;
		shiftMultiply1_16;
		shiftMultiply1_17;
		shiftMultiply1_18;
		shiftMultiply1_19;
		shiftMultiply1_20;
		shiftMultiply1_21;
		shiftMultiply1_22;
		shiftMultiply1_23;
		shiftMultiply1_24;
		shiftMultiply1_25;
		shiftMultiply1_26;
		shiftMultiply1_27;
		shiftMultiply1_28;
		shiftMultiply1_29;
		shiftMultiply1_30;
		shiftMultiply1_31;
	}
	const entries = {
		0: shiftMultiply1_0();
		1: shiftMultiply1_1();
		2: shiftMultiply1_2();
		3: shiftMultiply1_3();
		4: shiftMultiply1_4();
		5: shiftMultiply1_5();
		6: shiftMultiply1_6();
		7: shiftMultiply1_7();
		8: shiftMultiply1_8();
		9: shiftMultiply1_9();
		10: shiftMultiply1_10();
		11: shiftMultiply1_11();
		12: shiftMultiply1_12();
		13: shiftMultiply1_13();
		14: shiftMultiply1_14();
		15: shiftMultiply1_15();
		16: shiftMultiply1_16();
		17: shiftMultiply1_17();
		18: shiftMultiply1_18();
		19: shiftMultiply1_19();
		20: shiftMultiply1_20();
		21: shiftMultiply1_21();
		22: shiftMultiply1_22();
		23: shiftMultiply1_23();
		24: shiftMultiply1_24();
		25: shiftMultiply1_25();
		26: shiftMultiply1_26();
		27: shiftMultiply1_27();
		28: shiftMultiply1_28();
		29: shiftMultiply1_29();
		30: shiftMultiply1_30();
		31: shiftMultiply1_31();
	}
}

action shiftMultiply2_0() {
	meta.multAddValue = hdr.calculation.reg1 << 0;
}

action shiftMultiply2_1() {
	meta.multAddValue = hdr.calculation.reg1 << 1;
}

action shiftMultiply2_2() {
	meta.multAddValue = hdr.calculation.reg1 << 2;
}

action shiftMultiply2_3() {
	meta.multAddValue = hdr.calculation.reg1 << 3;
}

action shiftMultiply2_4() {
	meta.multAddValue = hdr.calculation.reg1 << 4;
}

action shiftMultiply2_5() {
	meta.multAddValue = hdr.calculation.reg1 << 5;
}

action shiftMultiply2_6() {
	meta.multAddValue = hdr.calculation.reg1 << 6;
}

action shiftMultiply2_7() {
	meta.multAddValue = hdr.calculation.reg1 << 7;
}

action shiftMultiply2_8() {
	meta.multAddValue = hdr.calculation.reg1 << 8;
}

action shiftMultiply2_9() {
	meta.multAddValue = hdr.calculation.reg1 << 9;
}

action shiftMultiply2_10() {
	meta.multAddValue = hdr.calculation.reg1 << 10;
}

action shiftMultiply2_11() {
	meta.multAddValue = hdr.calculation.reg1 << 11;
}

action shiftMultiply2_12() {
	meta.multAddValue = hdr.calculation.reg1 << 12;
}

action shiftMultiply2_13() {
	meta.multAddValue = hdr.calculation.reg1 << 13;
}

action shiftMultiply2_14() {
	meta.multAddValue = hdr.calculation.reg1 << 14;
}

action shiftMultiply2_15() {
	meta.multAddValue = hdr.calculation.reg1 << 15;
}

action shiftMultiply2_16() {
	meta.multAddValue = hdr.calculation.reg1 << 16;
}

action shiftMultiply2_17() {
	meta.multAddValue = hdr.calculation.reg1 << 17;
}

action shiftMultiply2_18() {
	meta.multAddValue = hdr.calculation.reg1 << 18;
}

action shiftMultiply2_19() {
	meta.multAddValue = hdr.calculation.reg1 << 19;
}

action shiftMultiply2_20() {
	meta.multAddValue = hdr.calculation.reg1 << 20;
}

action shiftMultiply2_21() {
	meta.multAddValue = hdr.calculation.reg1 << 21;
}

action shiftMultiply2_22() {
	meta.multAddValue = hdr.calculation.reg1 << 22;
}

action shiftMultiply2_23() {
	meta.multAddValue = hdr.calculation.reg1 << 23;
}

action shiftMultiply2_24() {
	meta.multAddValue = hdr.calculation.reg1 << 24;
}

action shiftMultiply2_25() {
	meta.multAddValue = hdr.calculation.reg1 << 25;
}

action shiftMultiply2_26() {
	meta.multAddValue = hdr.calculation.reg1 << 26;
}

action shiftMultiply2_27() {
	meta.multAddValue = hdr.calculation.reg1 << 27;
}

action shiftMultiply2_28() {
	meta.multAddValue = hdr.calculation.reg1 << 28;
}

action shiftMultiply2_29() {
	meta.multAddValue = hdr.calculation.reg1 << 29;
}

action shiftMultiply2_30() {
	meta.multAddValue = hdr.calculation.reg1 << 30;
}

action shiftMultiply2_31() {
	meta.multAddValue = hdr.calculation.reg1 << 31;
}

table shiftMultiply2_Table {
	key = {
		hdr.calculation.multBit : exact;
	}
	actions = {
		shiftMultiply2_0;
		shiftMultiply2_1;
		shiftMultiply2_2;
		shiftMultiply2_3;
		shiftMultiply2_4;
		shiftMultiply2_5;
		shiftMultiply2_6;
		shiftMultiply2_7;
		shiftMultiply2_8;
		shiftMultiply2_9;
		shiftMultiply2_10;
		shiftMultiply2_11;
		shiftMultiply2_12;
		shiftMultiply2_13;
		shiftMultiply2_14;
		shiftMultiply2_15;
		shiftMultiply2_16;
		shiftMultiply2_17;
		shiftMultiply2_18;
		shiftMultiply2_19;
		shiftMultiply2_20;
		shiftMultiply2_21;
		shiftMultiply2_22;
		shiftMultiply2_23;
		shiftMultiply2_24;
		shiftMultiply2_25;
		shiftMultiply2_26;
		shiftMultiply2_27;
		shiftMultiply2_28;
		shiftMultiply2_29;
		shiftMultiply2_30;
		shiftMultiply2_31;
	}
	const entries = {
		0: shiftMultiply2_0();
		1: shiftMultiply2_1();
		2: shiftMultiply2_2();
		3: shiftMultiply2_3();
		4: shiftMultiply2_4();
		5: shiftMultiply2_5();
		6: shiftMultiply2_6();
		7: shiftMultiply2_7();
		8: shiftMultiply2_8();
		9: shiftMultiply2_9();
		10: shiftMultiply2_10();
		11: shiftMultiply2_11();
		12: shiftMultiply2_12();
		13: shiftMultiply2_13();
		14: shiftMultiply2_14();
		15: shiftMultiply2_15();
		16: shiftMultiply2_16();
		17: shiftMultiply2_17();
		18: shiftMultiply2_18();
		19: shiftMultiply2_19();
		20: shiftMultiply2_20();
		21: shiftMultiply2_21();
		22: shiftMultiply2_22();
		23: shiftMultiply2_23();
		24: shiftMultiply2_24();
		25: shiftMultiply2_25();
		26: shiftMultiply2_26();
		27: shiftMultiply2_27();
		28: shiftMultiply2_28();
		29: shiftMultiply2_29();
		30: shiftMultiply2_30();
		31: shiftMultiply2_31();
	}
}
action shiftMultiply3_0() {
	meta.multAddValue = hdr.calculation.reg1 << 0;
}

action shiftMultiply3_1() {
	meta.multAddValue = hdr.calculation.reg1 << 1;
}

action shiftMultiply3_2() {
	meta.multAddValue = hdr.calculation.reg1 << 2;
}

action shiftMultiply3_3() {
	meta.multAddValue = hdr.calculation.reg1 << 3;
}

action shiftMultiply3_4() {
	meta.multAddValue = hdr.calculation.reg1 << 4;
}

action shiftMultiply3_5() {
	meta.multAddValue = hdr.calculation.reg1 << 5;
}

action shiftMultiply3_6() {
	meta.multAddValue = hdr.calculation.reg1 << 6;
}

action shiftMultiply3_7() {
	meta.multAddValue = hdr.calculation.reg1 << 7;
}

action shiftMultiply3_8() {
	meta.multAddValue = hdr.calculation.reg1 << 8;
}

action shiftMultiply3_9() {
	meta.multAddValue = hdr.calculation.reg1 << 9;
}

action shiftMultiply3_10() {
	meta.multAddValue = hdr.calculation.reg1 << 10;
}

action shiftMultiply3_11() {
	meta.multAddValue = hdr.calculation.reg1 << 11;
}

action shiftMultiply3_12() {
	meta.multAddValue = hdr.calculation.reg1 << 12;
}

action shiftMultiply3_13() {
	meta.multAddValue = hdr.calculation.reg1 << 13;
}

action shiftMultiply3_14() {
	meta.multAddValue = hdr.calculation.reg1 << 14;
}

action shiftMultiply3_15() {
	meta.multAddValue = hdr.calculation.reg1 << 15;
}

action shiftMultiply3_16() {
	meta.multAddValue = hdr.calculation.reg1 << 16;
}

action shiftMultiply3_17() {
	meta.multAddValue = hdr.calculation.reg1 << 17;
}

action shiftMultiply3_18() {
	meta.multAddValue = hdr.calculation.reg1 << 18;
}

action shiftMultiply3_19() {
	meta.multAddValue = hdr.calculation.reg1 << 19;
}

action shiftMultiply3_20() {
	meta.multAddValue = hdr.calculation.reg1 << 20;
}

action shiftMultiply3_21() {
	meta.multAddValue = hdr.calculation.reg1 << 21;
}

action shiftMultiply3_22() {
	meta.multAddValue = hdr.calculation.reg1 << 22;
}

action shiftMultiply3_23() {
	meta.multAddValue = hdr.calculation.reg1 << 23;
}

action shiftMultiply3_24() {
	meta.multAddValue = hdr.calculation.reg1 << 24;
}

action shiftMultiply3_25() {
	meta.multAddValue = hdr.calculation.reg1 << 25;
}

action shiftMultiply3_26() {
	meta.multAddValue = hdr.calculation.reg1 << 26;
}

action shiftMultiply3_27() {
	meta.multAddValue = hdr.calculation.reg1 << 27;
}

action shiftMultiply3_28() {
	meta.multAddValue = hdr.calculation.reg1 << 28;
}

action shiftMultiply3_29() {
	meta.multAddValue = hdr.calculation.reg1 << 29;
}

action shiftMultiply3_30() {
	meta.multAddValue = hdr.calculation.reg1 << 30;
}

action shiftMultiply3_31() {
	meta.multAddValue = hdr.calculation.reg1 << 31;
}

table shiftMultiply3_Table {
	key = {
		hdr.calculation.multBit : exact;
	}
	actions = {
		shiftMultiply3_0;
		shiftMultiply3_1;
		shiftMultiply3_2;
		shiftMultiply3_3;
		shiftMultiply3_4;
		shiftMultiply3_5;
		shiftMultiply3_6;
		shiftMultiply3_7;
		shiftMultiply3_8;
		shiftMultiply3_9;
		shiftMultiply3_10;
		shiftMultiply3_11;
		shiftMultiply3_12;
		shiftMultiply3_13;
		shiftMultiply3_14;
		shiftMultiply3_15;
		shiftMultiply3_16;
		shiftMultiply3_17;
		shiftMultiply3_18;
		shiftMultiply3_19;
		shiftMultiply3_20;
		shiftMultiply3_21;
		shiftMultiply3_22;
		shiftMultiply3_23;
		shiftMultiply3_24;
		shiftMultiply3_25;
		shiftMultiply3_26;
		shiftMultiply3_27;
		shiftMultiply3_28;
		shiftMultiply3_29;
		shiftMultiply3_30;
		shiftMultiply3_31;
	}
	const entries = {
		0: shiftMultiply3_0();
		1: shiftMultiply3_1();
		2: shiftMultiply3_2();
		3: shiftMultiply3_3();
		4: shiftMultiply3_4();
		5: shiftMultiply3_5();
		6: shiftMultiply3_6();
		7: shiftMultiply3_7();
		8: shiftMultiply3_8();
		9: shiftMultiply3_9();
		10: shiftMultiply3_10();
		11: shiftMultiply3_11();
		12: shiftMultiply3_12();
		13: shiftMultiply3_13();
		14: shiftMultiply3_14();
		15: shiftMultiply3_15();
		16: shiftMultiply3_16();
		17: shiftMultiply3_17();
		18: shiftMultiply3_18();
		19: shiftMultiply3_19();
		20: shiftMultiply3_20();
		21: shiftMultiply3_21();
		22: shiftMultiply3_22();
		23: shiftMultiply3_23();
		24: shiftMultiply3_24();
		25: shiftMultiply3_25();
		26: shiftMultiply3_26();
		27: shiftMultiply3_27();
		28: shiftMultiply3_28();
		29: shiftMultiply3_29();
		30: shiftMultiply3_30();
		31: shiftMultiply3_31();
	}
}
action shiftMultiply4_0() {
	meta.multAddValue = hdr.calculation.reg1 << 0;
}

action shiftMultiply4_1() {
	meta.multAddValue = hdr.calculation.reg1 << 1;
}

action shiftMultiply4_2() {
	meta.multAddValue = hdr.calculation.reg1 << 2;
}

action shiftMultiply4_3() {
	meta.multAddValue = hdr.calculation.reg1 << 3;
}

action shiftMultiply4_4() {
	meta.multAddValue = hdr.calculation.reg1 << 4;
}

action shiftMultiply4_5() {
	meta.multAddValue = hdr.calculation.reg1 << 5;
}

action shiftMultiply4_6() {
	meta.multAddValue = hdr.calculation.reg1 << 6;
}

action shiftMultiply4_7() {
	meta.multAddValue = hdr.calculation.reg1 << 7;
}

action shiftMultiply4_8() {
	meta.multAddValue = hdr.calculation.reg1 << 8;
}

action shiftMultiply4_9() {
	meta.multAddValue = hdr.calculation.reg1 << 9;
}

action shiftMultiply4_10() {
	meta.multAddValue = hdr.calculation.reg1 << 10;
}

action shiftMultiply4_11() {
	meta.multAddValue = hdr.calculation.reg1 << 11;
}

action shiftMultiply4_12() {
	meta.multAddValue = hdr.calculation.reg1 << 12;
}

action shiftMultiply4_13() {
	meta.multAddValue = hdr.calculation.reg1 << 13;
}

action shiftMultiply4_14() {
	meta.multAddValue = hdr.calculation.reg1 << 14;
}

action shiftMultiply4_15() {
	meta.multAddValue = hdr.calculation.reg1 << 15;
}

action shiftMultiply4_16() {
	meta.multAddValue = hdr.calculation.reg1 << 16;
}

action shiftMultiply4_17() {
	meta.multAddValue = hdr.calculation.reg1 << 17;
}

action shiftMultiply4_18() {
	meta.multAddValue = hdr.calculation.reg1 << 18;
}

action shiftMultiply4_19() {
	meta.multAddValue = hdr.calculation.reg1 << 19;
}

action shiftMultiply4_20() {
	meta.multAddValue = hdr.calculation.reg1 << 20;
}

action shiftMultiply4_21() {
	meta.multAddValue = hdr.calculation.reg1 << 21;
}

action shiftMultiply4_22() {
	meta.multAddValue = hdr.calculation.reg1 << 22;
}

action shiftMultiply4_23() {
	meta.multAddValue = hdr.calculation.reg1 << 23;
}

action shiftMultiply4_24() {
	meta.multAddValue = hdr.calculation.reg1 << 24;
}

action shiftMultiply4_25() {
	meta.multAddValue = hdr.calculation.reg1 << 25;
}

action shiftMultiply4_26() {
	meta.multAddValue = hdr.calculation.reg1 << 26;
}

action shiftMultiply4_27() {
	meta.multAddValue = hdr.calculation.reg1 << 27;
}

action shiftMultiply4_28() {
	meta.multAddValue = hdr.calculation.reg1 << 28;
}

action shiftMultiply4_29() {
	meta.multAddValue = hdr.calculation.reg1 << 29;
}

action shiftMultiply4_30() {
	meta.multAddValue = hdr.calculation.reg1 << 30;
}

action shiftMultiply4_31() {
	meta.multAddValue = hdr.calculation.reg1 << 31;
}

table shiftMultiply4_Table {
	key = {
		hdr.calculation.multBit : exact;
	}
	actions = {
		shiftMultiply4_0;
		shiftMultiply4_1;
		shiftMultiply4_2;
		shiftMultiply4_3;
		shiftMultiply4_4;
		shiftMultiply4_5;
		shiftMultiply4_6;
		shiftMultiply4_7;
		shiftMultiply4_8;
		shiftMultiply4_9;
		shiftMultiply4_10;
		shiftMultiply4_11;
		shiftMultiply4_12;
		shiftMultiply4_13;
		shiftMultiply4_14;
		shiftMultiply4_15;
		shiftMultiply4_16;
		shiftMultiply4_17;
		shiftMultiply4_18;
		shiftMultiply4_19;
		shiftMultiply4_20;
		shiftMultiply4_21;
		shiftMultiply4_22;
		shiftMultiply4_23;
		shiftMultiply4_24;
		shiftMultiply4_25;
		shiftMultiply4_26;
		shiftMultiply4_27;
		shiftMultiply4_28;
		shiftMultiply4_29;
		shiftMultiply4_30;
		shiftMultiply4_31;
	}
	const entries = {
		0: shiftMultiply4_0();
		1: shiftMultiply4_1();
		2: shiftMultiply4_2();
		3: shiftMultiply4_3();
		4: shiftMultiply4_4();
		5: shiftMultiply4_5();
		6: shiftMultiply4_6();
		7: shiftMultiply4_7();
		8: shiftMultiply4_8();
		9: shiftMultiply4_9();
		10: shiftMultiply4_10();
		11: shiftMultiply4_11();
		12: shiftMultiply4_12();
		13: shiftMultiply4_13();
		14: shiftMultiply4_14();
		15: shiftMultiply4_15();
		16: shiftMultiply4_16();
		17: shiftMultiply4_17();
		18: shiftMultiply4_18();
		19: shiftMultiply4_19();
		20: shiftMultiply4_20();
		21: shiftMultiply4_21();
		22: shiftMultiply4_22();
		23: shiftMultiply4_23();
		24: shiftMultiply4_24();
		25: shiftMultiply4_25();
		26: shiftMultiply4_26();
		27: shiftMultiply4_27();
		28: shiftMultiply4_28();
		29: shiftMultiply4_29();
		30: shiftMultiply4_30();
		31: shiftMultiply4_31();
	}
}
action shiftMultiply5_0() {
	meta.multAddValue = hdr.calculation.reg1 << 0;
}

action shiftMultiply5_1() {
	meta.multAddValue = hdr.calculation.reg1 << 1;
}

action shiftMultiply5_2() {
	meta.multAddValue = hdr.calculation.reg1 << 2;
}

action shiftMultiply5_3() {
	meta.multAddValue = hdr.calculation.reg1 << 3;
}

action shiftMultiply5_4() {
	meta.multAddValue = hdr.calculation.reg1 << 4;
}

action shiftMultiply5_5() {
	meta.multAddValue = hdr.calculation.reg1 << 5;
}

action shiftMultiply5_6() {
	meta.multAddValue = hdr.calculation.reg1 << 6;
}

action shiftMultiply5_7() {
	meta.multAddValue = hdr.calculation.reg1 << 7;
}

action shiftMultiply5_8() {
	meta.multAddValue = hdr.calculation.reg1 << 8;
}

action shiftMultiply5_9() {
	meta.multAddValue = hdr.calculation.reg1 << 9;
}

action shiftMultiply5_10() {
	meta.multAddValue = hdr.calculation.reg1 << 10;
}

action shiftMultiply5_11() {
	meta.multAddValue = hdr.calculation.reg1 << 11;
}

action shiftMultiply5_12() {
	meta.multAddValue = hdr.calculation.reg1 << 12;
}

action shiftMultiply5_13() {
	meta.multAddValue = hdr.calculation.reg1 << 13;
}

action shiftMultiply5_14() {
	meta.multAddValue = hdr.calculation.reg1 << 14;
}

action shiftMultiply5_15() {
	meta.multAddValue = hdr.calculation.reg1 << 15;
}

action shiftMultiply5_16() {
	meta.multAddValue = hdr.calculation.reg1 << 16;
}

action shiftMultiply5_17() {
	meta.multAddValue = hdr.calculation.reg1 << 17;
}

action shiftMultiply5_18() {
	meta.multAddValue = hdr.calculation.reg1 << 18;
}

action shiftMultiply5_19() {
	meta.multAddValue = hdr.calculation.reg1 << 19;
}

action shiftMultiply5_20() {
	meta.multAddValue = hdr.calculation.reg1 << 20;
}

action shiftMultiply5_21() {
	meta.multAddValue = hdr.calculation.reg1 << 21;
}

action shiftMultiply5_22() {
	meta.multAddValue = hdr.calculation.reg1 << 22;
}

action shiftMultiply5_23() {
	meta.multAddValue = hdr.calculation.reg1 << 23;
}

action shiftMultiply5_24() {
	meta.multAddValue = hdr.calculation.reg1 << 24;
}

action shiftMultiply5_25() {
	meta.multAddValue = hdr.calculation.reg1 << 25;
}

action shiftMultiply5_26() {
	meta.multAddValue = hdr.calculation.reg1 << 26;
}

action shiftMultiply5_27() {
	meta.multAddValue = hdr.calculation.reg1 << 27;
}

action shiftMultiply5_28() {
	meta.multAddValue = hdr.calculation.reg1 << 28;
}

action shiftMultiply5_29() {
	meta.multAddValue = hdr.calculation.reg1 << 29;
}

action shiftMultiply5_30() {
	meta.multAddValue = hdr.calculation.reg1 << 30;
}

action shiftMultiply5_31() {
	meta.multAddValue = hdr.calculation.reg1 << 31;
}

table shiftMultiply5_Table {
	key = {
		hdr.calculation.multBit : exact;
	}
	actions = {
		shiftMultiply5_0;
		shiftMultiply5_1;
		shiftMultiply5_2;
		shiftMultiply5_3;
		shiftMultiply5_4;
		shiftMultiply5_5;
		shiftMultiply5_6;
		shiftMultiply5_7;
		shiftMultiply5_8;
		shiftMultiply5_9;
		shiftMultiply5_10;
		shiftMultiply5_11;
		shiftMultiply5_12;
		shiftMultiply5_13;
		shiftMultiply5_14;
		shiftMultiply5_15;
		shiftMultiply5_16;
		shiftMultiply5_17;
		shiftMultiply5_18;
		shiftMultiply5_19;
		shiftMultiply5_20;
		shiftMultiply5_21;
		shiftMultiply5_22;
		shiftMultiply5_23;
		shiftMultiply5_24;
		shiftMultiply5_25;
		shiftMultiply5_26;
		shiftMultiply5_27;
		shiftMultiply5_28;
		shiftMultiply5_29;
		shiftMultiply5_30;
		shiftMultiply5_31;
	}
	const entries = {
		0: shiftMultiply5_0();
		1: shiftMultiply5_1();
		2: shiftMultiply5_2();
		3: shiftMultiply5_3();
		4: shiftMultiply5_4();
		5: shiftMultiply5_5();
		6: shiftMultiply5_6();
		7: shiftMultiply5_7();
		8: shiftMultiply5_8();
		9: shiftMultiply5_9();
		10: shiftMultiply5_10();
		11: shiftMultiply5_11();
		12: shiftMultiply5_12();
		13: shiftMultiply5_13();
		14: shiftMultiply5_14();
		15: shiftMultiply5_15();
		16: shiftMultiply5_16();
		17: shiftMultiply5_17();
		18: shiftMultiply5_18();
		19: shiftMultiply5_19();
		20: shiftMultiply5_20();
		21: shiftMultiply5_21();
		22: shiftMultiply5_22();
		23: shiftMultiply5_23();
		24: shiftMultiply5_24();
		25: shiftMultiply5_25();
		26: shiftMultiply5_26();
		27: shiftMultiply5_27();
		28: shiftMultiply5_28();
		29: shiftMultiply5_29();
		30: shiftMultiply5_30();
		31: shiftMultiply5_31();
	}
}
action shiftMultiply6_0() {
	meta.multAddValue = hdr.calculation.reg1 << 0;
}

action shiftMultiply6_1() {
	meta.multAddValue = hdr.calculation.reg1 << 1;
}

action shiftMultiply6_2() {
	meta.multAddValue = hdr.calculation.reg1 << 2;
}

action shiftMultiply6_3() {
	meta.multAddValue = hdr.calculation.reg1 << 3;
}

action shiftMultiply6_4() {
	meta.multAddValue = hdr.calculation.reg1 << 4;
}

action shiftMultiply6_5() {
	meta.multAddValue = hdr.calculation.reg1 << 5;
}

action shiftMultiply6_6() {
	meta.multAddValue = hdr.calculation.reg1 << 6;
}

action shiftMultiply6_7() {
	meta.multAddValue = hdr.calculation.reg1 << 7;
}

action shiftMultiply6_8() {
	meta.multAddValue = hdr.calculation.reg1 << 8;
}

action shiftMultiply6_9() {
	meta.multAddValue = hdr.calculation.reg1 << 9;
}

action shiftMultiply6_10() {
	meta.multAddValue = hdr.calculation.reg1 << 10;
}

action shiftMultiply6_11() {
	meta.multAddValue = hdr.calculation.reg1 << 11;
}

action shiftMultiply6_12() {
	meta.multAddValue = hdr.calculation.reg1 << 12;
}

action shiftMultiply6_13() {
	meta.multAddValue = hdr.calculation.reg1 << 13;
}

action shiftMultiply6_14() {
	meta.multAddValue = hdr.calculation.reg1 << 14;
}

action shiftMultiply6_15() {
	meta.multAddValue = hdr.calculation.reg1 << 15;
}

action shiftMultiply6_16() {
	meta.multAddValue = hdr.calculation.reg1 << 16;
}

action shiftMultiply6_17() {
	meta.multAddValue = hdr.calculation.reg1 << 17;
}

action shiftMultiply6_18() {
	meta.multAddValue = hdr.calculation.reg1 << 18;
}

action shiftMultiply6_19() {
	meta.multAddValue = hdr.calculation.reg1 << 19;
}

action shiftMultiply6_20() {
	meta.multAddValue = hdr.calculation.reg1 << 20;
}

action shiftMultiply6_21() {
	meta.multAddValue = hdr.calculation.reg1 << 21;
}

action shiftMultiply6_22() {
	meta.multAddValue = hdr.calculation.reg1 << 22;
}

action shiftMultiply6_23() {
	meta.multAddValue = hdr.calculation.reg1 << 23;
}

action shiftMultiply6_24() {
	meta.multAddValue = hdr.calculation.reg1 << 24;
}

action shiftMultiply6_25() {
	meta.multAddValue = hdr.calculation.reg1 << 25;
}

action shiftMultiply6_26() {
	meta.multAddValue = hdr.calculation.reg1 << 26;
}

action shiftMultiply6_27() {
	meta.multAddValue = hdr.calculation.reg1 << 27;
}

action shiftMultiply6_28() {
	meta.multAddValue = hdr.calculation.reg1 << 28;
}

action shiftMultiply6_29() {
	meta.multAddValue = hdr.calculation.reg1 << 29;
}

action shiftMultiply6_30() {
	meta.multAddValue = hdr.calculation.reg1 << 30;
}

action shiftMultiply6_31() {
	meta.multAddValue = hdr.calculation.reg1 << 31;
}

table shiftMultiply6_Table {
	key = {
		hdr.calculation.multBit : exact;
	}
	actions = {
		shiftMultiply6_0;
		shiftMultiply6_1;
		shiftMultiply6_2;
		shiftMultiply6_3;
		shiftMultiply6_4;
		shiftMultiply6_5;
		shiftMultiply6_6;
		shiftMultiply6_7;
		shiftMultiply6_8;
		shiftMultiply6_9;
		shiftMultiply6_10;
		shiftMultiply6_11;
		shiftMultiply6_12;
		shiftMultiply6_13;
		shiftMultiply6_14;
		shiftMultiply6_15;
		shiftMultiply6_16;
		shiftMultiply6_17;
		shiftMultiply6_18;
		shiftMultiply6_19;
		shiftMultiply6_20;
		shiftMultiply6_21;
		shiftMultiply6_22;
		shiftMultiply6_23;
		shiftMultiply6_24;
		shiftMultiply6_25;
		shiftMultiply6_26;
		shiftMultiply6_27;
		shiftMultiply6_28;
		shiftMultiply6_29;
		shiftMultiply6_30;
		shiftMultiply6_31;
	}
	const entries = {
		0: shiftMultiply6_0();
		1: shiftMultiply6_1();
		2: shiftMultiply6_2();
		3: shiftMultiply6_3();
		4: shiftMultiply6_4();
		5: shiftMultiply6_5();
		6: shiftMultiply6_6();
		7: shiftMultiply6_7();
		8: shiftMultiply6_8();
		9: shiftMultiply6_9();
		10: shiftMultiply6_10();
		11: shiftMultiply6_11();
		12: shiftMultiply6_12();
		13: shiftMultiply6_13();
		14: shiftMultiply6_14();
		15: shiftMultiply6_15();
		16: shiftMultiply6_16();
		17: shiftMultiply6_17();
		18: shiftMultiply6_18();
		19: shiftMultiply6_19();
		20: shiftMultiply6_20();
		21: shiftMultiply6_21();
		22: shiftMultiply6_22();
		23: shiftMultiply6_23();
		24: shiftMultiply6_24();
		25: shiftMultiply6_25();
		26: shiftMultiply6_26();
		27: shiftMultiply6_27();
		28: shiftMultiply6_28();
		29: shiftMultiply6_29();
		30: shiftMultiply6_30();
		31: shiftMultiply6_31();
	}
}
