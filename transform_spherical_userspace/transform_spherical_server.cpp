/*
    Coordinate Transformation
    Copyright (c) 2021 
	
	Authors: Ike Kunze, René Glebke, Jan Scheiper
	E-mail: inp@comsys.rwth-aachen.de
*/

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h> 
#include <sys/socket.h> 
#include <arpa/inet.h> 
#include <netinet/in.h> 
#include <string>
#include <iostream>
#include <math.h>
#include <cstring>
#include <thread>
#include <mutex>
#include <map>
#include <iomanip>

#include "defines.h"
#include "helpers.h"
#include "structs.h"

static int32_t FP_PI = 0, FP_2PI = 0;
static std::map<uint32_t, MatrixTableEntry> matrix_table;
static std::mutex matrix_table_mutex;

int32_t sin_approx(int32_t input) { // adapted from http://mooooo.ooo/chebyshev-sine-approximation/
    const int64_t coeff1 = -3481369351;
    const int64_t coeff2 = 227491688;
    const int64_t coeff3 = -5961589;
    const int64_t coeff4 = 86665;
    const int64_t coeff5 = -802;
    const int64_t coeff6 = 4;

    if (input >= FP_PI || input <= -FP_PI) {
        input = input % FP_2PI;

        if (input >= FP_PI) {
            input -= FP_2PI;
        }
        if (input <= -FP_PI) {
            input += FP_2PI;
        }
    }

    int64_t x2 = multiply_large(input , input, FIX_POINT_EXPONENT);  

    int64_t tmp = coeff6;
    tmp = multiply_large(tmp, x2, FIX_POINT_EXPONENT) + coeff5;
    tmp = multiply_large(tmp, x2, FIX_POINT_EXPONENT) + coeff4;
    tmp = multiply_large(tmp, x2, FIX_POINT_EXPONENT) + coeff3;
    tmp = multiply_large(tmp, x2, FIX_POINT_EXPONENT) + coeff2;
    tmp = multiply_large(tmp, x2, FIX_POINT_EXPONENT) + coeff1;

    tmp = multiply_large((int64_t)input, tmp, FPE_CALC);

    return multiply(input - FP_PI, multiply(input + FP_PI, (int32_t)tmp, FIX_POINT_EXPONENT), FIX_POINT_EXPONENT);
}

int32_t cos_approx(int32_t input) {
    return sin_approx(input + (FP_PI >> 1));
}

void MatrixUpdateThread(bool* keep_running, bool* should_exit, bool enable_output) {
    int server, rv;

    struct sockaddr_in bind_address;

    bind_address.sin_family = AF_INET;
    bind_address.sin_port = htons(16400);
    bind_address.sin_addr.s_addr = INADDR_ANY;

    server = socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
	if (server == -1) {
		perror("[MatrixUpdate] Error while creating socket");
		return;
	}

    int opt = 1;
	rv = setsockopt(server, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));
	if (rv != 0 ) {
		perror("[MatrixUpdate] Error while setting socket option");
		return;
	}

	rv = bind(server, (struct sockaddr*)(&bind_address), sizeof(bind_address));
	if (rv != 0 ) {
		perror("[MatrixUpdate] Error while binding socket");
		return;
	}

    rv = listen(server, 10);
    if (rv != 0 ) {
		perror("[MatrixUpdate] Error while socket tried to listen");
		return;
	}

    char input_buffer[1500];
    char ok_msg[] = "ok";

    while(*keep_running) {
        struct sockaddr_in client_address;
        socklen_t client_address_length = sizeof(client_address);
        int sock = accept(server, (struct sockaddr*)&client_address, &client_address_length);

        int recv_size = recv(sock, &input_buffer, 1500, 0);

        if (recv_size < 0) {
            perror("[MatrixUpdate] Receive error");
            close(sock);
            continue;
        }

        if (recv_size < 4) {
            std::cout << "[MatrixUpdate] Invalid packet of size " << recv_size << std::endl;
            close(sock);
            continue;
        }

        if (strncmp(input_buffer, "exit", 4) == 0) {
            *should_exit = true;
            *keep_running = false;

            send(sock, &ok_msg, strlen(ok_msg), 0);
            close(sock);
            continue;
        }

        if (recv_size < (int)sizeof(update_matrix_payload)) {
            std::cout << "[MatrixUpdate] Invalid packet of size " << recv_size << std::endl;
            close(sock);
            continue;
        }

        update_matrix_payload* pl = (update_matrix_payload*)input_buffer;
        pl->to_h();

        matrix_table_mutex.lock();
        matrix_table[pl->target_addr] = MatrixTableEntry::from_payload(pl);
        matrix_table_mutex.unlock();

        // matrix_table[pl->target_addr].print();

        if (enable_output) {
            std::cout << "[MatrixUpdate] Adding/updating transformation matrix for IP " << format_addr(pl->target_addr) << std::endl;
            std::cout << std::setprecision(3) << pl->matrix[0] << "\t" << pl->matrix[1] << "\t" << pl->matrix[2] << "\t" << pl->translate[0] << std::endl;
            std::cout << std::setprecision(3) << pl->matrix[3] << "\t" << pl->matrix[4] << "\t" << pl->matrix[5] << "\t" << pl->translate[1] << std::endl;
            std::cout << std::setprecision(3) << pl->matrix[6] << "\t" << pl->matrix[7] << "\t" << pl->matrix[8] << "\t" << pl->translate[2] << std::endl;
        }

        send(sock, &ok_msg, strlen(ok_msg), 0);
        close(sock);
    }
}

