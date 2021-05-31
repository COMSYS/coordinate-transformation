/*
    Coordinate Transformation
    Copyright (c) 2021 
	
	Authors: Ike Kunze, René Glebke, Jan Scheiper
	E-mail: inp@comsys.rwth-aachen.de
*/

#include "include/multipipe_shared.p4"
#include "transform_spherical_fastmp_split_multipipe_multiply.p4"

/*************************************************************************
 **************  I N G R E S S   P R O C E S S I N G   *******************
 *************************************************************************/

    /***********************  P A R S E R  **************************/
parser IngressParser(packet_in        pkt,
    /* User */    
    out my_ingress_headers_t          hdr,
    out my_ingress_metadata_t         meta,
    /* Intrinsic */
    out ingress_intrinsic_metadata_t  ig_intr_md)
{
    state start {
        pkt.extract(ig_intr_md);
        pkt.advance(PORT_METADATA_SIZE);

        meta.negFlag = 0;
        meta.reg1neg = 0;
        meta.reg2neg = 0;

        transition parse_ethernet;
    }

    state parse_ethernet {
        pkt.extract(hdr.ethernet);
        transition select(hdr.ethernet.ether_type) {
            ETHERTYPE_IPV4:  parse_ipv4;
            default: accept;
        }
    }

    state parse_ipv4 {
        pkt.extract(hdr.ipv4);
        transition select(hdr.ipv4.protocol) {
            PROTOCOL_UDP:  parse_udp;
            default: accept;
        }
    }

    state parse_udp {
        pkt.extract(hdr.udp);
        transition select(hdr.udp.dport) {
            NORMAL_PORT: parse_recirc;
            TIMING_PORT: parse_timing;
            default: accept;
        }
    }

    state parse_timing {
        pkt.extract(hdr.timing);
        transition parse_recirc;
    }

    state parse_recirc {
        pkt.extract(hdr.recirculate);
        transition parse_payload;
    }

    state parse_payload {
        pkt.extract(hdr.spherical);

        transition select(ig_intr_md.ingress_port[7:0]) {
            RECIRC_PORT_MAIN: parse_calculation;
            RECIRC_PORT_MULTIPLY: parse_calculation;
            default: enable_calculation;
        }
    }

    state parse_calculation {
        pkt.extract(hdr.calculation);

        transition accept;
    }

    state enable_calculation {
        hdr.calculation.setValid();

        transition accept;
    }
}

    /***************** M A T C H - A C T I O N  *********************/

