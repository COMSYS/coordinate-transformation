/*
    Coordinate Transformation
    Copyright (c) 2021 
	
	Authors: Ike Kunze, René Glebke, Jan Scheiper
	E-mail: inp@comsys.rwth-aachen.de
*/

/* -*- P4_16 -*- */
#include <core.p4>
#include <v1model.p4>

#include "include/defines.h"

const bit<16> TYPE_IPV4 = 16w0x0800;
const bit<16> TYPE_IPV6 = 16w0x86dd;
const bit<16> TYPE_ARP = 16w0x0806;

const bit<8> PROTTYPE_TCP = 8w0x06;
const bit<8> PROTTYPE_UDP = 8w0x11;


/*************************************************************************
*********************** H E A D E R S  ***********************************
*************************************************************************/

typedef bit<9>  egressSpec_t;

header intrinsic_metadata_t {
    bit<64> ingress_global_timestamp;
    bit<64> current_global_timestamp;
}

header ethernet_t {
    bit<48>     dstAddr;
    bit<48>     srcAddr;
    bit<16>     etherType;
}

header arp_t {
    bit<16>     hwType;
    bit<16>     protType;
    bit<8>      hwAddrLen;
    bit<8>      protAddrLen;
    bit<16>     opcode;
    bit<48>     hwSrcAddr;
    bit<32>     protSrcAddr;
    bit<48>     hwDstAddr;
    bit<32>     protDstAddr;
}

header ipv4_t {
    bit<4>      version;
    bit<4>      ihl;
    bit<8>      diffserv;
    bit<16>     totalLen;
    bit<16>     identification;
    bit<3>      flags;
    bit<13>     fragOffset;
    bit<8>      ttl;
    bit<8>      protocol;
    bit<16>     hdrChecksum;
    bit<32>     srcAddr;
    bit<32>     dstAddr;
}

header ipv6_t {
    bit<4>    version;
    bit<8>    trafficClass;
    bit<20>   flowLabel;
    bit<16>   payloadLen;
    bit<8>    nextHeader;
    bit<8>    hopLimit;
    bit<128>  srcAddr;
    bit<128>  dstAddr;
}

header udp_t {
    bit<16>   srcPort;
    bit<16>   dstPort;
    bit<16>   udpLen;
    bit<16>   checkSum;
}

header timing_h {
    bit<8> hops;
    bit<64> hop1;
    bit<64> hop2;
}

header spherical_p {
    int<32> radius;
    bit<32> phi;
    bit<32> theta;
}

header output_p {
    int<32> x;
    int<32> y;
    int<32> z;
    bit<64> start_ts;
    bit<64> end_ts;
}

struct metadata {
    bit<32> inputPhi;
    bit<32> inputTheta;
    int<32> sinPhi;
    int<32> cosPhi;
    int<32> sinTheta;
    int<32> cosTheta;
    bit<16> phiLower;
    bit<16> phiUpper;
    bit<16> thetaLower;
    bit<16> thetaUpper;
    int<32> phiLowerSin;
    int<32> phiUpperSin;
    int<32> phiLowerCos;
    int<32> phiUpperCos;
    int<32> thetaLowerSin;
    int<32> thetaUpperSin;
    int<32> thetaLowerCos;
    int<32> thetaUpperCos;

    int<32> matrix_a00;
    int<32> matrix_a01;
    int<32> matrix_a02;
    int<32> matrix_a10;
    int<32> matrix_a11;
    int<32> matrix_a12;
    int<32> matrix_a20;
    int<32> matrix_a21;
    int<32> matrix_a22;
    int<32> matrix_t0;
    int<32> matrix_t1;
    int<32> matrix_t2;

    bit<8> addr_match;

#ifdef USE_QUARTER_TABLES
    bit<1>  flipSinPhi;
    bit<1>  flipCosPhi;
    bit<1>  flipSinTheta;
    bit<1>  flipCosTheta;
#endif

    intrinsic_metadata_t intrinsic_metadata;
}

