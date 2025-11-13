#!/usr/bin/env python3

import yaml
import json
import sys

os_list = {}
def main(infile):
    ## Read the YAML file
    with open(infile) as infile:
     os_list = yaml.load(infile, Loader=yaml.FullLoader)
     #print(os_list)
     json.dump(os_list, sys.stdout, indent=4) 

if __name__ == "__main__":
   main(sys.argv[1])
