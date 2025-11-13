#!/usr/bin/env python3
import sys

from pyasn1_modules import pem, rfc2459
from pyasn1.codec.der import decoder

def main():
    filepath=sys.argv[1]
    print(f"file: {filepath}")

    with open(filepath, encoding="utf-8") as f:
        substrate = pem.readPemFromFile(f)
        cert = decoder.decode(substrate, asn1Spec=rfc2459.Certificate())[0]
        print(cert.prettyPrint())

if __name__ == "__main__":
    main()
