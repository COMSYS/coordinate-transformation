/*
    Coordinate Transformation
    Copyright (c) 2021 
	
	Authors: Ike Kunze, René Glebke, Jan Scheiper
	E-mail: inp@comsys.rwth-aachen.de
*/

#pragma once

#include <arpa/inet.h> 
#include <unistd.h>
#include "helpers.h"

// disable padding for all structs which are network headers
#pragma pack(push, 1)
struct spherical_payload {
    int32_t radius;
    uint32_t phi;
    uint32_t theta;
    int32_t x;
    int32_t y;
    int32_t z;
    uint64_t start_ts;
    uint64_t end_ts;

    // convert to host byte order
    void to_h() {
        radius = ntohl(radius);
        phi = ntohl(phi);
        theta = ntohl(theta);
        x = ntohl(x);
        y = ntohl(y);
        z = ntohl(z);
        start_ts = ntohll(start_ts);
        end_ts = ntohll(end_ts);
    }

    // convert to network byte order
    void to_n() {
        radius = htonl(radius);
        phi = htonl(phi);
        theta = htonl(theta);
        x = htonl(x);
        y = htonl(y);
        z = htonl(z);
        start_ts = htonll(start_ts);
        end_ts = htonll(end_ts);
    }
};

struct timing_headers {
    uint8_t hops;
    uint64_t hop1;
    uint64_t hop2;

    // convert to host byte order
    void to_h() {
        hop1 = ntohll(hop1);
        hop2 = ntohll(hop2);
    }

    // convert to network byte order
    void to_n() {
        hop1 = htonll(hop1);
        hop2 = htonll(hop2);
    }
};

struct update_matrix_payload {
    uint32_t target_addr;
    double matrix[9];
    double translate[3];

    void to_h() {
        target_addr = ntohl(target_addr);
        for (uint8_t i = 0; i < 9; i++) {
            matrix[i] = ntohd(matrix[i]);
        }
        for (uint8_t i = 0; i < 3; i++) {
            translate[i] = ntohd(translate[i]);
        }
    }

    void to_n() {
        target_addr = htonl(target_addr);
        for (uint8_t i = 0; i < 9; i++) {
            matrix[i] = htond(matrix[i]);
        }
        for (uint8_t i = 0; i < 3; i++) {
            translate[i] = htond(translate[i]);
        }
    }
};
#pragma pack(pop)

#ifndef USE_APPROX

struct MatrixTableEntry {
    double matrix[9];
    double translate[3];

    static MatrixTableEntry from_payload(update_matrix_payload* pl) {
        MatrixTableEntry result;
        for (uint8_t i = 0; i < 9; i++) {
            result.matrix[i] = pl->matrix[i];
        }
        for (uint8_t i = 0; i < 3; i++) {
            result.translate[i] = pl->translate[i];
        }
        return result;
    }
};

#else

struct MatrixTableEntry {
    int32_t matrix[9];
    int32_t translate[3];

    static MatrixTableEntry from_payload(update_matrix_payload* pl) {
        MatrixTableEntry result;
        for (uint8_t i = 0; i < 9; i++) {
            result.matrix[i] = double_to_fp(pl->matrix[i]);
        }
        for (uint8_t i = 0; i < 3; i++) {
            result.translate[i] = double_to_fp(pl->translate[i]);
        }
        return result;
    }

    void print() {
        std::cout << matrix[0] << "\t" << matrix[1] << "\t" << matrix[2] << "\t" << translate[0] << std::endl;
        std::cout << matrix[3] << "\t" << matrix[4] << "\t" << matrix[5] << "\t" << translate[1] << std::endl;
        std::cout << matrix[6] << "\t" << matrix[7] << "\t" << matrix[8] << "\t" << translate[2] << std::endl;
    }
};

#endif