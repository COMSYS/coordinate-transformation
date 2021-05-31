.PHONY: all clean

all: transform_spherical_server

transform_spherical_server: transform_spherical_server.cpp helpers.h structs.h defines.h
	$(CXX) -Wall -lm -msse3 -O3 -pthread transform_spherical_server.cpp -o transform_spherical_server

clean:
	rm -f transform_spherical_server