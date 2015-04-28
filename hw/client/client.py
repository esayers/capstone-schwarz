import socket
import ctypes

class Fpass(ctypes.Union):
    _fields_ = [("fl", ctypes.c_float * 64),
                ("ch", ctypes.c_char * 4 * 64)]

p = Fpass()
for i in range(0,64):
    p.fl[i] = ctypes.c_float(i)


s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(('192.168.1.10', 7))
s.send(p.ch)
while True:
    buf = s.recv(256)
    if len(buf) > 0:
        print buf
        break
