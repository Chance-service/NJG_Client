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
    print 'usage: args.py arg_platform arg_versionCode arg_versionName arg_time'
    print 'Valid arg_platform: Efun_en or R2Game_en ...'
    print 'Valid arg_versionCode: number string'
    print 'Valid arg_versionName: x.xx.xx (eg. 1.79.0)'
    print 'Valid arg_time: if "0" then calculate by self'

platform = sys.argv[1]
versionCode = sys.argv[2]
if platform =='' or versionCode=='':
    usage()
    sys.exit(1)
#----------------------------get command line arg----------------------
if len(sys.argv) < 6:
    print 'At leaset 5 arguments'
    usage()
    sys.exit(1)
    
#---------------------------Define timestr------------------------------------ 
timestr='0'
if sys.argv[4] == '0':
    timestr = time.strftime('%Y-%m-%d_%H%M%S',time.localtime(time.time()))
else:
    timestr = sys.argv[4]
printlog('timestr = ' + timestr)

#---------------------------Define version------------------------------------ 
versionName = sys.argv[3]
if not re.match('\d+\.\d+\.\d+$',versionName) and versionName!="trunk":
    print 'error:invalid arg_version Version Error!'
    usage()
    sys.exit(1)
printlog('versionName = ' + versionName)
        
BuildNode = sys.argv[5]
if BuildNode != 'master':
    ftp_remote_dir_sv = ''
    if versionName=="trunk":
        ftp_remote_dir_sv = ftp_remote_dailyBuild_dir + timestr
    else:
        big_version =  versionName.rpartition('.')[0]
        ftp_remote_dir_sv = ftp_remote_dir + big_version + '/' + versionName
    workspaceName = 'workspace_'+platform+'_'+versionCode+'_'+versionName+'_'+timestr
    workspacePath = Code_Android_Native_Path + '/' + workspaceName
    FTP_Download_zip_for_Directory(workspacePath, ftp_remote_dir_sv+'/'+workspaceName+'.zip')

run_cmd(Code_Android_Native_Path + '/buildRealse.bat ' + platform + ' ' + versionCode + ' ' + versionName + ' ' + timestr)
printlog('--------------------------done!!!--------------------------')