struct headers {
    ethernet_t                              ethernet;
    arp_t                                   arp;
	ipv4_t									ipv4;
	ipv6_t									ipv6;
	udp_t									udp;
    timing_h                                timing;
    spherical_p                             spherical;
    output_p                                output;

}

/*************************************************************************
*********************** P A R S E R  ***********************************
*************************************************************************/

parser MyParser(packet_in packet,
                out headers hdr,
                inout metadata meta,
                inout standard_metadata_t standard_metadata)
{

    state start
    {
        transition parse_ethernet;
    }

    state parse_ethernet
    {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType)
        {
            TYPE_IPV4: parse_ipv4;
			TYPE_IPV6: parse_ipv6;
            TYPE_ARP: parse_arp;
        }
    }

	state parse_ipv4
    {
        packet.extract(hdr.ipv4);
        transition select(hdr.ipv4.protocol)
        {
            PROTTYPE_UDP: parse_udp;
        }
    }

	state parse_ipv6
    {
        packet.extract(hdr.ipv6);
        transition select(hdr.ipv6.nextHeader)
        {
            PROTTYPE_UDP: parse_udp;
        }
    }

    state parse_arp
    {
        packet.extract(hdr.arp);
        transition accept;
    }

	state parse_udp
    {
		packet.extract(hdr.udp);
        transition select(hdr.udp.dstPort) {
            DEFAULT_PORT: parse_payload;
            TIMING_PORT: parse_timing;
            default: accept;
        }
    }

    state parse_timing {
        packet.extract(hdr.timing);
        transition parse_payload;
    }

    state parse_payload {
        packet.extract(hdr.spherical);
        packet.extract(hdr.output);
        transition accept;
    }
}

/*************************************************************************
************   C H E C K S U M    V E R I F I C A T I O N   *************
*************************************************************************/

control DummyVerifyChecksum(inout headers hdr, inout metadata meta)
{
    apply {  }
}


