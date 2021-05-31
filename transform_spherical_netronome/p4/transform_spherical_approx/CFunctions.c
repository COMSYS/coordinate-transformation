/*
    Coordinate Transformation
    Copyright (c) 2021 
	
	Authors: Ike Kunze, René Glebke, Jan Scheiper
	E-mail: inp@comsys.rwth-aachen.de
*/

#include "pif_plugin.h"
#include "pif_plugin_metadata.h"
#include "pif_headers.h"
#include "pif_registers.h"
#include <stdint.h>
#include "include/defines.h"

#define FPE_CALC 35

int32_t multiply(int32_t a_input, int32_t b_input, uint8_t shift) {
    return (((int64_t)a_input) * ((int64_t)b_input)) >> shift;
}

int64_t multiply_large(int64_t a_input, int64_t b_input, uint8_t shift) {
    return (a_input * b_input) >> shift;
}

int32_t sin_approx(int32_t input) { // adapted from http://mooooo.ooo/chebyshev-sine-approximation/
    // constants have 35 bits of precision
    const uint8_t coeff1_bytes[8] = { 0xff,0xff,0xff,0xff,0x30,0x7e,0x84,0xf9 }; // -3481369351
    const int64_t coeff1 = *(int64_t*)coeff1_bytes;
    const int64_t coeff2 = 227491688;
    const int64_t coeff3 = -5961589;
    const int64_t coeff4 = 86665;
    const int64_t coeff5 = -802;
    const int64_t coeff6 = 4;

    int64_t x2, tmp;

    if (input >= FP_PI || input <= -FP_PI) {
        input = input % FP_2PI;

        if (input >= FP_PI) {
            input -= FP_2PI;
        }
        if (input <= -FP_PI) {
            input += FP_2PI;
        }
    }

    x2 = multiply_large(input, input, FIX_POINT_EXPONENT);

    tmp = coeff6;
    tmp = multiply_large(tmp, x2, FIX_POINT_EXPONENT) + coeff5;
    tmp = multiply_large(tmp, x2, FIX_POINT_EXPONENT) + coeff4;
    tmp = multiply_large(tmp, x2, FIX_POINT_EXPONENT) + coeff3;
    tmp = multiply_large(tmp, x2, FIX_POINT_EXPONENT) + coeff2;
    tmp = multiply_large(tmp, x2, FIX_POINT_EXPONENT) + coeff1;

    tmp = multiply_large((int64_t)input, tmp, FPE_CALC); // shift by 35 bits to get back into 25 bit land

    tmp = multiply(input + FP_PI, (int32_t)tmp, FIX_POINT_EXPONENT);
    tmp = multiply(input - FP_PI, (int32_t)tmp, FIX_POINT_EXPONENT);

    return tmp;
}

int32_t cos_approx(int32_t input) {
    return sin_approx(input + (FP_PI >> 1));
}

int pif_plugin_coordinate_transform(EXTRACTED_HEADERS_T* headers, ACTION_DATA_T* action_data)
{

    PIF_PLUGIN_spherical_T* hdr_spherical = pif_plugin_hdr_get_spherical(headers);
    PIF_PLUGIN_output_T* hdr_output = pif_plugin_hdr_get_output(headers);
    PIF_PLUGIN_ipv4_T* hdr_ipv4 = pif_plugin_hdr_get_ipv4(headers);

    uint8_t match_index = hdr_ipv4->srcAddr & 0xFF;

    __emem int32_t* matrix_a00 = (__emem int32_t*)pif_register_matrix_table_a00;
    __emem int32_t* matrix_a01 = (__emem int32_t*)pif_register_matrix_table_a01;
    __emem int32_t* matrix_a02 = (__emem int32_t*)pif_register_matrix_table_a02;
    __emem int32_t* matrix_a10 = (__emem int32_t*)pif_register_matrix_table_a10;
    __emem int32_t* matrix_a11 = (__emem int32_t*)pif_register_matrix_table_a11;
    __emem int32_t* matrix_a12 = (__emem int32_t*)pif_register_matrix_table_a12;
    __emem int32_t* matrix_a20 = (__emem int32_t*)pif_register_matrix_table_a20;
    __emem int32_t* matrix_a21 = (__emem int32_t*)pif_register_matrix_table_a21;
    __emem int32_t* matrix_a22 = (__emem int32_t*)pif_register_matrix_table_a22;
    __emem int32_t* matrix_t0 = (__emem int32_t*)pif_register_matrix_table_t0;
    __emem int32_t* matrix_t1 = (__emem int32_t*)pif_register_matrix_table_t1;
    __emem int32_t* matrix_t2 = (__emem int32_t*)pif_register_matrix_table_t2;

    int32_t sinPhi, cosPhi, sinTheta, cosTheta, temp;
    int32_t x, y, z;

    sinPhi = sin_approx(hdr_spherical->phi);
    cosPhi = cos_approx(hdr_spherical->phi);
    sinTheta = sin_approx(hdr_spherical->theta);
    cosTheta = cos_approx(hdr_spherical->theta);

    temp = multiply(sinTheta, hdr_spherical->radius, FIX_POINT_EXPONENT);

    x = multiply(temp, cosPhi, FIX_POINT_EXPONENT);
    y = multiply(temp, sinPhi, FIX_POINT_EXPONENT);
    z = multiply(hdr_spherical->radius, cosTheta, FIX_POINT_EXPONENT);

    hdr_output->x = multiply(x, matrix_a00[match_index], FIX_POINT_EXPONENT) +
        multiply(y, matrix_a01[match_index], FIX_POINT_EXPONENT) +
        multiply(z, matrix_a02[match_index], FIX_POINT_EXPONENT) +
        matrix_t0[match_index];

    hdr_output->y = multiply(x, matrix_a10[match_index], FIX_POINT_EXPONENT) +
        multiply(y, matrix_a11[match_index], FIX_POINT_EXPONENT) +
        multiply(z, matrix_a12[match_index], FIX_POINT_EXPONENT) +
        matrix_t1[match_index];

    hdr_output->z = multiply(x, matrix_a20[match_index], FIX_POINT_EXPONENT) +
        multiply(y, matrix_a21[match_index], FIX_POINT_EXPONENT) +
        multiply(z, matrix_a22[match_index], FIX_POINT_EXPONENT) +
        matrix_t2[match_index];

    return PIF_PLUGIN_RETURN_FORWARD;
}
