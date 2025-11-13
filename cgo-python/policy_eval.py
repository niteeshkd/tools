#!/usr/bin/env python3
'''
  1) Path of the policy file
  2) Path of the data file
  3) Path of the input file

'''

import argparse
import json
import datetime

from ctypes import *
from ctypes import cdll

def parser_main():
    parser = argparse.ArgumentParser(
        description="To evaluate the poliy using cgo"
    )
    parser.add_argument(
        "-p",
        "--policy",
        type=argparse.FileType("r"),
        help="policy file",
    )
    parser.add_argument(
        "-d",
        "--data",
        type=argparse.FileType("r"),
        help="data file in json format",
    )
    parser.add_argument(
        "-i",
        "--input",
        type=argparse.FileType("r"),
        help="input file in json format",
    )
    return parser

def main():
    pr = parser_main()
    args = pr.parse_args()

    input_json=json.load(args.input)
    data_json=json.load(args.data)

    policy = args.policy.read()
    data = args.data.read()
    inp = args.input.read()


    lib = cdll.LoadLibrary("./opa.so")

    start_time = datetime.datetime.now()

    class GoString(Structure):
        _fields_ = [("p", c_char_p), ("n", c_longlong)] 

    lib.evaluateGo.argtypes = [GoString, GoString, GoString]
    lib.evaluateGo.restype = c_char_p

    print(len(policy))
    print(len(policy.encode('utf-8')))

    #p = GoString(c_wchar_p(policy), len(policy))
    p = GoString(c_char_p(policy.encode('utf-8')), len(policy))
    d = GoString(c_char_p(data.encode('utf-8')), len(data))
    i = GoString(c_char_p(inp.encode('utf-8')), len(inp))

    #result = lib.evaluateGo(args.policy, data_json, input_json)
    result = lib.evaluateGo(p, d, i)

    end_time = datetime.datetime.now()
    time_diff = (end_time - start_time)
    execution_time = time_diff.total_seconds() * 1000
    print(f'time taken = {round(execution_time,2)} ms')

    print(result)


if __name__ == "__main__":
    main()
