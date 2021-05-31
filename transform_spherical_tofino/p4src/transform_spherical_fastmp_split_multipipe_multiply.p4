/*
    Coordinate Transformation
    Copyright (c) 2021 
	
	Authors: Ike Kunze, René Glebke, Jan Scheiper
	E-mail: inp@comsys.rwth-aachen.de
*/

#include "include/multipipe_shared.p4"

/*************************************************************************
 **************  I N G R E S S   P R O C E S S I N G   *******************
 *************************************************************************/

    /***********************  P A R S E R  **************************/
parser IngressParserMultiply(packet_in        pkt,
    /* User */    
    out my_ingress_headers_t          hdr,
    out my_ingress_metadata_t         meta,
    /* Intrinsic */
    out ingress_intrinsic_metadata_t  ig_intr_md)
{
    state start {
        pkt.extract(ig_intr_md);
        pkt.advance(PORT_METADATA_SIZE);

        meta.tmp0 = 0;
        meta.tmp0S = 0;
        meta.tmp2 = 0;
        meta.tmp3 = 0;
        meta.tmp4 = 0;
        meta.tmp4S = 0;
        meta.tmp6 = 0;
        meta.tmp7 = 0;
        meta.tmp8 = 0;
        meta.tmp8S = 0;
        meta.tmp10 = 0;
        meta.tmp11 = 0;
        meta.tmp12 = 0;

        meta.tmp14 = 0;
        meta.tmp15 = 0;
        meta.tmp16 = 0;
        meta.tmp16S = 0;
        meta.tmp18 = 0;
        meta.tmp19 = 0;
        meta.tmp20 = 0;
        meta.tmp20S = 0;
        meta.tmp22 = 0;
        meta.tmp23 = 0;
        
        meta.tmp26 = 0;
        meta.tmp27 = 0;
        meta.tmp28 = 0;
        meta.tmp29 = 0;
        meta.tmp30 = 0;
        meta.tmp31 = 0;

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
            RECIRC_PORT_MULTIPLY: parse_calculation;
            RECIRC_PORT_MAIN: parse_calculation;
            default: accept;
        }
    }

    state parse_calculation {
        pkt.extract(hdr.calculation);

        transition accept;
    }
}

    /***************** M A T C H - A C T I O N  *********************/