control Ingress(
    /* User */
    inout my_ingress_headers_t                       hdr,
    inout my_ingress_metadata_t                      meta,
    /* Intrinsic */
    in    ingress_intrinsic_metadata_t               ig_intr_md,
    in    ingress_intrinsic_metadata_from_parser_t   ig_prsr_md,
    inout ingress_intrinsic_metadata_for_deparser_t  ig_dprsr_md,
    inout ingress_intrinsic_metadata_for_tm_t        ig_tm_md)
{
    // TABLE ACTIONS

    action trigLowerPosPos(int<32> sin, int<32> cos) {
        hdr.calculation.sinLower = sin;
        hdr.calculation.cosLower = cos;
    }
	
    action trigLowerNegPos(int<32> sin, int<32> cos) {
        hdr.calculation.sinLower = sin;
        hdr.calculation.cosLower = cos;
        meta.negFlag = meta.negFlag + 1;
    }

    action trigLowerPosNeg(int<32> sin, int<32> cos) {
        hdr.calculation.sinLower = sin;
        hdr.calculation.cosLower = cos;
        meta.negFlag = meta.negFlag + 2;
    }

    action trigLowerNegNeg(int<32> sin, int<32> cos) {
        hdr.calculation.sinLower = sin;
        hdr.calculation.cosLower = cos;
        meta.negFlag = meta.negFlag + 3;
    }

    action trigUpperPosPos(int<32> sin, int<32> cos) {
        hdr.calculation.sinUpper = sin;
        hdr.calculation.cosUpper = cos;
    }
	
    action trigUpperNegPos(int<32> sin, int<32> cos) {
        hdr.calculation.sinUpper = sin;
        hdr.calculation.cosUpper = cos;
        meta.negFlag = meta.negFlag + 4;
    }

    action trigUpperPosNeg(int<32> sin, int<32> cos) {
        hdr.calculation.sinUpper = sin;
        hdr.calculation.cosUpper = cos;
        meta.negFlag = meta.negFlag + 8;
    }

    action trigUpperNegNeg(int<32> sin, int<32> cos) {
        hdr.calculation.sinUpper = sin;
        hdr.calculation.cosUpper = cos;
        meta.negFlag = meta.negFlag + 12;
    }

    action getMatrixRowPPP(int<32> col1, int<32> col2, int<32> col3) {
        ALIAS_matrixcol1 = col1;
        ALIAS_matrixcol2 = col2;
        ALIAS_matrixcol3 = col3;
        meta.negFlag = 0;
    }

    action getMatrixRowPPN(int<32> col1, int<32> col2, int<32> col3) {
        ALIAS_matrixcol1 = col1;
        ALIAS_matrixcol2 = col2;
        ALIAS_matrixcol3 = col3;
        meta.negFlag = 4;
    }

    action getMatrixRowPNP(int<32> col1, int<32> col2, int<32> col3) {
        ALIAS_matrixcol1 = col1;
        ALIAS_matrixcol2 = col2;
        ALIAS_matrixcol3 = col3;
        meta.negFlag = 2;
    }

    action getMatrixRowPNN(int<32> col1, int<32> col2, int<32> col3) {
        ALIAS_matrixcol1 = col1;
        ALIAS_matrixcol2 = col2;
        ALIAS_matrixcol3 = col3;
        meta.negFlag = 6;
    }

    action getMatrixRowNPP(int<32> col1, int<32> col2, int<32> col3) {
        ALIAS_matrixcol1 = col1;
        ALIAS_matrixcol2 = col2;
        ALIAS_matrixcol3 = col3;
        meta.negFlag = 1;
    }

    action getMatrixRowNPN(int<32> col1, int<32> col2, int<32> col3) {
        ALIAS_matrixcol1 = col1;
        ALIAS_matrixcol2 = col2;
        ALIAS_matrixcol3 = col3;
        meta.negFlag = 5;
    }

    action getMatrixRowNNP(int<32> col1, int<32> col2, int<32> col3) {
        ALIAS_matrixcol1 = col1;
        ALIAS_matrixcol2 = col2;
        ALIAS_matrixcol3 = col3;
        meta.negFlag = 3;
    }

    action getMatrixRowNNN(int<32> col1, int<32> col2, int<32> col3) {
        ALIAS_matrixcol1 = col1;
        ALIAS_matrixcol2 = col2;
        ALIAS_matrixcol3 = col3;
        meta.negFlag = 7;
    }

    // COMPUTATION ACTIONS

    action calculateCartesian1_setup() {
        hdr.calculation.reg1 = (bit<32>)hdr.calculation.sinUpper;
        hdr.calculation.reg2 = (bit<32>)hdr.calculation.cosLower;
    }

    action calculateCartesian1_finalize() {
        hdr.spherical.x = hdr.calculation.multResult >> (FIX_POINT_EXPONENT - 24);
    }

    action calculateCartesian2_setup() {
        hdr.calculation.reg1 = (bit<32>)hdr.calculation.cosUpper;
        hdr.calculation.reg2 = (bit<32>)hdr.calculation.sinLower;
    }

    action calculateCartesian2_finalize() {
        hdr.calculation.sinPhi = hdr.calculation.multResult >> (FIX_POINT_EXPONENT - 24);
    }

    action calculateCartesian3_setup() {
        hdr.calculation.sinPhi = hdr.calculation.sinPhi + hdr.spherical.x;

        hdr.calculation.reg1 = (bit<32>)hdr.calculation.cosUpper;
        hdr.calculation.reg2 = (bit<32>)hdr.calculation.cosLower;
    }

    action calculateCartesian3_finalize() {
        hdr.spherical.x = hdr.calculation.multResult >> (FIX_POINT_EXPONENT - 24);
    }

    action calculateCartesian4_setup() {
        hdr.calculation.reg1 = (bit<32>)hdr.calculation.sinUpper;
        hdr.calculation.reg2 = (bit<32>)hdr.calculation.sinLower;
    }

    action calculateCartesian4_finalize() {
        hdr.calculation.cosPhi = hdr.calculation.multResult >> (FIX_POINT_EXPONENT - 24);
    }

    action calculateCartesian5_setup() {
        hdr.calculation.cosPhi = hdr.spherical.x - hdr.calculation.cosPhi;

        hdr.calculation.reg1 = (bit<32>)hdr.calculation.sinUpper;
        hdr.calculation.reg2 = (bit<32>)hdr.calculation.cosLower;
    }

    action calculateCartesian5_finalize() {
        hdr.spherical.x = hdr.calculation.multResult >> (FIX_POINT_EXPONENT - 24);
    }

    action calculateCartesian6_setup() {
        hdr.calculation.reg1 = (bit<32>)hdr.calculation.cosUpper;
        hdr.calculation.reg2 = (bit<32>)hdr.calculation.sinLower;
    }

    action calculateCartesian6_finalize() {
        hdr.calculation.sinTheta = hdr.calculation.multResult >> (FIX_POINT_EXPONENT - 24);
    }

    action calculateCartesian7_setup() {
        hdr.calculation.sinTheta = hdr.calculation.sinTheta + hdr.spherical.x;

        hdr.calculation.reg1 = (bit<32>)hdr.calculation.cosUpper;
        hdr.calculation.reg2 = (bit<32>)hdr.calculation.cosLower;
    }

    action calculateCartesian7_finalize() {
        hdr.spherical.x = hdr.calculation.multResult >> (FIX_POINT_EXPONENT - 24);
    }

    action calculateCartesian8_setup() {
        hdr.calculation.reg1 = (bit<32>)hdr.calculation.sinUpper;
        hdr.calculation.reg2 = (bit<32>)hdr.calculation.sinLower;
    }

    action calculateCartesian8_finalize() {
        hdr.calculation.cosTheta = hdr.calculation.multResult >> (FIX_POINT_EXPONENT - 24);
    }

    action calculateCartesian9_setup() {
        hdr.calculation.cosTheta = hdr.spherical.x - hdr.calculation.cosTheta;

        hdr.calculation.reg1 = (bit<32>)hdr.spherical.radius;
        hdr.calculation.reg2 = (bit<32>)hdr.calculation.sinTheta;
    }

    action calculateCartesian9_finalize() {
        hdr.spherical.x = hdr.calculation.multResult >> (FIX_POINT_EXPONENT - 24);
        hdr.spherical.y = hdr.calculation.multResult >> (FIX_POINT_EXPONENT - 24);
    }

    action calculateCartesian10_setup() {
        hdr.calculation.reg1 = (bit<32>)hdr.spherical.radius;
        hdr.calculation.reg2 = (bit<32>)hdr.calculation.cosTheta;
    }

    action calculateCartesian10_finalize() {
        hdr.spherical.z = hdr.calculation.multResult >> (FIX_POINT_EXPONENT - 24);
    }

    action calculateCartesian11_setup() {
        hdr.calculation.reg1 = (bit<32>)hdr.spherical.x;
        hdr.calculation.reg2 = (bit<32>)hdr.calculation.cosPhi;
    }

    action calculateCartesian11_finalize() {
        hdr.spherical.x = hdr.calculation.multResult >> (FIX_POINT_EXPONENT - 24);
    }

    action calculateCartesian12_setup() {
        hdr.calculation.reg1 = (bit<32>)hdr.spherical.y;
        hdr.calculation.reg2 = (bit<32>)hdr.calculation.sinPhi;
    }

    action calculateCartesian12_finalize() {
        hdr.spherical.y = hdr.calculation.multResult >> (FIX_POINT_EXPONENT - 24);
    }

    action calculateTransform1_setup() {
        hdr.calculation.reg1 = (bit<32>)hdr.spherical.x;
        hdr.calculation.reg2 = (bit<32>)ALIAS_matrixcol1;
    }

    action calculateTransform1_finalize() {
        ALIAS_matrixres1 = hdr.calculation.multResult >> (FIX_POINT_EXPONENT - 24);
    }

    action calculateTransform2_setup() {
        hdr.calculation.reg1 = (bit<32>)hdr.spherical.y;
        hdr.calculation.reg2 = (bit<32>)ALIAS_matrixcol2;
    }

    action calculateTransform2_finalize() {
        ALIAS_matrixacc = hdr.calculation.multResult >> (FIX_POINT_EXPONENT - 24);
    }

    action calculateTransform3_setup() {
        hdr.calculation.reg1 = (bit<32>)hdr.spherical.z;
        hdr.calculation.reg2 = (bit<32>)ALIAS_matrixcol3;
    }

    action calculateTransform3_finalize() {
        ALIAS_matrixres1 = ALIAS_matrixres1 + ALIAS_matrixacc;
        ALIAS_matrixacc2 = hdr.calculation.multResult >> (FIX_POINT_EXPONENT - 24);
    }

    action calculateTransform3_finalize2() {
        ALIAS_matrixres1 = ALIAS_matrixres1 + ALIAS_matrixacc2;
    }

    action calculateTransform4_setup() {
        hdr.calculation.reg1 = (bit<32>)hdr.spherical.x;
        hdr.calculation.reg2 = (bit<32>)ALIAS_matrixcol1;
    }

    action calculateTransform4_finalize() {
        ALIAS_matrixres2 = hdr.calculation.multResult >> (FIX_POINT_EXPONENT - 24);
    }

    action calculateTransform5_setup() {
        hdr.calculation.reg1 = (bit<32>)hdr.spherical.y;
        hdr.calculation.reg2 = (bit<32>)ALIAS_matrixcol2;
    }

    action calculateTransform5_finalize() {
        ALIAS_matrixacc = hdr.calculation.multResult >> (FIX_POINT_EXPONENT - 24);
    }

    action calculateTransform6_setup() {
        hdr.calculation.reg1 = (bit<32>)hdr.spherical.z;
        hdr.calculation.reg2 = (bit<32>)ALIAS_matrixcol3;
    }

    action calculateTransform6_finalize() {
        ALIAS_matrixres2 = ALIAS_matrixres2 + ALIAS_matrixacc;
        ALIAS_matrixacc2 = hdr.calculation.multResult >> (FIX_POINT_EXPONENT - 24);
    }

    action calculateTransform6_finalize2() {
        ALIAS_matrixres2 = ALIAS_matrixres2 + ALIAS_matrixacc2;
    }

    action calculateTransform7_setup() {
        hdr.calculation.reg1 = (bit<32>)hdr.spherical.x;
        hdr.calculation.reg2 = (bit<32>)ALIAS_matrixcol1;
    }

    action calculateTransform7_finalize() {
        ALIAS_matrixres3 = hdr.calculation.multResult >> (FIX_POINT_EXPONENT - 24);
    }

    action calculateTransform8_setup() {
        hdr.calculation.reg1 = (bit<32>)hdr.spherical.y;
        hdr.calculation.reg2 = (bit<32>)ALIAS_matrixcol2;
    }

    action calculateTransform8_finalize() {
        ALIAS_matrixacc = hdr.calculation.multResult >> (FIX_POINT_EXPONENT - 24);
    }

    action calculateTransform9_setup() {
        hdr.calculation.reg1 = (bit<32>)hdr.spherical.z;
        hdr.calculation.reg2 = (bit<32>)ALIAS_matrixcol3;
    }

    action calculateTransform9_finalize() {
        ALIAS_matrixres3 = ALIAS_matrixres3 + ALIAS_matrixacc;
        ALIAS_matrixacc2 = hdr.calculation.multResult >> (FIX_POINT_EXPONENT - 24);
    }

    action calculateTransform9_finalize2() {
        hdr.spherical.z = ALIAS_matrixres3 + ALIAS_matrixacc2;
        hdr.spherical.x = ALIAS_matrixres1;
        hdr.spherical.y = ALIAS_matrixres2;
    }

    // NETWORK RELATED ACTIONS

    action recirc(bit<16> count) {
        hdr.recirculate.count = count;
        ig_tm_md.ucast_egress_port = RECIRC_PORT_MULTIPLY; // recirculate to multiplication pipe
    }

    action recircFast(bit<16> count) {
        hdr.recirculate.count = count;
        ig_tm_md.ucast_egress_port = RECIRC_PORT_MAIN;  // recirculate to same pipe
    }

    action setRecirc(bit<16> count) {
        hdr.recirculate.count = count;
    }

    action ipv4_forward(PortId_t port){
        ig_tm_md.ucast_egress_port = port;
    }

    // CALCULATION RELATED ACTIONS

    action fix_reg1() {
        hdr.calculation.reg1 = ~hdr.calculation.reg1;
        hdr.calculation.calcNeg = 1;
        meta.reg1neg = 1;
    }
    action fix_reg2() {
        hdr.calculation.reg2 = ~hdr.calculation.reg2;
        hdr.calculation.calcNeg = 1;
        meta.reg2neg = 1;
    }
    action fix_reg1_2() {
        hdr.calculation.reg1 = ~hdr.calculation.reg1;
        hdr.calculation.reg2 = ~hdr.calculation.reg2;
        meta.reg1neg = 1;
        meta.reg2neg = 1;
    }

    action finish_multiplication1() {
        hdr.calculation.multResult = (int<32>)hdr.calculation.reg1 >> 12;
    }

    action finish_multiplication2() {
        hdr.calculation.multResult = hdr.calculation.multResult + (int<32>)hdr.calculation.tmp24;
        hdr.calculation.tmp24 = 0;
    }

    table fix_negative_table {
        key = {
            hdr.calculation.reg1 : ternary;
            hdr.calculation.reg2 : ternary;
        }
        actions = {
            fix_reg1;
            fix_reg2;
            fix_reg1_2;
        }
        const entries = {
            (0x80000000 &&& 0x80000000, 0x00000000 &&& 0x80000000) : fix_reg1();
            (0x00000000 &&& 0x80000000, 0x80000000 &&& 0x80000000) : fix_reg2();
            (0x80000000 &&& 0x80000000, 0x80000000 &&& 0x80000000) : fix_reg1_2();
        }
    }

    #include "include/trigonometryTables_pow2e_split.p4"
    #include "include/transformMatrixTables.p4"

    table translation_table {
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
        default_action = getMatrixRowPPP(0, 0, 0);
    }

    table static_ipv4_fowarding {
        key = {
            hdr.ipv4.dst_addr: ternary;
        }
        actions = {
            ipv4_forward;
            NoAction;
        }

        const entries = {
            // send all traffic to port 1
            0x0000 &&& 0x0000 : ipv4_forward(1);
        }

        size = 128;
        default_action = NoAction;
    }

    table static_ipv4_fowarding_2 {
        key = {
            hdr.ipv4.dst_addr: ternary;
        }
        actions = {
            ipv4_forward;
            NoAction;
        }

        const entries = {
            // send all traffic to port 1
            0x0000 &&& 0x0000 : ipv4_forward(1);
        }

        size = 128;
        default_action = NoAction;
    }

    apply {
        if (hdr.ipv4.isValid()) {
            if (hdr.spherical.isValid()) { 
                if (hdr.calculation.multiply_simulate_egress == 1) {
                    finish_multiplication1();
                    finish_multiplication2();
                    if (hdr.calculation.calcNeg == 1) {
                        hdr.calculation.multResult = -hdr.calculation.multResult;
                    }
                    
                    hdr.calculation.calcNeg = 0;
                    hdr.calculation.multiply_simulate_egress = 0;
                }

                // STEP 1-8: calculate sin and cos
                // the step number is indicated by the recirculate header
                // -------------------------------
                // STEP 1: temp = phiUpperSin * phiLowerCos
                // STEP 2: sin(phi) = temp + (phiUpperCos * phiLowerSin)
                // STEP 3: temp = phiUpperCos * phiLowerCos
                // STEP 4: cos(phi) = temp + (phiUpperSin * phiLowerSin)
                // STEP 5: temp = thetaUpperSin * thetaLowerCos
                // STEP 6: sin(theta) = temp + (thetaUpperCos * thetaLowerSin)
                // STEP 7: temp = thetaUpperCos * thetaLowerCos
                // STEP 8: cos(theta) = temp + (thetaUpperSin * thetaLowerSin)

                // STEP 9-12: calculate multiplications
                // -------------------------------
                // STEP  9: x,y = radius * sin(theta)
                // STEP 10: z = radius * cos(theta)
                // STEP 11: x = x * cos(phi)
                // STEP 12: y = y * sin(phi)

                // STEP 13-25: transform coordinates with a rotation matrix and a translation vector
                // -------------------------------
                // STEP 13: get row 1
                // STEP 14: rx = mc1 * x
                // STEP 15: rx += mc2 * y
                // STEP 16: rx += mc3 * z
                // STEP 17: get row 2
                // STEP 18: ry = mc1 * x
                // STEP 19: ry += mc2 * y
                // STEP 20: ry += mc3 * z
                // STEP 21: get row 3
                // STEP 22: rz = mc1 * x
                // STEP 23: rz += mc2 * y
                // STEP 24: rz += mc3 * z
                // STEP 25: get and add translation vector

                if (hdr.recirculate.count == 0) {
                    hdr.spherical.start_ts = ig_prsr_md.global_tstamp;

                    meta.trigLower = (bit<16>)(hdr.spherical.phi)[BIT_SPLIT-1:0];
                    meta.trigUpper = (bit<16>)(hdr.spherical.phi)[BIT_SPLIT+15:BIT_SPLIT];

                    hdr.udp.checksum = 0;

                    // STEP 0: Calculate trig values and set up the first multiplication
                    phiUpperTable.apply();
                    phiLowerTable.apply();

                    if (meta.negFlag & 1 > 0) {
                        hdr.calculation.sinLower = -hdr.calculation.sinLower;
                    }
                    if (meta.negFlag & 2 > 0) {
                        hdr.calculation.cosLower = -hdr.calculation.cosLower;
                    }
                    if (meta.negFlag & 4 > 0) {
                        hdr.calculation.sinUpper = -hdr.calculation.sinUpper;
                    }
                    if (meta.negFlag & 8 > 0) {
                        hdr.calculation.cosUpper = -hdr.calculation.cosUpper;
                    }

                    calculateCartesian1_setup();
                    recirc(1);
                } else if (hdr.recirculate.count == 1) {
                    calculateCartesian1_finalize();
                    calculateCartesian2_setup();
                    recirc(2);
                } else if (hdr.recirculate.count == 2) {
                    calculateCartesian2_finalize();
                    calculateCartesian3_setup();
                    recirc(3);
                } else if (hdr.recirculate.count == 3) {
                    calculateCartesian3_finalize();
                    calculateCartesian4_setup();
                    recirc(4);
                } else if (hdr.recirculate.count == 4) {
                    calculateCartesian4_finalize();
                    
                    meta.trigLower = (bit<16>)(hdr.spherical.theta)[BIT_SPLIT-1:0];
                    meta.trigUpper = (bit<16>)(hdr.spherical.theta)[BIT_SPLIT+15:BIT_SPLIT];

                    thetaUpperTable.apply();
                    thetaLowerTable.apply();

                    if (meta.negFlag & 1 > 0) {
                        hdr.calculation.sinLower = -hdr.calculation.sinLower;
                    }
                    if (meta.negFlag & 2 > 0) {
                        hdr.calculation.cosLower = -hdr.calculation.cosLower;
                    }
                    if (meta.negFlag & 4 > 0) {
                        hdr.calculation.sinUpper = -hdr.calculation.sinUpper;
                    }
                    if (meta.negFlag & 8 > 0) {
                        hdr.calculation.cosUpper = -hdr.calculation.cosUpper;
                    }

                    calculateCartesian5_setup();
                    recirc(6);
                } else if (hdr.recirculate.count == 6) {
                    calculateCartesian5_finalize();
                    calculateCartesian6_setup();
                    recirc(7);
                } else if (hdr.recirculate.count == 7) {
                    calculateCartesian6_finalize();
                    calculateCartesian7_setup();
                    recirc(8);
                } else if (hdr.recirculate.count == 8) {
                    calculateCartesian7_finalize();
                    calculateCartesian8_setup();
                    recirc(9);
                } else if (hdr.recirculate.count == 9) {
                    calculateCartesian8_finalize();
                    calculateCartesian9_setup();
                    recirc(10);
                } else if (hdr.recirculate.count == 10) {
                    calculateCartesian9_finalize();
                    calculateCartesian10_setup();
                    recirc(11);
                } else if (hdr.recirculate.count == 11) {
                    calculateCartesian10_finalize();
                    calculateCartesian11_setup();
                    recirc(12);
                } else if (hdr.recirculate.count == 12) {
                    calculateCartesian11_finalize();
                    calculateCartesian12_setup();
                    recirc(13);
                } else if (hdr.recirculate.count == 13) {
                    calculateCartesian12_finalize();

                    // ----- END OF SPHERICAL TO CARTESIAN CONVERSION -----
                    matrix_row1_table.apply(); // get first matrix row

                    if (meta.negFlag & 1 > 0) {
                        ALIAS_matrixcol1 = -ALIAS_matrixcol1;
                    }
                    if (meta.negFlag & 2 > 0) {
                        ALIAS_matrixcol2 = -ALIAS_matrixcol2;
                    }
                    if (meta.negFlag & 4 > 0) {
                        ALIAS_matrixcol3 = -ALIAS_matrixcol3;
                    }

                    calculateTransform1_setup();
                    recirc(15);
                } else if (hdr.recirculate.count == 15) {
                    calculateTransform1_finalize();
                    calculateTransform2_setup();
                    recirc(16);
                } else if (hdr.recirculate.count == 16) {
                    calculateTransform2_finalize();
                    calculateTransform3_setup();
                    recirc(17);
                } else if (hdr.recirculate.count == 17) {
                    calculateTransform3_finalize();
                    calculateTransform3_finalize2();

                    matrix_row2_table.apply(); // get second matrix row

                    if (meta.negFlag & 1 > 0) {
                        ALIAS_matrixcol1 = -ALIAS_matrixcol1;
                    }
                    if (meta.negFlag & 2 > 0) {
                        ALIAS_matrixcol2 = -ALIAS_matrixcol2;
                    }
                    if (meta.negFlag & 4 > 0) {
                        ALIAS_matrixcol3 = -ALIAS_matrixcol3;
                    }

                    calculateTransform4_setup();
                    recirc(19);
                } else if (hdr.recirculate.count == 19) {
                    calculateTransform4_finalize();
                    calculateTransform5_setup();
                    recirc(20);
                } else if (hdr.recirculate.count == 20) {
                    calculateTransform5_finalize();
                    calculateTransform6_setup();
                    recirc(21);
                } else if (hdr.recirculate.count == 21) {
                    calculateTransform6_finalize();
                    calculateTransform6_finalize2();

                    matrix_row3_table.apply(); // get third matrix row

                    if (meta.negFlag & 1 > 0) {
                        ALIAS_matrixcol1 = -ALIAS_matrixcol1;
                    }
                    if (meta.negFlag & 2 > 0) {
                        ALIAS_matrixcol2 = -ALIAS_matrixcol2;
                    }
                    if (meta.negFlag & 4 > 0) {
                        ALIAS_matrixcol3 = -ALIAS_matrixcol3;
                    }

                    calculateTransform7_setup();
                    recirc(23);
                } else if (hdr.recirculate.count == 23) {
                    calculateTransform7_finalize();
                    calculateTransform8_setup();
                    recirc(24);
                } else if (hdr.recirculate.count == 24) {
                    calculateTransform8_finalize();
                    calculateTransform9_setup();
                    recirc(25);
                } else if (hdr.recirculate.count == 25) {
                    calculateTransform9_finalize();
                    calculateTransform9_finalize2();

                    translation_table.apply();

                    if (meta.negFlag & 1 > 0) {
                        ALIAS_matrixcol1 = -ALIAS_matrixcol1;
                    }
                    if (meta.negFlag & 2 > 0) {
                        ALIAS_matrixcol2 = -ALIAS_matrixcol2;
                    }
                    if (meta.negFlag & 4 > 0) {
                        ALIAS_matrixcol3 = -ALIAS_matrixcol3;
                    }

                    hdr.spherical.x = hdr.spherical.x + ALIAS_matrixcol1;
                    hdr.spherical.y = hdr.spherical.y + ALIAS_matrixcol2;
                    hdr.spherical.z = hdr.spherical.z + ALIAS_matrixcol3;

#ifdef ENABLE_RTS
                    bit<32> temp_addr = hdr.ipv4.src_addr;
                    hdr.ipv4.src_addr = hdr.ipv4.dst_addr;
                    hdr.ipv4.dst_addr = temp_addr;

                    bit<48> temp_mac = hdr.ethernet.src_addr;
                    hdr.ethernet.src_addr = hdr.ethernet.dst_addr;
                    hdr.ethernet.dst_addr = temp_mac;

#ifdef SWAP_PORTS_ON_RETURN
                    bit<16> tmp_port = hdr.udp.sport;
                    hdr.udp.sport = hdr.udp.dport;
                    hdr.udp.dport = tmp_port;
#endif
#endif

                    hdr.recirculate.count = 0xFFFF;    
                    static_ipv4_fowarding_2.apply();
                }

                if (hdr.recirculate.count != 0xFFFF) {
                    // make all negative numbers positive, since the multiplication in pipe 1 only works with positive numbers
                    fix_negative_table.apply();

                    if (meta.reg1neg == 1) {
                        hdr.calculation.reg1 = hdr.calculation.reg1 + 1;
                    }
                    if (meta.reg2neg == 1) {
                        hdr.calculation.reg2 = hdr.calculation.reg2 + 1;
                    }

                    hdr.calculation.multResult = 0;
                }
            } else {
				static_ipv4_fowarding.apply();
            }
        }
    }
}

    /*********************  D E P A R S E R  ************************/

