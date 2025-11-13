#!/usr/bin/env python3
import sys
import yaml

def main(mblog):
    with open(mblog, "r") as fh:
        mb_dict = yaml.safe_load(fh) 

    #print(mb_dict)
    for i in mb_dict['events']:
        print(i['EventNum'],'\t',i['PCRIndex'],'\t',i['EventType'])
        if 'Digests' in i:
            for j in i['Digests']:
                if j['AlgorithmId'] == 'sha1':
                    print (j['Digest'])
                if j['AlgorithmId'] == 'sha256':
                    print (j['Digest'])
        if 'Event' in i:
            if isinstance(i['Event'],dict):
                if 'UnicodeName' in i['Event']:
                    print(i['Event']['UnicodeName'])
            else:
                print(i['Event'])

if __name__ == "__main__":
    main(sys.argv[1])

