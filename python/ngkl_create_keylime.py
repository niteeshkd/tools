#!/usr/bin/env python3                                                                                                                
import platform
import os
import stat
import json
import yaml
import sys
from optparse import OptionParser


def main():
    bname = os.path.basename(sys.argv[0])
    parser = OptionParser("usage: %s -u <undercloudfile>"%(bname))
    parser.add_option("-u", "--undercloud", \
                       dest="undercloud", \
                       default=None, \
                       help="undercloud file")
    parser.add_option("-f", "--keylimedefaults", \
                      dest="keylimedefaults", \
                      default="/etc/default/keylime", \
                      help="target file for keylime defaults")
    (options,args) = parser.parse_args()

    if not options.undercloud:
        parser.error("undercloud file (-u/--undercloud) is required")

    # get keylime configuration: exit if none exists
    keylimedict = keylimedict_get(options.undercloud)
    if keylimedict and len(keylimedict) == 0:
        print("Keylime dictionary is empty!")
        exit(1)

    keylimedict_write(keylimedict, options.keylimedefaults)
    return 0

# #################################################
# extract keylime configuration from the undercloud file
# #################################################

def keylimedict_get(undercloudfile):

    try:
        _fd = open(undercloudfile,'r')
        _underclouddict = yaml.safe_load(_fd)
        _fd.close()
    except Exception as e:
        print('## ERROR: failed to read undercloud file %s: %s'%(undercloudfile, str(e)))
        exit(1)

    if not 'services' in _underclouddict: return {}
    if not 'keylime' in _underclouddict['services']: return {}

    kldict = dict()            
    kldict2 = { k.lower(): v for k,v in (_underclouddict['services']['keylime']).items() }
    kldict.update(kldict2)
    return kldict

# #################################################
# write back the keylime dictionary to /etc/default/keylime
# #################################################

def keylimedict_write (keylimedict, filename):
    try:
        _edk = open(filename, 'w')
        _counter = 0
        for key in keylimedict.keys():
            _edk.write("export KEYLIME_%s=%s\n"%(key.upper(),str(keylimedict[key])))
            _counter += 1
        _edk.close()

        os.chmod(filename, stat.S_IROTH+stat.S_IRUSR+stat.S_IRGRP+stat.S_IWUSR)

        #print('## Wrote %d entries to %s'%(_counter,filename))
        return
    except Exception as e:
        print("## ERROR: failed to write file %s: %s\n"%(filename, str(e)))
        exit(1)

main()
exit(0)
