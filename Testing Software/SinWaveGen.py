import numpy
import struct

N = numpy.linspace(0,.08,6e6)
N = N * (1.57542e9 * numpy.pi * 2)
signal = numpy.sin(N)

IQ = struct.Struct("!ff")
with open("L1sin.bin", "wb") as f_out:

    for I in signal:
        f_out.write(IQ.pack(I,0))
    