/*************************************************************************
**************  I N G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyIngress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata)
{
    register<int<32>>(255) matrix_table_a00;
    register<int<32>>(255) matrix_table_a01;
    register<int<32>>(255) matrix_table_a02;
    register<int<32>>(255) matrix_table_a10;
    register<int<32>>(255) matrix_table_a11;
    register<int<32>>(255) matrix_table_a12;
    register<int<32>>(255) matrix_table_a20;
    register<int<32>>(255) matrix_table_a21;
    register<int<32>>(255) matrix_table_a22;
    register<int<32>>(255) matrix_table_t0;
    register<int<32>>(255) matrix_table_t1;
    register<int<32>>(255) matrix_table_t2;

    action arpResponse()
    {

        bi<32> dummy = 0x00154d1379f2
        // Switch destination and source MAC address
        hdr.ethernet.dstAddr = hdr.ethernet.srcAddr;
        hdr.ethernet.srcAddr = dummy;

        hdr.arp.opcode = 2;
        bit<32> tmpARP = hdr.arp.protSrcAddr;
        hdr.arp.protSrcAddr = hdr.arp.protDstAddr;
        hdr.arp.protDstAddr = tmpARP;

        hdr.arp.hwDstAddr = hdr.arp.hwSrcAddr; //Back to sender
        hdr.arp.hwSrcAddr = dummy;

        standard_metadata.egress_spec = standard_metadata.ingress_port;
    }

    action returnToSenderv4()
    {
        //Switch destination and source MAC address
        bit<48> tmpEthernet = hdr.ethernet.srcAddr;
        hdr.ethernet.srcAddr = hdr.ethernet.dstAddr;
        hdr.ethernet.dstAddr = tmpEthernet;

        //Switch destination and source IP address
        bit<32> tmpIPv4 = hdr.ipv4.srcAddr;
        hdr.ipv4.srcAddr = hdr.ipv4.dstAddr;
        hdr.ipv4.dstAddr = tmpIPv4;

        //Switch destination and source UDP port
        bit<16> tmpUDP = hdr.udp.srcPort;
        hdr.udp.srcPort = hdr.udp.dstPort;
        hdr.udp.dstPort = tmpUDP;
        hdr.udp.checkSum = 0;

        standard_metadata.egress_spec = standard_metadata.ingress_port;
    }

    action returnToSenderv4Port(bit<16> dstPort) {
        //Switch destination and source MAC address
        bit<48> tmpEthernet = hdr.ethernet.srcAddr;
        hdr.ethernet.srcAddr = hdr.ethernet.dstAddr;
        hdr.ethernet.dstAddr = tmpEthernet;

        //Switch destination and source IP address
        bit<32> tmpIPv4 = hdr.ipv4.srcAddr;
        hdr.ipv4.srcAddr = hdr.ipv4.dstAddr;
        hdr.ipv4.dstAddr = tmpIPv4;

        hdr.udp.dstPort = dstPort;
        hdr.udp.checkSum = 0;

        standard_metadata.egress_spec = standard_metadata.ingress_port;
    }

    action phiLowerPosPos(int<32> sin, int<32> cos) {
        meta.phiLowerSin = sin;
        meta.phiLowerCos = cos;
    }
	
    action phiLowerNegPos(int<32> sin, int<32> cos) {
        meta.phiLowerSin = -sin;
        meta.phiLowerCos = cos;
    }

    action phiLowerPosNeg(int<32> sin, int<32> cos) {
        meta.phiLowerSin = sin;
        meta.phiLowerCos = -cos;
    }

    action phiLowerNegNeg(int<32> sin, int<32> cos) {
        meta.phiLowerSin = -sin;
        meta.phiLowerCos = -cos;
    }

    action phiUpperPosPos(int<32> sin, int<32> cos) {
        meta.phiUpperSin = sin;
        meta.phiUpperCos = cos;
    }
	
    action phiUpperNegPos(int<32> sin, int<32> cos) {
        meta.phiUpperSin = -sin;
        meta.phiUpperCos = cos;
    }

    action phiUpperPosNeg(int<32> sin, int<32> cos) {
        meta.phiUpperSin = sin;
        meta.phiUpperCos = -cos;
    }

    action phiUpperNegNeg(int<32> sin, int<32> cos) {
        meta.phiUpperSin = -sin;
        meta.phiUpperCos = -cos;
    }

    action thetaLowerPosPos(int<32> sin, int<32> cos) {
        meta.thetaLowerSin = sin;
        meta.thetaLowerCos = cos;
    }
	
    action thetaLowerNegPos(int<32> sin, int<32> cos) {
        meta.thetaLowerSin = -sin;
        meta.thetaLowerCos = cos;
    }

    action thetaLowerPosNeg(int<32> sin, int<32> cos) {
        meta.thetaLowerSin = sin;
        meta.thetaLowerCos = -cos;
    }

    action thetaLowerNegNeg(int<32> sin, int<32> cos) {
        meta.thetaLowerSin = -sin;
        meta.thetaLowerCos = -cos;
    }

    action thetaUpperPosPos(int<32> sin, int<32> cos) {
        meta.thetaUpperSin = sin;
        meta.thetaUpperCos = cos;
    }
	
    action thetaUpperNegPos(int<32> sin, int<32> cos) {
        meta.thetaUpperSin = -sin;
        meta.thetaUpperCos = cos;
    }

    action thetaUpperPosNeg(int<32> sin, int<32> cos) {
        meta.thetaUpperSin = sin;
        meta.thetaUpperCos = -cos;
    }

    action thetaUpperNegNeg(int<32> sin, int<32> cos) {
        meta.thetaUpperSin = -sin;
        meta.thetaUpperCos = -cos;
    }

    action prepare() {
        meta.sinPhi = 0;
        meta.sinTheta = 0;
        meta.cosPhi = 0;
        meta.cosTheta = 0;

        meta.inputPhi = hdr.spherical.phi;
        meta.inputTheta = hdr.spherical.theta;

#ifdef USE_QUARTER_TABLES
        meta.flipSinPhi = 0;
        meta.flipCosPhi = 0;
        meta.flipSinTheta = 0;
        meta.flipCosTheta = 0;

        if (meta.inputPhi > PI_FP) {
            meta.flipSinPhi = 1;
            meta.flipCosPhi = 1;
            meta.inputPhi = meta.inputPhi - PI_FP;
        }

        if (meta.inputPhi > (PI_FP >> 1)) {
            meta.inputPhi = PI_FP - meta.inputPhi;
            meta.flipCosPhi = 1 - meta.flipCosPhi;
        }

        if (meta.inputTheta > PI_FP) {
            meta.flipSinTheta = 1;
            meta.flipCosTheta = 1;
            meta.inputTheta = meta.inputTheta - PI_FP;
        }

        if (meta.inputTheta > (PI_FP >> 1)) {
            meta.inputTheta = PI_FP - meta.inputTheta;
            meta.flipCosTheta = 1 - meta.flipCosTheta;
        }
#endif

        meta.phiLower = (bit<16>)(meta.inputPhi >> TABLE_KEY_OFFSET)[BIT_SPLIT - 1:0];
        meta.phiUpper = (meta.inputPhi >> (BIT_SPLIT + TABLE_KEY_OFFSET))[15:0];
        meta.thetaLower = (bit<16>)(meta.inputTheta >> TABLE_KEY_OFFSET)[BIT_SPLIT - 1:0];
        meta.thetaUpper = (meta.inputTheta >> (BIT_SPLIT + TABLE_KEY_OFFSET))[15:0];

        meta.addr_match = hdr.ipv4.srcAddr[7:0];
    }

    #include "include/trigTablesSplitEmpty.p4"
    #include "include/multiply_action.p4"

	apply {
        if (hdr.arp.isValid()) {
            arpResponse();
        } else if (hdr.spherical.isValid()) {
            hdr.output.start_ts = meta.intrinsic_metadata.current_global_timestamp;

            prepare();
            
            phiUpperTable.apply();
            phiLowerTable.apply();
            thetaUpperTable.apply();
            thetaLowerTable.apply();

            int<32> result1;
            int<32> result2;

            multiply01(result1, meta.phiUpperSin, meta.phiLowerCos);
            multiply02(result2, meta.phiUpperCos, meta.phiLowerSin);

            meta.sinPhi = result1 + result2;

            multiply03(result1, meta.phiUpperCos, meta.phiLowerCos);
            multiply04(result2, meta.phiUpperSin, meta.phiLowerSin);
            meta.cosPhi = result1 - result2;

            multiply05(result1, meta.thetaUpperSin, meta.thetaLowerCos);
            multiply06(result2, meta.thetaUpperCos, meta.thetaLowerSin);
            meta.sinTheta = result1 + result2;

            multiply07(result1, meta.thetaUpperCos, meta.thetaLowerCos);
            multiply08(result2, meta.thetaUpperSin, meta.thetaLowerSin);
            meta.cosTheta = result1 - result2;

#ifdef USE_QUARTER_TABLES
            if (meta.flipSinPhi == 1) {
                meta.sinPhi = -meta.sinPhi;
            }
            if (meta.flipCosPhi == 1) {
                meta.cosPhi = -meta.cosPhi;
            }
            if (meta.flipSinTheta == 1) {
                meta.sinTheta = -meta.sinTheta;
            }
            if (meta.flipCosTheta == 1) {
                meta.cosTheta = -meta.cosTheta;
            }
#endif

            int<32> reg;
            multiply09(reg, meta.sinTheta, hdr.spherical.radius);

            int<32> x = 0;
            int<32> y = 0;
            int<32> z = 0;

            multiply10(x, reg, meta.cosPhi);
            multiply11(y, reg, meta.sinPhi);
            multiply12(z, hdr.spherical.radius, meta.cosTheta);

            matrix_table_a00.read(meta.matrix_a00, (bit<32>)meta.addr_match);
            matrix_table_a01.read(meta.matrix_a01, (bit<32>)meta.addr_match);
            matrix_table_a02.read(meta.matrix_a02, (bit<32>)meta.addr_match);
            matrix_table_a10.read(meta.matrix_a10, (bit<32>)meta.addr_match);
            matrix_table_a11.read(meta.matrix_a11, (bit<32>)meta.addr_match);
            matrix_table_a12.read(meta.matrix_a12, (bit<32>)meta.addr_match);
            matrix_table_a20.read(meta.matrix_a20, (bit<32>)meta.addr_match);
            matrix_table_a21.read(meta.matrix_a21, (bit<32>)meta.addr_match);
            matrix_table_a22.read(meta.matrix_a22, (bit<32>)meta.addr_match);
            matrix_table_t0.read(meta.matrix_t0, (bit<32>)meta.addr_match);
            matrix_table_t1.read(meta.matrix_t1, (bit<32>)meta.addr_match);
            matrix_table_t2.read(meta.matrix_t2, (bit<32>)meta.addr_match);

            multiply_matrix01(result1, meta.matrix_a00, x);
            multiply_matrix02(result2, meta.matrix_a01, y);
            hdr.output.x = result1 + result2;
            multiply_matrix03(result1, meta.matrix_a02, z);
            hdr.output.x = hdr.output.x + result1 + meta.matrix_t0;

            multiply_matrix04(result1, meta.matrix_a10, x);
            multiply_matrix05(result2, meta.matrix_a11, y);
            hdr.output.y = result1 + result2;
            multiply_matrix06(result1, meta.matrix_a12, z);
            hdr.output.y = hdr.output.y + result1 + meta.matrix_t1;

            multiply_matrix07(result1, meta.matrix_a20, x);
            multiply_matrix08(result2, meta.matrix_a21, y);
            hdr.output.z = result1 + result2;
            multiply_matrix09(result1, meta.matrix_a22, z);
            hdr.output.z = hdr.output.z + result1 + meta.matrix_t2;

            hdr.output.end_ts = meta.intrinsic_metadata.current_global_timestamp;

            returnToSenderv4Port(hdr.udp.dstPort);
        } else if (hdr.ipv4.isValid()) {
            returnToSenderv4();
	    }
    }
}

/*************************************************************************
****************  E G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control DummyEgress(inout headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {
    apply {  }
}

/*************************************************************************
*************   C H E C K S U M    C O M P U T A T I O N   **************
*************************************************************************/

