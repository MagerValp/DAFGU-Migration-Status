#!/usr/bin/python


import sys
import optparse
from Foundation import *


SRV_NAME = u"se.gu.it.dafgu_migration_status"


def main(argv):
    p = optparse.OptionParser()
    p.set_usage("""Usage: %prog [options] status message""")
    p.add_option("-v", "--verbose", action="store_true",
                 help="Verbose output.")
    options, argv = p.parse_args(argv)
    if len(argv) != 3:
        print >>sys.stderr, p.get_usage()
        return 1
    
    status = int(argv[1])
    message = argv[2].decode("utf-8")
    
    srv_proxy = NSConnection.rootProxyForConnectionWithRegisteredName_host_(SRV_NAME, None)
    if not srv_proxy:
        sys.exit(u"Couldn't establish connection with '%s'" % SRV_NAME)
    
    print u"Setting status to %d %s" % (status, message)
    srv_proxy.setStatus_message_(status, message)
    
    return 0
    

if __name__ == '__main__':
    sys.exit(main(sys.argv))
    
