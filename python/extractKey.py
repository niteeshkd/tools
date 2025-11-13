#!/usr/bin/env python3
import sys, getopt

from cryptography.x509 import load_pem_x509_certificate
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization
import base64

#inputfile = "/home/niteesh/github/refstates/ek_certificates/DAL/DAL10/qz1/rk119/dal1-qz1-sr3-rk119-s08-ekcert.rsa.pem"

def main(argv):
   inputfile = ''
   try:
      opts, args = getopt.getopt(argv,"hi:",["ifile="])
   except getopt.GetoptError:
      print("extractKey.py -i <inputfile>")
      sys.exit(2)
   for opt, arg in opts:
      if opt == '-h':
         print("extractKey.py -i <inputfile>")
         sys.exit()
      elif opt in ("-i", "--ifile"):
         inputfile = arg

   print(inputfile)

   with open(inputfile, "rb") as f:
      cert = load_pem_x509_certificate(f.read(),default_backend())
      cert_der = cert.public_bytes(serialization.Encoding.DER)
      cert_stripped = base64.b64encode(cert_der)
      print (cert_stripped)

if __name__ == "__main__":
   main(sys.argv[1:])

