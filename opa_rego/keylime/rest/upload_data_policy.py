#!/usr/bin/env python3
'''
  To upload the data json and policy to OPA server.
  It needs:
  1) Path of the data or policy file to be uploaded
  2a) Path under v1/data/ on server in the case of data file
  2b) Path under v1/policies on server in the case of policy file 

'''

import argparse
import sys
import json
from opa_client.opa import OpaClient

def parser_main():
    parser = argparse.ArgumentParser(
        description="To upload data/policy file to local OPA server"
    )
    parser.add_argument(
        "-d",
        "--data",
        type=argparse.FileType("r"),
        help="data file in json format",
    )
    parser.add_argument(
        "-p",
        "--policy",
        help="policy file in rego",
    )
    parser.add_argument(
        "-s",
        "--pathstr",
        required=True,
        help="path string on server for data/policy",
    )
    return parser


def open_connection() -> OpaClient:
    client = OpaClient() # default host='localhost', port=8181, version='v1'
    #print('{}'.format(client.check_connection()))
    return client

def close_connection(client: OpaClient):
    #print('{}'.format(client.check_connection()))
    del client


def main():
    pr = parser_main()
    args = pr.parse_args()

    if not args.policy and  args.policy:
        print('data/policy file is required')
        sys.exit(1)
    
    cl = open_connection()

    if args.data:
        data=json.load(args.data)
        if not cl.update_or_create_opa_data(data, args.pathstr):
            print("data upload failed")

    if args.policy:
        #cl.delete_opa_policy(args.pathstr)
        if not cl.update_opa_policy_fromfile(args.policy,endpoint=args.pathstr):
            print("policy file upload failed")
        #print(cl.get_policies_list())
        #print(cl.get_policies_info())

    close_connection(cl)


if __name__ == "__main__":
    main()
