/*
    Coordinate Transformation
    Copyright (c) 2021 
	
	Authors: Ike Kunze, René Glebke, Jan Scheiper
	E-mail: inp@comsys.rwth-aachen.de
*/

/* -*- P4_16 -*- */
#pragma once

#include <core.p4>
#include <tna.p4>

// Defines
// -------------------------------------------------------

const bit<16> ETHERTYPE_IPV4 = 0x0800;
const bit<8> PROTOCOL_UDP = 0x11;

#define FIX_POINT_EXPONENT 25
#define BIT_SPLIT 14

// Return To Sender feature
// incoming packets will get their source and dest addresses switched
#define ENABLE_RTS

// Port config (default):
// #define NORMAL_PORT 10000
// #define TIMING_PORT 10001
#define NORMAL_PORT 48878
#define TIMING_PORT 48879

// Port swapping feature
// incoming packets will get their src and dst port switched (only works with ENABLE_RTS)
#define SWAP_PORTS_ON_RETURN

#define TRAILER_BITS 0

#define RECIRC_PORT_MAIN 148
#define RECIRC_PORT_MULTIPLY 12

// Headers
// -------------------------------------------------------

header ethernet_h {
    bit<48>   dst_addr;
    bit<48>   src_addr;
    bit<16>   ether_type;
}

header ipv4_h {
    bit<4>   version;
    bit<4>   ihl;
    bit<8>   diffserv;
    bit<16>  total_len;
    bit<16>  identification;
    bit<3>   flags;
    bit<13>  frag_offset;
    bit<8>   ttl;
    bit<8>   protocol;
    bit<16>  hdr_checksum;
    bit<32>  src_addr;
    bit<32>  dst_addr;
}

header udp_h {
    bit<16> sport;
    bit<16> dport;
    bit<16> len;
    bit<16> checksum;
}

header recirculate_p {
    bit<16> count;
}

header spherical_p {
    int<32> radius;
    int<32> phi;
    int<32> theta;
    int<32> x;
    int<32> y;
    int<32> z;
    bit<48> start_ts;
    bit<48> end_ts;
#if TRAILER_BITS > 0
    bit<TRAILER_BITS> trailer;
#endif
}

#define ALIAS_matrixcol1 hdr.calculation.sinTheta
#define ALIAS_matrixcol2 hdr.calculation.sinPhi
#define ALIAS_matrixcol3 hdr.calculation.cosTheta
#define ALIAS_matrixacc hdr.calculation.cosPhi
#define ALIAS_matrixres1 hdr.calculation.sinLower
#define ALIAS_matrixres2 hdr.calculation.sinUpper
#define ALIAS_matrixres3 hdr.calculation.cosLower
#define ALIAS_matrixacc2 hdr.calculation.cosUpper

header calculation_p {
    int<32> sinLower;
    int<32> sinUpper;
    int<32> cosLower;
    int<32> cosUpper;

    int<32> sinTheta;
    int<32> sinPhi;
    int<32> cosTheta;
    int<32> cosPhi;
    bit<32> reg1;
    bit<32> reg2;
    int<32> multResult;

    bit<32> tmp24;
    bit<1> calcNeg;
    bit<1> multiply_simulate_egress;
    @padding bit<6> _pad;
}

header timing_h {
    bit<8> hops;
    bit<16> _pad1;
    bit<48> hop1;
    bit<16> _pad2;
    bit<48> hop2;
}

// Ingress Headers
// -------------------------------------------------------

struct my_ingress_headers_t {
    ethernet_h      ethernet;
    ipv4_h          ipv4;
    udp_h           udp;
    timing_h        timing;
    recirculate_p   recirculate;
    spherical_p     spherical;
    calculation_p   calculation;
}

// Ingress Metadata
// -------------------------------------------------------

struct my_ingress_metadata_t {
    bit<8> negFlag;

    bit<16> trigUpper;
    bit<16> trigLower;

    bit<32> reg1_1;
    bit<32> reg1_2;
    bit<32> reg2_1;
    bit<32> reg2_2;

    bit<32> tmp0;
    bit<32> tmp0S;
    bit<32> tmp2;
    bit<32> tmp3;
    bit<32> tmp4;
    bit<32> tmp4S;
    bit<32> tmp6;
    bit<32> tmp7;
    bit<32> tmp8;
    bit<32> tmp8S;
    bit<32> tmp10;
    bit<32> tmp11;
    bit<32> tmp12;
    bit<32> tmp12S;

    bit<32> tmp14;
    bit<32> tmp15;
    bit<32> tmp16;
    bit<32> tmp16S;
    bit<32> tmp18;
    bit<32> tmp19;
    bit<32> tmp20;
    bit<32> tmp20S;
    bit<32> tmp22;
    bit<32> tmp23;

    bit<32> tmp26;
    bit<32> tmp27;
    bit<32> tmp28;
    bit<32> tmp29;
    bit<32> tmp30;
    bit<32> tmp31;

    bit<1> reg1neg;
    bit<1> reg2neg;
}

// Egress Headers
// -------------------------------------------------------

struct my_egress_headers_t {
    ethernet_h      ethernet;
    ipv4_h          ipv4;
    udp_h           udp;
    timing_h        timing;
    recirculate_p   recirculate;
    spherical_p     spherical;
    calculation_p   calculation;
}

// Egress Metadata
// -------------------------------------------------------

struct my_egress_metadata_t {
    int<32> multResult;
    bit<8> negFlag;
    bit<32> matchAddr;
}