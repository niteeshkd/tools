#!/usr/bin/env python3
import os
import stat
import yaml
import json
import sys
import jsonschema
from jsonschema import validate
from os.path import exists

#keylime_file="/etc/default/keylime"
#schema_file="/etc/default/cluster_schema.json"
keylime_file="./keylime"
schema_file="./cluster_schema.json"

def validate_json(json_data):
    with open(schema_file, 'r') as file:
        cluster_schema = json.load(file)

    try:
        validate(instance=json_data, schema=cluster_schema)
    except jsonschema.exceptions.ValidationError as err:
        print(err)
        err = "Cluster data is invalid"
        return False, err

    message = "Cluster data is valid"
    return True, message

    
def json_yaml_read(_fd):
    """
    First try to read the file as a json file. If it fails then read as an yaml file
    """
    if not _fd:
        return None

    cluster_data = _fd.read()
    cluster_dict = dict()
    valid_json = True

    try:
        cluster_dict = json.loads(cluster_data)
    except:
        valid_json = False
    if not valid_json:    
        try:
            cluster_dict = yaml.safe_load(cluster_data)
        except yaml.YAMLError as exc:
            print(f"## ERROR: failed to parse file {_fd.name}: {str(exc)}")
            exit(1)

    is_valid, msg = validate_json(cluster_dict)
    if is_valid:
        return cluster_dict
    else:
        print(msg)
        return None

def main(argv):
    #Check the existence of the cluster file
    if exists("./cluster.json"):
        cluster_file="./cluster.json"
    else:
        cluster_file="./cluster.yml"

    #Read the cluster file
    try:
        _fd = open(cluster_file,'r')
        _clusterdict = json_yaml_read(_fd)
        _fd.close() 
    except Exception as e:
        print('## ERROR: failed to read cluster file {}: {}'.format(cluster_file, str(e)))
        exit(1)

    if _clusterdict is None:
        exit(1)

    kldict = dict()
    kldict1 = { k.lower(): v for k,v in (_clusterdict['services']['keylime']).items() }
    kldict.update(kldict1)
    kldict2 = { k.lower(): v for k,v in (_clusterdict['services']['keylimecontainer']).items() }
    kldict.update(kldict2)
    
    print (argv)

    print (kldict)

    if argv: 
        found = False
        hostname = sys.argv[1]
        for host in _clusterdict['nodes']:
            if host["hostname"] == hostname:
                found = True
                kldict.update({"node_name": host["hostname"], 
                    "cloud_agent_cloudagent_ip": host["hostIP"],
                    "cloud_agent_agent_uuid": host["uuid"]}) 
        if found is False:
            print('## ERROR: failed to find hostname {} in the cluster file {}'.format(hostname,cluster_file))
            exit(1)
         
    try:
        _fd2 = open(keylime_file, 'w')
        for key in kldict.keys():
            _fd2.write("export KEYLIME_%s=%s\n"%(key.upper(),str(kldict[key])))
        _fd2.close()
    except Exception as e:
        print('## ERROR: failed to write {}: {}'.format(keylime_file, str(e)))
        exit(1)

    os.chmod(keylime_file, stat.S_IROTH+stat.S_IRUSR+stat.S_IRGRP+stat.S_IWUSR)


    exit(0)

if __name__ == "__main__":
    main(sys.argv[1:])
