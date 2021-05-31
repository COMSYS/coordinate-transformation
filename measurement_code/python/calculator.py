"""
    Coordinate Transformation
    Copyright (c) 2021 
	
	Authors: Ike Kunze, René Glebke, Jan Scheiper
	E-mail: inp@comsys.rwth-aachen.de
"""

import math

def toSpherical(x, y, z):
    r = math.sqrt(x**2 + y**2 + z**2)
    phi = math.atan(y / x)
    theta = math.acos(z / r)

    return r, phi, theta

def toCartesian(r, phi, theta):
    x = r * math.sin(theta) * math.cos(phi)
    y = r * math.sin(theta) * math.sin(phi)
    z = r * math.cos(theta)

    return x, y, z

def matrixVectorMultiply3x3(matrix, vector):
    a1 = matrix[0]*vector[0] + matrix[1]*vector[1] + matrix[2]*vector[2]
    a2 = matrix[3]*vector[0] + matrix[4]*vector[1] + matrix[5]*vector[2]
    a3 = matrix[6]*vector[0] + matrix[7]*vector[1] + matrix[8]*vector[2]

    return a1, a2, a3

def matrixVectorMultiply3x4(matrix, vector):
    a1 = matrix[0]*vector[0] + matrix[1]*vector[1] + matrix[2]*vector[2] + matrix[3]*vector[3]
    a2 = matrix[4]*vector[0] + matrix[5]*vector[1] + matrix[6]*vector[2] + matrix[7]*vector[3]
    a3 = matrix[8]*vector[0] + matrix[9]*vector[1] + matrix[10]*vector[2] + matrix[11]*vector[3]

    return a1, a2, a3