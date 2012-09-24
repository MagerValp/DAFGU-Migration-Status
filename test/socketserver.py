#!/usr/bin/python


import sys
import optparse
import os
import socket
import atexit
import signal


SOCKET_DIR = "."
SOCKET_NAME = "test_socket"
MAX_MSG_SIZE = 65536


def main(argv):
    p = optparse.OptionParser()
    p.set_usage("""Usage: %prog [options]""")
    p.add_option("-v", "--verbose", action="store_true",
                 help="Verbose output.")
    options, argv = p.parse_args(argv)
    if len(argv) != 1:
        print >>sys.stderr, p.get_usage()
        return 1
    
    random_id = os.urandom(8).encode("hex")
    socket_path = os.path.join(SOCKET_DIR, "%s.%s" % (SOCKET_NAME, random_id))
    @atexit.register
    def cleanup(*args, **kwargs):
        try:
            os.unlink(socket_path)
        except:
            pass
    
    signal.signal(signal.SIGHUP,  cleanup);
    signal.signal(signal.SIGINT,  cleanup);
    signal.signal(signal.SIGTERM, cleanup);
    signal.signal(signal.SIGABRT, cleanup);
    signal.signal(signal.SIGPIPE, cleanup);
    
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
    sock.bind(socket_path)
    
    while True:
        try:
            data, address = sock.recvfrom(MAX_MSG_SIZE)
            print repr(data), repr(address)
        except socket.error:
            break
    
    return 0
    

if __name__ == '__main__':
    sys.exit(main(sys.argv))
    
