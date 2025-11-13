#!/usr/bin/env python2
import os
from shutil import copyfile

_cfgdict = {}
_fd = open("./keylime.conf.orig", 'r')
_fc = _fd.readlines()
_fd.close()

_key = None
for _line in _fc :
    _line = _line.strip()
    if len(_line) :
        if _line[0].count("#") :
            True
        elif _line[0].count('[') and _line.count(']') :
            _key = _line.replace('[','').replace(']','')
            _cfgdict[_key] = {}
        else :
            if _key :
                _skey,_svalue = _line.split('=')
                _cfgdict[_key][_skey.strip()] = _svalue.strip()

for _var in os.environ :
    if _var.count("KEYLIME") :
        for _key in _cfgdict :
            if _var.count("KEYLIME_" + _key.upper()) :
                _svar = _var.replace("KEYLIME_",'', 1).replace(_key.upper() + '_','', 1).lower()
                _cfgdict[_key][_svar] = os.environ[_var]

_fd = open("./keylime.conf",'w')
for _key in _cfgdict :
    _fd.write('\n' + '['+ _key +']' + '\n')
    for _skey in _cfgdict[_key] :
        _fd.write(_skey + " = " +  _cfgdict[_key][_skey] + '\n')
_fd.close()