control IngressMultiply(
    /* User */
    inout my_ingress_headers_t                       hdr,
    inout my_ingress_metadata_t                      meta,
    /* Intrinsic */
    in    ingress_intrinsic_metadata_t               ig_intr_md,
    in    ingress_intrinsic_metadata_from_parser_t   ig_prsr_md,
    inout ingress_intrinsic_metadata_for_deparser_t  ig_dprsr_md,
    inout ingress_intrinsic_metadata_for_tm_t        ig_tm_md)
{
    // NETWORK RELATED ACTIONS
    action ipv4_forward(PortId_t port){
        ig_tm_md.ucast_egress_port = port;
        ig_tm_md.disable_ucast_cutthru = 1;
    }

    table static_ipv4_fowarding_multiply {
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

    action returnToPipe1() {
        hdr.calculation.multiply_simulate_egress = 1;
        ig_tm_md.ucast_egress_port = RECIRC_PORT_MAIN;  // recirculate to main pipe
    }

    Hash<bit<32>>(HashAlgorithm_t.IDENTITY) hash_copy1;
    Hash<bit<32>>(HashAlgorithm_t.IDENTITY) hash_copy2;
    Hash<bit<32>>(HashAlgorithm_t.IDENTITY) hash_copy3;
    Hash<bit<32>>(HashAlgorithm_t.IDENTITY) hash_copy4;
    Hash<bit<32>>(HashAlgorithm_t.IDENTITY) hash_copy5;
    Hash<bit<32>>(HashAlgorithm_t.IDENTITY) hash_copy6;

    table reg1_table {
        key = {
            meta.reg1_1: exact;
        }
        actions = {
            NoAction;
        }
        default_action = NoAction();
    }

    table reg2_table {
        key = {
            meta.reg2_1: exact;
        }
        actions = {
            NoAction;
        }
        default_action = NoAction();
    }

    action mult01() {
        meta.tmp2 = meta.tmp2 + meta.tmp3;
        meta.tmp6 = meta.tmp6 + meta.tmp7;
        meta.tmp10 = meta.tmp10 + meta.tmp11;
        meta.tmp14 = meta.tmp14 + meta.tmp15;

        meta.tmp18 = meta.tmp18 + meta.tmp19;
        meta.tmp22 = meta.tmp22 + meta.tmp23;
        meta.tmp26 = meta.tmp26 + meta.tmp27;
        meta.tmp28 = meta.tmp28 + meta.tmp29;
        meta.tmp30 = meta.tmp30 + meta.tmp31;
    }

    action mult02() {
        meta.tmp0 = meta.tmp0 + meta.tmp2;
        meta.tmp4 = meta.tmp4 + meta.tmp6;
        meta.tmp8 = meta.tmp8 + meta.tmp10;
        meta.tmp12 = meta.tmp12 + meta.tmp14;

        meta.tmp16 = meta.tmp16 + meta.tmp18;
        meta.tmp20 = meta.tmp20 + meta.tmp22;
        hdr.calculation.tmp24 = hdr.calculation.tmp24 + meta.tmp26;
        meta.tmp28 = meta.tmp28 + meta.tmp30;
    }

    action mult03() {
        meta.tmp0S = meta.tmp0 >> 4;

        hdr.calculation.tmp24 = hdr.calculation.tmp24 + meta.tmp28;
    }

    action mult04() {
        meta.tmp8S = meta.tmp8 >> 4;

        meta.tmp4 = meta.tmp0S + meta.tmp4;
    }

    action mult05() {
        meta.tmp12 = meta.tmp8S + meta.tmp12;

        meta.tmp16S = meta.tmp16 >> 4;
    }

    action mult06() {
        meta.tmp20 = meta.tmp16S + meta.tmp20;

        meta.tmp4S = meta.tmp4 >> 8;
    }

    action mult07() {
        meta.tmp12 = meta.tmp4S + meta.tmp12;

        meta.tmp20S = meta.tmp20 >> 4;
    }

    action mult08() {
        hdr.calculation.tmp24 = meta.tmp20S + hdr.calculation.tmp24;

        hdr.calculation.reg1 = hash_copy5.get( meta.tmp12 );
    }

    apply {
        if (hdr.ipv4.isValid()) {
            if (hdr.calculation.isValid()) {
                meta.reg1_1 = hash_copy1.get( hdr.calculation.reg1 );
                reg1_table.apply();
                meta.reg1_2 = hash_copy2.get( hdr.calculation.reg2 );

                if (meta.reg1_1 & 0x2 == 0x2) {
                    meta.tmp0 = meta.reg1_2 << 1;
                }
                if (meta.reg1_1 & 0x1 == 0x1) {
                    meta.tmp0 = meta.tmp0 + meta.reg1_2;
                }

                if (meta.reg1_1 & 0x4 == 0x4) {
                    meta.tmp2 = meta.reg1_2 << 2;
                }
                if (meta.reg1_1 & 0x8 == 0x8) {
                    meta.tmp3 = meta.reg1_2 << 3;
                }

                if (meta.reg1_1 & 0x20 == 0x20) {
                    meta.tmp4 = meta.reg1_2 << 1;
                }
                if (meta.reg1_1 & 0x10 == 0x10) {
                    meta.tmp4 = meta.tmp4 + meta.reg1_2;
                }

                if (meta.reg1_1 & 0x40 == 0x40) {
                    meta.tmp6 = meta.reg1_2 << 2;
                }
                if (meta.reg1_1 & 0x80 == 0x80) {
                    meta.tmp7 = meta.reg1_2 << 3;
                }

                if (meta.reg1_1 & 0x200 == 0x200) {
                    meta.tmp8 = meta.reg1_2 << 1;
                }
                if (meta.reg1_1 & 0x100 == 0x100) {
                    meta.tmp8 = meta.tmp8 + meta.reg1_2;
                }

                if (meta.reg1_1 & 0x400 == 0x400) {
                    meta.tmp10 = meta.reg1_2 << 2;
                }
                if (meta.reg1_1 & 0x800 == 0x800) {
                    meta.tmp11 = meta.reg1_2 << 3;
                }

                if (meta.reg1_1 & 0x2000 == 0x2000) {
                    meta.tmp12 = meta.reg1_2 << 1;
                }
                if (meta.reg1_1 & 0x1000 == 0x1000) {
                    meta.tmp12 = meta.tmp12 + meta.reg1_2;
                }

                if (meta.reg1_1 & 0x4000 == 0x4000) {
                    meta.tmp14 = meta.reg1_2 << 2;
                }
                if (meta.reg1_1 & 0x8000 == 0x8000) {
                    meta.tmp15 = meta.reg1_2 << 3;
                }

                meta.reg2_1 = hash_copy3.get( hdr.calculation.reg1 );
                reg2_table.apply();
                meta.reg2_2 = hash_copy4.get( hdr.calculation.reg2 );

                if (meta.reg2_1 & 0x20000 == 0x20000) {
                    meta.tmp16 = meta.reg2_2 << 1;
                }
                if (meta.reg2_1 & 0x10000 == 0x10000) {
                    meta.tmp16 = meta.tmp16 + meta.reg2_2;
                }
                
                if (meta.reg2_1 & 0x40000 == 0x40000) {
                    meta.tmp18 = meta.reg2_2 << 2;
                }
                if (meta.reg2_1 & 0x80000 == 0x80000) {
                    meta.tmp19 = meta.reg2_2 << 3;
                }

                if (meta.reg2_1 & 0x200000 == 0x200000) {
                    meta.tmp20 = meta.reg2_2 << 1;
                }
                if (meta.reg2_1 & 0x100000 == 0x100000) {
                    meta.tmp20 = meta.tmp20 + meta.reg2_2;
                }
                
                if (meta.reg2_1 & 0x400000 == 0x400000) {
                    meta.tmp22 = meta.reg2_2 << 2;
                }
                if (meta.reg2_1 & 0x800000 == 0x800000) {
                    meta.tmp23 = meta.reg2_2 << 3;
                }

                if (meta.reg2_1 & 0x2000000 == 0x2000000) {
                    hdr.calculation.tmp24 = meta.reg2_2 << 1;
                }
                if (meta.reg2_1 & 0x1000000 == 0x1000000) {
                    hdr.calculation.tmp24 = hdr.calculation.tmp24 + meta.reg2_2;
                }

                if (meta.reg2_1 & 0x4000000 == 0x4000000) {
                    meta.tmp26 = meta.reg2_2 << 2;
                }
                if (meta.reg2_1 & 0x8000000 == 0x8000000) {
                    meta.tmp27 = meta.reg2_2 << 3;
                }
                if (meta.reg2_1 & 0x10000000 == 0x10000000) {
                    meta.tmp28 = meta.reg2_2 << 4;
                }
                if (meta.reg2_1 & 0x20000000 == 0x20000000) {
                    meta.tmp29 = meta.reg2_2 << 5;
                }
                if (meta.reg2_1 & 0x40000000 == 0x40000000) {
                    meta.tmp30 = meta.reg2_2 << 6;
                }
                if (meta.reg2_1 & 0x80000000 == 0x80000000) {
                    meta.tmp31 = meta.reg2_2 << 7;
                }

                mult01();

                mult02();

                mult03();

                mult04();

                mult05();

                mult06();

                mult07();

                mult08();

                returnToPipe1();
            } else {
                // forward packet normally if its not a calculation packet
                static_ipv4_fowarding_multiply.apply();
            }
        }
    }
}

    /*********************  D E P A R S E R  ************************/

control IngressDeparserMultiply(packet_out pkt,
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

parser EgressParserMultiply(packet_in        pkt,
    /* User */
    out my_egress_headers_t          hdr,
    out my_egress_metadata_t         meta,
    /* Intrinsic */
    out egress_intrinsic_metadata_t  eg_intr_md)
{
    /* This is a mandatory state, required by Tofino Architecture */
    state start {
        pkt.extract(eg_intr_md);

        transition accept;
    }
}

    /***************** M A T C H - A C T I O N  *********************/

control EgressMultiply(
    /* User */
    inout my_egress_headers_t                          hdr,
    inout my_egress_metadata_t                         meta,
    /* Intrinsic */    
    in    egress_intrinsic_metadata_t                  eg_intr_md,
    in    egress_intrinsic_metadata_from_parser_t      eg_prsr_md,
    inout egress_intrinsic_metadata_for_deparser_t     eg_dprsr_md,
    inout egress_intrinsic_metadata_for_output_port_t  eg_oport_md)
{
    apply {}
}

    /*********************  D E P A R S E R  ************************/

control EgressDeparserMultiply(packet_out pkt,
    /* User */
    inout my_egress_headers_t                       hdr,
    in    my_egress_metadata_t                      meta,
    /* Intrinsic */
    in    egress_intrinsic_metadata_for_deparser_t  eg_dprsr_md)
{
    apply {    
        pkt.emit(hdr);
    }
}