control MyComputeChecksum(inout headers  hdr, inout metadata meta)
{
    apply
    {
    	update_checksum(
            hdr.ipv4.isValid(),
            { hdr.ipv4.version,
	          hdr.ipv4.ihl,
              hdr.ipv4.diffserv,
              hdr.ipv4.totalLen,
              hdr.ipv4.identification,
              hdr.ipv4.flags,
              hdr.ipv4.fragOffset,
              hdr.ipv4.ttl,
              hdr.ipv4.protocol,
              hdr.ipv4.srcAddr,
              hdr.ipv4.dstAddr },
            hdr.ipv4.hdrChecksum,
            HashAlgorithm.csum16);
    }
}

/*************************************************************************
***********************  D E P A R S E R  *******************************
*************************************************************************/

control MyDeparser(packet_out packet, in headers hdr)
{
    apply
    {
        packet.emit(hdr.ethernet);
        packet.emit(hdr.arp);
        packet.emit(hdr.ipv4);
        packet.emit(hdr.ipv6);
        packet.emit(hdr.udp);
        packet.emit(hdr.timing);
        packet.emit(hdr.spherical);
        packet.emit(hdr.output);
    }
}

/*************************************************************************
***********************  S W I T C H  *******************************
*************************************************************************/

V1Switch(
    MyParser(),
    DummyVerifyChecksum(),
    MyIngress(),
    DummyEgress(),
    MyComputeChecksum(),
    MyDeparser()
) main;
