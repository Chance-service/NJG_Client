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
    print 'usage: args.py -v arg_version -t arg_Targets -d arg_Distributed -h'
    print '-h show usage'
    print 'Valid -v arg_version: xxxx.xxxx.xxxx (eg. 2.140.0)'
    print '''Valid -t arg_Targets: [a#b|]...
        valid a param:
        1 - win32
        2 - google_r2_en
        3 - android_efun_en
        4 - android_efun_tw
        5 - android_entermate_kr
        6 - ios_efun_en
        7 - ios_efun_tw
        8 - ios_r2_en
        9 - android_gNetop_jp
        valid b = version code
        '''

def checkVersion(v):                 
    if not re.match('\d+\.\d+\.\d+$',v):
        printlog('error:invalid arg_version')
        usage()
        sys.exit(1)

def parseArgs():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "v:t:d:h")
    except getopt.GetoptError as err:
        print str(err)
        usage()
        sys.exit(1)
    global version,BuildTargets,Distributed
    for op, value in opts:
        if op == "-v":
            version = value
        elif op == "-t":
            BuildTargets = value
        elif op == "-d":
            Distributed = value
        elif op == "-h":
            usage()
            sys.exit()
        else:
            assert False, "unhandled option"
            usage()
            sys.exit(1)

def printVersion():
    printlog('version = ' + version)
    printlog('big_version = ' + big_version)
    printlog('pre_small_version = ' + pre_small_version)

def parseTargets():
    global Distributed
    targets = BuildTargets.split("|")
    for value in targets:
        target = value.partition('#')
        system = target[0].partition('_')[0]
        if system == 'win32':
            if Distributed == '0':
                BuildOperation.setop('op_c_w')
            else:
                BuildOperation.Build_Win32_Job()
        elif system == 'so':
            BuildOperation.setop('op_c_so')
        elif system == 'jar':
            BuildOperation.setop('op_c_jar')
        elif system == 'android':
            BuildOperation.Android_args.append((target[0].partition('_')[2], target[2]))
        elif system == 'ios':
            BuildOperation.IOS_args.append((target[0].partition('_')[2], target[2]))
        elif system == 'server':
            if Distributed == '0':
                BuildOperation.setop('op_c_s')
            else:
                BuildOperation.Build_Server_Job()
        elif system == 'res':
            #add by lyj : res add args
            resTargets = target[2].split(",")
            for resValue in resTargets:
                BuildOperation.res_args.append(resValue.partition("_")[2])
            BuildOperation.setop('op_c_r')
    if len(BuildOperation.IOS_args):
        BuildOperation.setop('op_c_i')
    if len(BuildOperation.Android_args):
        BuildOperation.setop('op_c_a')

#---------------------------Define timestr------------------------------------ 
timestr = time.strftime('%Y-%m-%d_%H%M%S',time.localtime(time.time()))

#---------------------------init param------------------------------------
Distributed = '0'
BuildTargets = ''
version = ''
big_version = ''
pre_small_version = ''

parseArgs()

big_version = version.rpartition('.')[0] #"2.140"
version_split = version.split(".")
if len(version_split)>1 and not version_split[2] == '0':
    pre_small_version = big_version +  '.' + str(string.atoi(version_split[2]) - 1)
else:
    pre_small_version = ''
printVersion()
printlog('BuildTarget = ' + BuildTargets)

#---------------------------init Operation param------------------------------------
baseURL = ''
if version.find("trunk") != -1:
    baseURL = Trunck_URL
else:
    baseURL = Branch_URL + '/' + version.rpartition('.')[0]

BuildOperation.init(version,baseURL,timestr,pre_small_version)

#---------------------------init Operation------------------------------------
BuildOperation.initOplist()
BuildOperation.initDependlist()

parseTargets()
printlog(str(BuildOperation.Android_args))
printlog(str(BuildOperation.IOS_args))

BuildOperation.setop('op_t')

#---------------------------run Operation------------------------------------
BuildOperation.bindOperations()
BuildOperation.runOperation()
printlog('--------------------------done!!!--------------------------')