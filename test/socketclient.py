#!/usr/bin/python


import sys
import optparse
import os
import socket
import errno
import plistlib


SOCKET_DIR = "/tmp"
SOCKET_NAME = "se.gu.it.dafgu_migration_status"
MAX_MSG_SIZE = 65536


def main(argv):
    p = optparse.OptionParser()
    p.set_usage("""Usage: %prog [options]""")
    p.add_option("-v", "--verbose", action="store_true",
                 help="Verbose output.")
    options, argv = p.parse_args(argv)
    if len(argv) != 3:
        print >>sys.stderr, p.get_usage()
        return 1
    
    status = int(argv[1])
    message = argv[2].decode("utf-8")
    
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
    msg = plistlib.writePlistToString({
            "DAFGUMigrationStatus": status,
            "DAFGUMigrationMessage": message,
        })
    for item in os.listdir(SOCKET_DIR):
        if item.startswith(SOCKET_NAME):
            socket_path = os.path.join(SOCKET_DIR, item)
            print "Sending message to %s" % socket_path
            try:
                sock.sendto(msg, socket_path)
            except socket.error, e:
                if e[0] == errno.ECONNREFUSED:
                    print "Removing stale socket %s" % (socket_path)
                    os.unlink(socket_path)
                else:
                    print "%s failed: %s" % (socket_path, e)
    
    return 0
    

if __name__ == '__main__':
    sys.exit(main(sys.argv))
    
