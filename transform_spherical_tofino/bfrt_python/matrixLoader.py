"""
    Coordinate Transformation
    Copyright (c) 2021 
	
	Authors: Ike Kunze, René Glebke, Jan Scheiper
	E-mail: inp@comsys.rwth-aachen.de
"""

def main():
    import math, socket, struct

    # GLOBAL DEFINES

    FIX_POINT_EXPONENT = 25
    # BIT_SPLIT = 14
    keyShiftConstant = 2**FIX_POINT_EXPONENT
    resultShiftConstant = 2**FIX_POINT_EXPONENT

    print("FIX_POINT_EXPONENT = {fpe}".format(fpe=FIX_POINT_EXPONENT))

    # HELPER FUNCTIONS

    def actionName(action, a0, a1, a2):
        return "{action}_with_getMatrixRow{a0}{a1}{a2}".format(action=action, a0="P" if a0 >= 0 else "N", a1="P" if a1 >= 0 else "N", a2="P" if a2 >= 0 else "N")

    def fixp_repr(x):
        return int(round(abs(x * keyShiftConstant)))

    def format_addr(a):
        return "{b0}.{b1}.{b2}.{b3}".format(b0=a >> 24, b1 = 0xff & (a >> 16), b2 = 0xff & (a >> 8), b3 = 0xff & a)

    # MAIN PROGRAM CODE

    p4 = bfrt.transform_spherical_fastmp_split_multipipe_main.pipe


    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(("", 16400))
    server.listen(10)

    running = True

    print("Waiting for incoming connections")
    print()

    while running:
        sock, addr = server.accept()

        print("Connection from " + addr[0])

        data = sock.recv(1024)

        if data[:4] == b"exit":
            running = False
            sock.send(b"ok")
            sock.close()
            break

        if len(data) < 100:
            print("Invalid packet {size} < 100".format(size=len(data)))
            continue

        # the transform_spherical_fastmp version uses the egress for the final translation
        if "translation_table" in dir(p4.Ingress):
            translation_table = p4.Ingress.translation_table
        else:
            translation_table = p4.Egress.translation_table

        ip_addr, a00, a01, a02, a10, a11, a12, a20, a21, a22, t0, t1, t2 = struct.unpack("!Idddddddddddd", data)

        print("Adding/updating transformation matrix for IP {addr}".format(addr=format_addr(ip_addr)))
        print("{a00:.3f}\t{a01:.3f}\t{a02:.3f}\t{t0:.3f}".format(a00=a00, a01=a01, a02=a02, t0=t0))
        print("{a10:.3f}\t{a11:.3f}\t{a12:.3f}\t{t1:.3f}".format(a10=a10, a11=a11, a12=a12, t1=t1))
        print("{a20:.3f}\t{a21:.3f}\t{a22:.3f}\t{t2:.3f}".format(a20=a20, a21=a21, a22=a22, t2=t2))

        addFn = getattr(p4.Ingress.matrix_row1_table, actionName("add", a00, a01, a02))
        modFn = getattr(p4.Ingress.matrix_row1_table, actionName("mod", a00, a01, a02))

        try:
            modFn(ip_addr, fixp_repr(a00), fixp_repr(a01), fixp_repr(a02))
        except:
            addFn(ip_addr, fixp_repr(a00), fixp_repr(a01), fixp_repr(a02))

        addFn = getattr(p4.Ingress.matrix_row2_table, actionName("add", a10, a11, a12))
        modFn = getattr(p4.Ingress.matrix_row2_table, actionName("mod", a10, a11, a12))

        try:
            modFn(ip_addr, fixp_repr(a10), fixp_repr(a11), fixp_repr(a12))
        except:
            addFn(ip_addr, fixp_repr(a10), fixp_repr(a11), fixp_repr(a12))

        addFn = getattr(p4.Ingress.matrix_row3_table, actionName("add", a20, a21, a22))
        modFn = getattr(p4.Ingress.matrix_row3_table, actionName("mod", a20, a21, a22))

        try:
            modFn(ip_addr, fixp_repr(a20), fixp_repr(a21), fixp_repr(a22))
        except:
            addFn(ip_addr, fixp_repr(a20), fixp_repr(a21), fixp_repr(a22))

        addFn = getattr(translation_table, actionName("add", t0, t1, t2))
        modFn = getattr(translation_table, actionName("mod", t0, t1, t2))

        try:
            modFn(ip_addr, fixp_repr(t0), fixp_repr(t1), fixp_repr(t2))
        except:
            addFn(ip_addr, fixp_repr(t0), fixp_repr(t1), fixp_repr(t2))

        print()

        sock.send(b"ok")
        sock.close()

    server.close()

main()