control IngressDeparser(packet_out pkt,
    /* User */
    inout my_ingress_headers_t                       hdr,
    in    my_ingress_metadata_t                      meta,
    /* Intrinsic */
    in    ingress_intrinsic_metadata_for_deparser_t  ig_dprsr_md)
{
    apply {    
        pkt.emit(hdr);
    }
}


/*************************************************************************
 ****************  E G R E S S   P R O C E S S I N G   *******************
 *************************************************************************/

    /***********************  P A R S E R  **************************/

parser EgressParser(packet_in        pkt,
    /* User */
    out my_egress_headers_t          hdr,
    out my_egress_metadata_t         meta,
    /* Intrinsic */
    out egress_intrinsic_metadata_t  eg_intr_md)
{
    state start {
        pkt.extract(eg_intr_md);
        transition parse_ethernet;
    }

    state parse_ethernet {
        pkt.extract(hdr.ethernet);
        transition select(hdr.ethernet.ether_type) {
            ETHERTYPE_IPV4:  parse_ipv4;
            default: accept;
        }
    }

    state parse_ipv4 {
        pkt.extract(hdr.ipv4);
        transition select(hdr.ipv4.protocol) {
            PROTOCOL_UDP:  parse_udp;
            default: accept;
        }
    }

    state parse_udp {
        pkt.extract(hdr.udp);
        transition select(hdr.udp.dport) {
            NORMAL_PORT: parse_recirc;
            TIMING_PORT: parse_timing;
            default: accept;
        }
    }

    state parse_timing {
        pkt.extract(hdr.timing);
        transition parse_recirc;
    }

    state parse_recirc {
        pkt.extract(hdr.recirculate);
        transition parse_payload;
    }

    state parse_payload {
        pkt.extract(hdr.spherical);

        transition select(eg_intr_md.egress_port[7:0]) {
            RECIRC_PORT_MULTIPLY: parse_calculation;
            default: accept;
        }
    }

    state parse_calculation {
        pkt.extract(hdr.calculation);
 
        transition accept;
    }
}

    /***************** M A T C H - A C T I O N  *********************/

