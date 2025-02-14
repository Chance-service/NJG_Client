#coding=utf-8

import os
import shutil
import time,datetime
import getopt
import re
import BuildOperation
from FTPOperation import *

printlog('sys.argv = ' + str(sys.argv))
#---------------------------Define option------------------------------------
def usage():
    print 'usage: args.py arg_time arg_version'
    print 'Valid arg_time: if "0" then calculate by self'
    print 'Valid arg_version: x.xx.xx (eg. 1.79.0)'
    
#----------------------------get command line arg----------------------
if len(sys.argv) < 3:
    print 'At leaset 2 arguments'
    usage()
    sys.exit(1)
    
#---------------------------Define timestr------------------------------------ 
timestr='0'
if sys.argv[1] == '0':
    timestr = time.strftime('%Y-%m-%d_%H%M%S',time.localtime(time.time()))
else:
    timestr = sys.argv[1]
printlog('timestr = ' + timestr)

#---------------------------Define version------------------------------------ 
version = sys.argv[2]
if not re.match('\d+\.\d+\.\d+$',version) and version!="trunk":
    print 'error:invalid arg_version Version Error!'
    usage()
    sys.exit(1)
printlog('version = ' + version)

#---------------------------init Operation param------------------------------------
baseURL = ''
if version=="trunk":
    baseURL = Trunck_URL
else:
    baseURL = Branch_URL + '/' + version.rpartition('.')[0]

BuildOperation.init(version,baseURL,timestr)

#---------------------------init Operation------------------------------------
BuildOperation.initOplist()
BuildOperation.initDependlist()
BuildOperation.setop('op_c_so')

#---------------------------run Operation------------------------------------
BuildOperation.bindOperations()
BuildOperation.runOperation()
printlog('--------------------------done!!!--------------------------')