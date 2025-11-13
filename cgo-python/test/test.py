from ctypes import *
lib = cdll.LoadLibrary("./func.so")
r=lib.fun(10,20)
print(r)
