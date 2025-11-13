#!/usr/bin/env python3

"""
A utility for generating Keylime configuration variables
"""

import json
import os
import stat
import sys

from os.path import exists

import yaml
from jsonschema import exceptions as jsonschema_exceptions
from jsonschema import validate

#KEYLIME_FILE = "/etc/default/keylime"
#SCHEMA_FILE = "/etc/default/cluster_schema.json"

KEYLIME_FILE = "./keylime"
SCHEMA_FILE = "./cluster_schema.json"

def validate_json(json_data):
    """
    Validate JSON data against JSON schema
    """
    with open(SCHEMA_FILE, "r", encoding="utf-8") as file:
        cluster_schema = json.load(file)

    try:
        validate(instance=json_data, schema=cluster_schema)
    except jsonschema_exceptions.ValidationError as err:
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
    cluster_dict = {}

    try:
        cluster_dict = json.loads(cluster_data)
        valid_json = True
    except TypeError as exc:
        print(f"## WARNING: Could not parse JSON from text: {cluster_data} ({exc})")
        valid_json = False
    except json.JSONDecodeError as exc:
        print(f"## WARNING: JSON decode error: {exc}")
        valid_json = False
    if not valid_json:
        try:
            cluster_dict = yaml.safe_load(cluster_data)
        except yaml.YAMLError as exc:
            sys.exit(f"## ERROR: failed to parse file {_fd.name}: {str(exc)}")

    is_valid, msg = validate_json(cluster_dict)
    if is_valid:
        return cluster_dict
    print(msg)
    return None


def main(argv):
    """
    the main function
    """
    # Check the existence of the cluster file
    if exists("./cluster.json"):
        cluster_file = "./cluster.json"
    else:
        cluster_file = "./cluster.yml"

    # Read the cluster file
    with open(cluster_file, "r", encoding="utf-8") as _fd:
        _clusterdict = json_yaml_read(_fd)
    if _clusterdict is None:
        sys.exit(f"## ERROR: failed to read cluster file {cluster_file}")

    kldict = {}
    kldict1 = {k.lower(): v for k, v in (_clusterdict["services"]["keylime"]).items()}
    kldict.update(kldict1)
    kldict2 = {
        k.lower(): v for k, v in (_clusterdict["services"]["keylimecontainer"]).items()
    }
    kldict.update(kldict2)

    if argv:
        found = False
        hostname = sys.argv[1]
        for host in _clusterdict["nodes"]:
            if host["hostname"] == hostname:
                found = True
                kldict.update(
                    {
                        "node_name": host["hostname"],
                        "cloud_agent_cloudagent_ip": host["hostIP"],
                        "cloud_agent_agent_uuid": host["uuid"],
                    }
                )
        if found is False:
            sys.exit(
                f"## ERROR: failed to find hostname {hostname} in the cluster file {cluster_file}"
            )

    with open(KEYLIME_FILE, "w", encoding="utf-8") as _fd2:
        for key, klval in kldict.items():
            _fd2.write(f"export KEYLIME_{key.upper()}={str(klval)}\n")

        os.chmod(
            KEYLIME_FILE, stat.S_IROTH + stat.S_IRUSR + stat.S_IRGRP + stat.S_IWUSR
        )


if __name__ == "__main__":
    main(sys.argv[1:])
