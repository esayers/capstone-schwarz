#!/usr/bin/python
# Client for sending data to FPGA

import tarfile
import xml.etree.ElementTree as ET
import sys
import tempfile
import struct
import shutil

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


with open("sampleinfo", "w") as df:
    df.write(dataname + "\n")
    df.write(samples + '\n')
    df.write(clock + '\n')

shutil.rmtree("tmp")
