#!/usr/bin/env python3
'''
  To check the rule.
  It needs:
  1) Path of the input json file
  2) <policy>/<rule> under v1/policies on OPA server

'''

import argparse
import json
import datetime
from opa_client.opa import OpaClient

def parser_main():
    parser = argparse.ArgumentParser(
        description="To check the policy rule"
    )
    parser.add_argument(
        "-s",
        "--pathstr",
        required=True,
        help="path string for policy",
    )
    parser.add_argument(
        "-r",
        "--rule",
        required=True,
        help="rule defined in the policy",
    )
    parser.add_argument(
        "-i",
        "--input",
        type=argparse.FileType("r"),
        help="input file in json format",
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

    cl = open_connection()

    check_data = {}
    if args.input:
        data=json.load(args.input)
        check_data["input"] = data
    else:
        check_data["input"] = "" 

    start_time = datetime.datetime.now()

    result = cl.check_permission(input_data=check_data, policy_name=args.pathstr, rule_name=args.rule)

    end_time = datetime.datetime.now()
    time_diff = (end_time - start_time)
    execution_time = time_diff.total_seconds() * 1000
    print(f'check_permission time = {round(execution_time,2)} ms')

    print(result)


    close_connection(cl)


if __name__ == "__main__":
    main()
