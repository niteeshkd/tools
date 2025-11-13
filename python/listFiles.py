#!/usr/bin/env python3
import glob
import os
import re

# absolute path to search all text files inside a specific folder
path = r'/home/niteesh/github/refstates/ek_certificates/**/*.pem'
files = glob.glob(path, recursive=True)
print(type(files))
for x in files:
    basename=os.path.basename(x)
    #print(basename)
    m = re.search('(.+)-ekcert.(.+).pem', basename)
    if m:
        node = m.group(1)
        cert_type = m.group(2)
        print('node={} cert_type={}'.format(node, cert_type))
    else:
        print('unmatched file {}'.format(basename))
#print(files)