int main(int argc, char** argv) {
    FP_PI = double_to_fp(M_PI);
    FP_2PI = double_to_fp(2.0 * M_PI);

    std::string bind_addr;
    int bind_port = 10000;
    int send_port = -1;

    int c;
    bool silent = false;
    bool enable_timing_headers = false;
    bool enable_verbose = false;
    while ((c = getopt (argc, argv, "a:p:r:stvh")) != -1) {
        switch (c) {
            case 'a':
                bind_addr = std::string(optarg);
                break;
            case 'p':
                bind_port = atoi(optarg);
                break;
            case 's':
                silent = true;
                break;
            case 't':
                enable_timing_headers = true;
                break;
            case 'v':
                enable_verbose = true;
                break;
            case 'r':
                send_port = atoi(optarg);
                break;
            case 'h':
                #ifdef USE_APPROX
                std::cout << "Program was compiled in approximation mode." << std::endl;
                #endif
                std::cout << "Usage: transform_spherical_server" << std::endl;
                std::cout << "  -a: Bind address (Default: 0.0.0.0)" << std::endl;
                std::cout << "  -p: Bind port (Default: 10000)" << std::endl;
                std::cout << "  -s: Silent mode, do not output each received packet." << std::endl;
                std::cout << "  -t: Enable timing headers" << std::endl;
                std::cout << "  -v: Enable verbose output" << std::endl;
                std::cout << "  -r: Send port (Default: bind port)" << std::endl;
                return 0;
            case '?':
                return 1;
            default:
                abort();
        }
    }

    #ifdef USE_APPROX
    std::cout << "Program was compiled in approximation mode." << std::endl;
    #endif

    std::cout << "Binding server to " << bind_addr << ":" << bind_port << std::endl;

    std::cout << "Fix point exponent: " << FIX_POINT_EXPONENT << std::endl;

    if (silent) {
        std::cout << "Silent mode engaged." << std::endl;
    }

    if (enable_timing_headers) {
        std::cout << "Timing headers enabled." << std::endl;
    }

    int server_sockfd, rv;
    char input_buffer[1500];

    struct sockaddr_in bind_address;
    struct sockaddr_in client_address;
    socklen_t client_address_length = sizeof(client_address);

    bind_address.sin_family = AF_INET;
    bind_address.sin_port = htons(bind_port);
    if (bind_addr == "") {
        bind_address.sin_addr.s_addr = INADDR_ANY;
    } else {
        inet_pton(AF_INET, bind_addr.c_str(), &(bind_address.sin_addr));
    }

    server_sockfd = socket(AF_INET, SOCK_DGRAM, IPPROTO_IP);
	if (server_sockfd == -1) {
		perror("Error while creating socket");
		return 1;
	}

    int opt = 1;
	rv = setsockopt(server_sockfd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));
	if (rv != 0 ) {
		perror("Error while setting socket option");
		return 1;
	}

	rv = bind(server_sockfd, (struct sockaddr*)(&bind_address), sizeof(bind_address));
	if (rv != 0 ) {
		perror("Error while binding socket");
		return 1;
	}

    bool should_exit = false;
    bool keep_mut_running = true;

    auto matrixUpdateThread = std::thread(MatrixUpdateThread, &keep_mut_running, &should_exit, !silent || enable_verbose);

    uint64_t start_ts = get_timestamp(); // all returned timestamps are relative to the start time

    while(!should_exit) {
        char* input_data = input_buffer;
        int recv_bytes = recvfrom(server_sockfd, input_buffer, 1500, MSG_WAITALL, (struct sockaddr*)&client_address, &client_address_length);

        int resp_size = sizeof(spherical_payload);
        if (enable_timing_headers) {
            resp_size += sizeof(timing_headers);
        }

        if (recv_bytes < resp_size) {
            if (!silent) {
                std::cout << "Invalid packet (too small, " << recv_bytes << " < " << resp_size << ")" << std::endl;
            }
            continue;
        }

        if (!silent) {
            std::cout << "Got request" << std::endl;
        }

        if (enable_timing_headers && enable_verbose) {
            timing_headers th;
            memcpy(&th, input_data, sizeof(timing_headers));
            th.to_h();

            std::cout << "timing: hops = " << (int)th.hops << ", hop1 = " << th.hop1 << ", hop2 = " << th.hop2 << std::endl;
        }

        spherical_payload* pl = (spherical_payload*)(enable_timing_headers ? input_data + sizeof(timing_headers) : input_data);

        // convert to host byte order
        pl->to_h();

        // lock mutex so the table doesn't change during the computation
        matrix_table_mutex.lock();

        // record start of computation timestamp
        pl->start_ts = get_timestamp() - start_ts;

        #ifndef USE_APPROX

        // compute coordinate transform
        double radius = fp_to_double(pl->radius);
        double phi = fp_to_double(pl->phi);
        double theta = fp_to_double(pl->theta);

        double sinTheta = sin(theta);

        double x = radius * sinTheta * cos(phi);
        double y = radius * sinTheta * sin(phi);
        double z = radius * cos(theta);

        auto matrix_table_match = matrix_table.find(ntohl(client_address.sin_addr.s_addr));

        if (matrix_table_match != matrix_table.end()) {
            double* matrix = matrix_table_match->second.matrix;
            double* translate = matrix_table_match->second.translate;

            double _x = x * matrix[0] + y * matrix[1] + z * matrix[2] + translate[0];
            double _y = x * matrix[3] + y * matrix[4] + z * matrix[5] + translate[1];
            double _z = x * matrix[6] + y * matrix[7] + z * matrix[8] + translate[2];

            x = _x, y = _y, z = _z;
        }

        pl->x = double_to_fp(x);
        pl->y = double_to_fp(y);
        pl->z = double_to_fp(z);

        #else

        // compute coordinate transform
        int32_t temp = multiply(pl->radius, sin_approx(pl->theta), FIX_POINT_EXPONENT);

        int32_t x = multiply(temp, cos_approx(pl->phi), FIX_POINT_EXPONENT);
        int32_t y = multiply(temp, sin_approx(pl->phi), FIX_POINT_EXPONENT);
        int32_t z  = multiply(pl->radius, cos_approx(pl->theta), FIX_POINT_EXPONENT);

        auto matrix_table_match = matrix_table.find(ntohl(client_address.sin_addr.s_addr));

        if (matrix_table_match != matrix_table.end()) {
            int32_t* matrix = matrix_table_match->second.matrix;
            int32_t* translate = matrix_table_match->second.translate;

            int32_t _x = multiply(matrix[0], x, FIX_POINT_EXPONENT) + multiply(matrix[1], y, FIX_POINT_EXPONENT) + multiply(matrix[2], z, FIX_POINT_EXPONENT) + translate[0];
            int32_t _y = multiply(matrix[3], x, FIX_POINT_EXPONENT) + multiply(matrix[4], y, FIX_POINT_EXPONENT) + multiply(matrix[5], z, FIX_POINT_EXPONENT) + translate[1];
            int32_t _z = multiply(matrix[6], x, FIX_POINT_EXPONENT) + multiply(matrix[7], y, FIX_POINT_EXPONENT) + multiply(matrix[8], z, FIX_POINT_EXPONENT) + translate[2];

            x = _x, y = _y, z = _z;
        }

        pl->x = x;
        pl->y = y;
        pl->z = z;

        #endif

        // record end of computation timestamp
        pl->end_ts = get_timestamp() - start_ts;

        // unlock mutex so we can update the table again
        matrix_table_mutex.unlock();

        // convert to network byte order
        pl->to_n();

        // return response
        client_address.sin_port = htons(enable_timing_headers ? 10001 : 10000);

        #ifndef USE_APPROX
        if (enable_verbose) {
            std::cout << "spherical: radius = " << radius << ", phi = " << phi << ", theta = " << theta << std::endl;
        }
        #endif

        if (send_port != -1) {
            client_address.sin_port = htons(send_port);
        }

        sendto(server_sockfd, input_data, recv_bytes, MSG_CONFIRM, (const struct sockaddr*)&client_address, client_address_length);
    }

    keep_mut_running = false;
    matrixUpdateThread.join();

    return 0;
}