control Egress(
    /* User */
    inout my_egress_headers_t                          hdr,
    inout my_egress_metadata_t                         meta,
    /* Intrinsic */    
    in    egress_intrinsic_metadata_t                  eg_intr_md,
    in    egress_intrinsic_metadata_from_parser_t      eg_prsr_md,
    inout egress_intrinsic_metadata_for_deparser_t     eg_dprsr_md,
    inout egress_intrinsic_metadata_for_output_port_t  eg_oport_md)
{
    apply {
        if (hdr.spherical.isValid()) {
            if (hdr.recirculate.count == 0xFFFF) {
                hdr.spherical.end_ts = eg_prsr_md.global_tstamp;
            }
        }
    }
}

    /*********************  D E P A R S E R  ************************/

control EgressDeparser(packet_out pkt,
    /* User */
    inout my_egress_headers_t                       hdr,
    in    my_egress_metadata_t                      meta,
    /* Intrinsic */
    in    egress_intrinsic_metadata_for_deparser_t  eg_dprsr_md)
{
    Checksum() ipv4_csum;

    apply {
		hdr.ipv4.hdr_checksum = ipv4_csum.update({
			hdr.ipv4.version, hdr.ipv4.ihl, hdr.ipv4.diffserv,
			hdr.ipv4.total_len, hdr.ipv4.identification,
			hdr.ipv4.flags, hdr.ipv4.frag_offset,
			hdr.ipv4.ttl, hdr.ipv4.protocol,
			hdr.ipv4.src_addr,
			hdr.ipv4.dst_addr});
    
        pkt.emit(hdr);
    }
}


/************ F I N A L   P A C K A G E ******************************/
Pipeline(
    IngressParser(),
    Ingress(),
    IngressDeparser(),
    EgressParser(),
    Egress(),
    EgressDeparser()
) pipe;

Pipeline(
    IngressParserMultiply(),
    IngressMultiply(),
    IngressDeparserMultiply(),
    EgressParser(),
    Egress(),
    EgressDeparser()
) pipe_multiply;


Switch(pipe, pipe_multiply) main;