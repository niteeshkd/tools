#!/usr/bin/env python3
'''
mblog yaml:
  The mblog_dict, created from the yaml boot log file, contains the following three keys.
  'version'=<int>
  'events'=<list of events say evenList>
  'pcrs'=<dictionary say pcrDict>

    Each item of the eventList is a dictionary (say eventDict) containing the following
    key:value pairs.
     ---- must ------
     EventNum:<int=1>
     PCRIndex:<int=0>
     EventType:<str=EV_S_CRTM_VERSION>

     ---- optional ------
     Digest:<hex="0000000000000000000000000000000000000000"> 
     or

     DigestCount:<int=2> and
     Digests:<list of digestDict> where digestDict contains following pairs.
      AlgorithmId: <str=sha1>
      Digest:<hex="1489f923c4dca729178b3e3233458550d8dddf29">

     ---- optional ------
     EventSize: <int=2>

     SpecID:<list of specId> where each item contains a dictionary with following pairs.
      specVersionMinor: <int=0>
      specVersionMajor: <int=2>
      numberOfAlgorithms: <int=2>
      Algorithms:<list of algorithms say algoList> whose item is adictionary with following pairs.
        algorithmId: <str=sha1>
        digestSize: <int=20>

     Event:<str="0000"> 
     or

     Event:<blobDict > where blobDict contains following pairs.
       BlobBase: <hex=0x900000>
       BlobLength: <hex=0xc00000>
     or

     Event:<varDict > where varDict contains following pairs.
       VariableName: <hex=61dfe48b-ca93-d211-aa0d-00e098032b8>
       UnicodeNameLength: <int=10>
       VariableDataLength: <int=1>
       UnicodeName: <str=SecureBoot
       VariableData: <str="01">
     or

     Event:<imgDict > where imgDict contains following pairs.
       ImageLocationInMemory: <hex=0x7cd51018>
       ImageLengthInMemory: <int=955656>
       ImageLinkTimeAddress: <hex=0x0>
       LengthOfDevicePath: <int=122>
       DevicePath: <str='PciRoot(0x0)...'>
     or

     Event:<strDict > where strDict contains following pair.
       String: <str='(hd0,gpt15)/EFI/ubuntu/grub.cfg'>

   pcrDict contains the following.
     sha1: <sha1PcrDict> where sha1PcrDict contains the following.
      0: <hex=0xa2b60369bf814f35ecc1445c1c699fe531d50ef7>
      ...
      9: ...
      14: ...
     sha256: <sha256PcrDict> where sha1PcrDict contains the following.
      0: <hex=0xa2b60369bf814f35ecc1445c1c699fe531d50ef7>
      ...
      9: ...
      14: ...
'''

import argparse
import yaml

event_pcr = {
    'EV_NO_ACTION':0,
    'EV_S_CRTM_VERSION':0,
    'EV_POST_CODE':0,
    'EV_EFI_PLATFORM_FIRMWARE_BLOB':0,
    'EV_EFI_BOOT_SERVICES_DRIVER':2,
    'EV_EFI_BOOT_SERVICES_APPLICATION':4,
    'EV_IPL':[8,9,14]
}

def parser_main():
    parser = argparse.ArgumentParser(
        description="measured boot log parser"
    )
    parser.add_argument(
        "-f",
        "--file",
        type=argparse.FileType("r"),
        help="measured boot log file",
    )
    parser.add_argument(
        "-e",
        "--event",
        help="event string",
    )
    parser.add_argument(
        "-sha256",
        "--sha256",
        help="sha256 digest",
    ) 
 
    return parser

def get_mblog_dict(file: str):
    _mblog_dict = yaml.safe_load(file)
    return _mblog_dict

def get_spec_version(mb_dict: dict):
    version=[]
    for ev in mb_dict['events']:
        if ev['EventType'] == 'EV_NO_ACTION':
            version.append(ev['SpecID'][0]['specVersionMajor'])
            version.append(ev['SpecID'][0]['specVersionMinor'])
    return('.'.join(map(str,version)))

def get_algoId(mb_dict: dict):
    algoId=[]
    for ev in mb_dict['events']:
        if ev['EventType'] == 'EV_NO_ACTION':
            for i in ev['SpecID'][0]['Algorithms']:
                algoId.append(i['algorithmId'])
    return(algoId)

def get_digests(mb_dict: dict, event: str, algo=None):
    dg_list=[]
    for ev in mb_dict['events']:
        if ev['EventType'] == event:
            if 'Digests' in ev:
                for i in range(0,ev['DigestCount']):
                    if algo is not None:
                        if ev['Digests'][i]['AlgorithmId'] == algo:
                            dg_list.append(ev['Digests'][i]['Digest'])
                    else:
                        dg_list.append(ev['Digests'][i]['Digest'])
    return (dg_list)

def main():
    p = parser_main()
    args = p.parse_args()
    assert (args.file),"file is required"
    
    mb_dict = get_mblog_dict(args.file)
    global event_pcr
    if args.event:
        if args.event not in event_pcr:
            print("event not found")

    #print(mb_dict)

    print(f'spec_version:{get_spec_version(mb_dict)}')
    print(f'algoIds:{get_algoId(mb_dict)}');
    
    digest_list = get_digests(mb_dict, args.event, 'sha256')

    if args.sha256:
        digest_matched=False
        for i in digest_list:
            if i == args.sha256:
                digest_matched=True
                break
            
        if digest_matched:
            print ('Digest matched!');
        else:
           print ('Digest does not match!');
           
if __name__ == "__main__":
    main()
