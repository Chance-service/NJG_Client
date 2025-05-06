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
    print 'usage: args.py -v arg_version -t arg_Targets -h'
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
        opts, args = getopt.getopt(sys.argv[1:], "v:t:h")
    except getopt.GetoptError as err:
        print str(err)
        usage()
        sys.exit(1)
    global version,BuildTargets
    for op, value in opts:
        if op == "-v":
            version = value
        elif op == "-t":
            BuildTargets = value
        elif op == "-h":
            usage()
            sys.exit()
        else:
            assert False, "unhandled option"
            usage()
            sys.exit(1)

def printVersion():
    printlog('small_version = ' + small_version)
    printlog('big_version = ' + big_version)
    printlog('pre_small_version = ' + pre_small_version)

def parseTargets():
    targets = BuildTargets.split("|")
    #BuildOperation.Android_args = [(value.partition('#')[0], value.partition('#')[2]) for value in targets if value.partition('#')[0].partition('_')[0]=='android' ]
    for value in targets:
        target = value.partition('#')
        system = target[0].partition('_')[0]
        if system == 'win32':
            BuildOperation.setop('op_c_w')
        elif system == 'so':
            BuildOperation.setop('op_c_so')
        elif system == 'jar':
            BuildOperation.setop('op_c_jar')
        elif system == 'android':
            BuildOperation.Android_args.append((target[0].partition('_')[2], target[2]))
        elif system == 'ios':
            BuildOperation.IOS_args.append((target[0].partition('_')[2], target[2]))
    if len(BuildOperation.IOS_args):
        BuildOperation.setop('op_c_i')
    if len(BuildOperation.Android_args):
        BuildOperation.setop('op_c_a')

#---------------------------init param------------------------------------
BuildOperation.timestr = time.strftime('%Y-%m-%d_%H%M%S',time.localtime(time.time()))

BuildTargets = ''
version = ''

small_version = ''
big_version = ''
pre_small_version = ''

BuildOperation.initOplist()
BuildOperation.initDependlist()

#---------------------------parse param------------------------------------
BuildOperation.setop('op_c_r')
BuildOperation.setop('op_c_s')
BuildOperation.setop('op_t')
parseArgs()
printlog('BuildTarget = ' + BuildTargets)
parseTargets()

printlog(str(BuildOperation.Android_args))
printlog(str(BuildOperation.IOS_args))

#printDictLog(BuildOperation.Android_args)
#printDictLog(BuildOperation.IOS_args)
#version = "2.140.0"
#if version=='':
#    version = getLatestSmallVersion()
#printlog('latestSmallVersion = ' + version)

if version.find("trunk") != -1:
    BuildOperation.newVersion = version.split("_")[-1]
    BuildOperation.Base_URL = Trunck_URL    
    BuildOperation.ftp_remote_dir_sv = ftp_remote_dailyBuild_dir + BuildOperation.timestr
else:   
    small_version = version #"2.140.0"
    checkVersion(small_version)
    big_version = small_version.rpartition('.')[0] #"2.140"
    #top_version = big_version + ".0" #2.140.0

    BuildOperation.newVersion = small_version
    BuildOperation.Base_URL = Branch_URL + '/' + big_version
    BuildOperation.Base_Tag_URL = Tag_URL + '/' + small_version

    BuildOperation.ftp_remote_dir_sv = ftp_remote_dir + big_version + '/' + small_version
    
    pre_small_version = version
    while True:
        version_split = pre_small_version.split(".")
        if not version_split[2] == '0':
            pre_small_version = big_version +  '.' + str(string.atoi(version_split[2]) - 1)
            ftp_remote_dir_psv = ftp_remote_dir +  big_version + '/' + pre_small_version
            if f.is_remotedir_exist(ftp_remote_dir_psv):
                BuildOperation.ftp_remote_dir_psv = ftp_remote_dir_psv
                break
            else:
                printlog('pre_small_version is not exist!')
                sys.exit(1)
        else:
            pre_small_version = ''
            BuildOperation.ftp_remote_dir_psv = ''
            break
        
    printVersion()
    f.mk_dir(ftp_remote_dir + big_version)

BuildOperation.Code_Server_URL = BuildOperation.Base_URL + '/Code_Server'
BuildOperation.Code_Client_URL = BuildOperation.Base_URL + '/Code_Client'
BuildOperation.Code_Core_URL = BuildOperation.Base_URL + '/Code_Core'
BuildOperation.Resource_Client_URL = BuildOperation.Base_URL + '/Resource_Client'
BuildOperation.Code_Android_URL = BuildOperation.Base_URL + '/Code_Android'

f.mk_dir(BuildOperation.ftp_remote_dir_sv)

BuildOperation.bindOperations()
BuildOperation.runOperation()
printlog('--------------------------done!!!--------------------------')