#!/usr/bin/env python3
import os
import stat
import yaml
import sys

clusterfile="/home/niteesh/github/ibm/niteesh/tools/tmp/klcOpen_analysis/cluster.yml"
keylimefile="/etc/default/keylime"

def main(hostname):

    found = False

    try:
        _fd = open(clusterfile,'r')
        _clusterdict = yaml.safe_load(_fd)
        _fd.close() 

    except Exception as e:
        print('## ERROR: failed to read cluster file %s: %s'%(clusterfile, str(e)))
        exit(1)

    if not 'services' in _clusterdict: return {}
    if not 'keylime' in _clusterdict['services']: return {}

    kldict = dict()
    kldict1 = { k.lower(): v for k,v in (_clusterdict['services']['keylime']).items() }
    kldict.update(kldict1)
      
    nodekinds = ["server_node","agent_node"]
    for kind in nodekinds:
        for host in _clusterdict[kind]:
            if host["hostname"] == hostname:
                found = True
                kldict.update({"node_name": host["hostname"], 
                    "cloud_agent_cloud_agent_ip": host["hostIP"],
                    "cloud_agent_agent_uuid": host["uuid"], 
                    "network_device": host["network"],
                    "node_order": host["order"]})
        
    if found is True:
        try:
            _fd2 = open(keylimefile, 'w')
            for key in kldict.keys():
                _fd2.write("export KEYLIME_%s=%s\n"%(key.upper(),str(kldict[key])))
            _fd2.close()
        except Exception as e:
            print('## ERROR: failed to write %s: %s'%(keylimefile, str(e)))
            exit(1)

        os.chmod(keylimefile, stat.S_IROTH+stat.S_IRUSR+stat.S_IRGRP+stat.S_IWUSR)

    else:
        print('## ERROR: failed to find hostname %s in %s'%(hostname,clusterfile))
        exit(1)

    exit(0)

if __name__ == "__main__":
   main(sys.argv[1])
