/*
    Coordinate Transformation
    Copyright (c) 2021 
	
	Authors: Ike Kunze, René Glebke, Jan Scheiper
	E-mail: inp@comsys.rwth-aachen.de
*/

#pragma once

#include <arpa/inet.h> 
#include <unistd.h>
#include <math.h>
#include <time.h>
#include <string>
#include <sstream>

#include "defines.h"

// https://stackoverflow.com/a/59888886/1342618
uint64_t htonll(uint64_t x) {
    #if __BIG_ENDIAN__
        return x;
    #else
        return ((uint64_t)htonl((x) & 0xFFFFFFFFLL) << 32) | htonl((x) >> 32);
    #endif
}

// https://stackoverflow.com/a/59888886/1342618
uint64_t ntohll(uint64_t x) {
    #if __BIG_ENDIAN__
        return x;
    #else
        return ((uint64_t)ntohl((x) & 0xFFFFFFFFLL) << 32) | ntohl((x) >> 32);
    #endif
}

// straight from the CPython sources (/Objects/floatobject.c)
double htond(double x) {
    #if __BIG_ENDIAN__
        return x;
    #else
        char* p = (char*)&x;

        double ret;
        char buf[8];
        char *d = &buf[7];
        int i;

        for (i = 0; i < 8; i++) {
            *d-- = *p++;
        }
        memcpy(&ret, buf, 8);

        return ret;
    #endif
}

double ntohd(double x) {
    return htond(x);
}

// convert fix point integer to double
inline double fp_to_double(int64_t input) {
    return (double)input / static_cast<double>(1 << FIX_POINT_EXPONENT);
}

// convert double back to fix point integer
inline int64_t double_to_fp(double input) {
    return (int64_t)round(input * static_cast<double>(1 << FIX_POINT_EXPONENT));
}

// get nanosecond timestamp
uint64_t get_timestamp() {
    struct timespec tspec;

	timespec_get(&tspec, TIME_UTC);

    return (uint64_t)tspec.tv_nsec + (uint64_t)tspec.tv_sec * 1000000000;
}

inline int32_t multiply(int32_t a_input, int32_t b_input, uint8_t shift) {
    return (((int64_t)a_input) * ((int64_t)b_input)) >> shift;
}

inline int64_t multiply_large(int64_t a_input, int64_t b_input, uint8_t shift) {
    return (a_input * b_input) >> shift;
}

std::string format_addr(uint32_t ip_address) {
    std::stringstream out;

    out << ((ip_address >> 24) & 0xFF) << "." << ((ip_address >> 16) & 0xFF) << "." << ((ip_address >> 8) & 0xFF) << "." << (ip_address & 0xFF);

    return out.str();
}