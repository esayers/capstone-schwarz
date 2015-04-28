#!/usr/bin/python
# Client for sending data to FPGA

import socket
import ctypes
import os
import tarfile
import xml.etree.ElementTree as ET
import sys
import tempfile
import struct
import shutil

# Union class for packing data
class Pack(ctypes.Union):
    _fields_ = [("fl", ctypes.c_float * 65),
                ("ch", ctypes.c_char * 4 * 65)]

# Error if there is the wrong number of arguments
if len(sys.argv) != 2:
    print "Client requires name of IQ file as an argument"
    sys.exit()

# Try to open the file specified by argument
filename = sys.argv[1]

try:
    tar = tarfile.open(filename)
except (IOError):
    print "Could not open specified file"
    sys.exit()

tempfile.mkdtemp("tmp")
tar.extractall("tmp")

for name in  tar.getnames():
    if ".xml" in name:
        xmlname = name
        break

tree = ET.parse("tmp/" + xmlname)
root = tree.getroot()

samples = root.find('Samples').text
dataname = root.find('DataFilename').text
clock = root.find('Clock').text

#s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
#s.connect(('192.168.1.10', 7))

with open("tmp/" + dataname, "rb") as df:
    fl = df.read(256)
    while len(fl) == 256:
        sendBytes = bytes()
        unpacked = struct.unpack('f'*64, fl)
        sendBytes = sendBytes.join(struct.pack('!f', val) for val in unpacked)
        print b
        fl = df.read(256)


shutil.rmtree("tmp")
#p = Pack()
#for i in range(1,65):
#    p.fl[i] = ctypes.c_float(i)


#s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
#s.connect(('192.168.1.10', 7))
#s.send(p.ch)
#while True:
#    buf = s.recv(256)
#    if len(buf) > 0:
#        print buf
#        break
