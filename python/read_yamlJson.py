#!/usr/bin/env python3
import sys
import yaml
import json
import jsonschema
from jsonschema import validate

def validate_json(json_data):
    with open('./cluster_schema.json', 'r') as file:
        cluster_schema = json.load(file)

    try:
        validate(instance=json_data, schema=cluster_schema)
    except jsonschema.exceptions.ValidationError as err:
        print(err)
        err = "Cluster data is invalid"
        return False, err

    message = "Cluster data is valid"
    return True, message


def main(clusterfile):
    with open(clusterfile, "r") as fh:
        config = fh.read()

    config_dict = dict()
    valid_yaml = True
    valid_json = True

    try:
        config_dict = json.loads(config)
    except:
        print("Could not load the file in JSON format")
        valid_json = False

    if valid_json:
        try:
            config_dict = yaml.safe_load(config)
        except yaml.YAMLError as exc:
            sys.exit(f"## ERROR: failed to parse file {fh.name}: {str(exc)}")
            print("Could not load the file in YAML format")
            valid_yaml = False
    else:
        valid_yaml = False


    if valid_json:
        print("From json file")
    else:
        print("From yaml file")

    is_valid, msg = validate_json(config_dict)
    if is_valid:
        print(msg)
        print(config_dict)

if __name__ == "__main__":
    main(sys.argv[1])

