#!/usr/bin/env python3
import sys
from cryptography import x509
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization
import base64

def main():
    filepath=sys.argv[1]
    print(f"file: {filepath}")

    with open(filepath, encoding="utf-8") as f: 
        cert = f.read()
        signcert = x509.load_pem_x509_certificate(
                data=cert.encode(),
                backend=default_backend(),)
        signcert_der = signcert.public_bytes(serialization.Encoding.DER)
        signcert_stripped = base64.b64encode(signcert_der)
        print (signcert_stripped)

if __name__ == "__main__":
    main()
