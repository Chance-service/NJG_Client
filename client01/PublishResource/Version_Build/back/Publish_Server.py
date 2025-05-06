#coding=utf-8

import os
import shutil
import time,datetime
import getopt
import re
from FTPOperation import *

PushServer_Svn_root = 'svn://23.91.96.225/publish_server/trunk'
PushServer_Svn_username = 'liyajiang'
PushServer_Svn_password = 'liyajiang'
PushServer_Auth_cmdstr = ' --username ' + PushServer_Svn_username + ' --password ' + PushServer_Svn_password

PushServer_ZipFile_name = 'Server'

PushServer_Native_SVN_path = Native_SVN_Root_Path + '/push_server_local'
PushServer_Native_path = Native_SVN_Root_Path + '/PushServer_Temp'

PushServer_CleanUp_cmdstr = string.Template('svn cleanup ${PATH}'+PushServer_Auth_cmdstr)
PushServer_Switch_cmdstr = string.Template('svn switch --ignore-ancestry ${URL} ${PATH}'+PushServer_Auth_cmdstr)
PushServer_Checkout_cmdstr = string.Template('svn checkout ${URL} ${PATH}'+PushServer_Auth_cmdstr)
PushServer_Commit_cmdstr = string.Template('svn commit -m "ci commit:${MESSAGE}" ${PATH}'+PushServer_Auth_cmdstr)
PushServer_Add_cmdstr = string.Template('svn add ${PATH} --force'+PushServer_Auth_cmdstr)
PushServer_Import_cmdstr = string.Template('svn import -m "commit version Resource" --force ${PATH} ${URL}'+PushServer_Auth_cmdstr)
PushServer_Del_cmdstr = string.Template('svn delete -m "delete" ${URL}'+PushServer_Auth_cmdstr)
PushServer_Del_Local_cmdstr = string.Template('svn delete ${PATH}'+PushServer_Auth_cmdstr)
PushServer_Creatdir_cmdstr = string.Template('svn mkdir -m "creat dir" ${URL}'+PushServer_Auth_cmdstr)
PushServer_Copy_cmdstr = string.Template('svn copy -m "copy dir" ${SRC_URL} ${DST_URL}'+PushServer_Auth_cmdstr)
PushServer_Export_cmdstr = string.Template('svn export ${URL} ${PATH}'+PushServer_Auth_cmdstr)
PushServer_List_cmdstr_R = string.Template('svn ls ${URL} -R'+PushServer_Auth_cmdstr)
PushServer_List_cmdstr = string.Template('svn ls ${URL}'+PushServer_Auth_cmdstr)
PushServer_Revert_cmdstr = string.Template('svn revert --depth=infinity ${PATH}'+PushServer_Auth_cmdstr)
PushServer_Update_cmdstr = string.Template('svn update ${PATH} --no-auth-cache'+PushServer_Auth_cmdstr)


printlog('sys.argv = ' + str(sys.argv))
#---------------------------Define option------------------------------------
def usage():
    print 'usage: args.py  -v arg_version -d arg_destination -t arg_platform -h'
    print '-h show usage'
    print 'Valid -v arg_version: xxxx.xxxx.xxxx (eg. 2.140.0)'
    print '''Valid -d arg_destination: [a,b|]...
        valid a param:
        1-  Efun_dev_all
        2-  Entermate_shen_ios
        3-  R2_shen_ios          
        4-  Efun_online_all
        5-  Entermate_test_all
        6-  R2_test_all          
        7-  Efun_shen_ios
        8-  Entermate_test_android
        9-  gNetop_dev_all       
        10- Efun_test_all
        11- Entermate_test_ios
        12- gNetop_online_all    
        13- Entermate_dev_test
        14- R2_dev_all
        15- gNetop_test_android
        16- Entermate_online_all
        17- R2_online_all
        18- gNetop_test_ios
        '''
    print '''Valid -t arg_platform...
        valid a param:
        1-  efun_cht
        2-  efun_en  
        3-  entermate_kr  
        4-  gNetop_jp  
        5-  r2_android_en
        '''

def checkVersion(v):                 
    if not re.match('\d+\.\d+\.\d+$',v):
        printlog('error:invalid arg_version')
        usage()
        sys.exit(1)

def parseArgs():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "v:d:t:h")
    except getopt.GetoptError as err:
        print str(err)
        usage()
        sys.exit(1)
    global Version,Destination,Platform
    for op, value in opts:
        if op == "-v":
            Version = value
        elif op == "-d":
            Destination = value
        elif op == "-t":
            Platform = value
        elif op == "-h":
            usage()
            sys.exit()
        else:
            assert False, "unhandled option"
            usage()
            sys.exit(1)

def init():
    global timestr, Version, zip_remote_path, zip_native_path, svn_native_path, svn_commit_message
    del_folder(PushServer_Native_path)
    run_cmd(Makedir_cmdstr.substitute(PATH=PushServer_Native_path).replace('/','\\'))
    
    big_version =  Version.rpartition('.')[0]    
    zip_remote_path = ftp_remote_dir + big_version + '/' + Version + '/' + PushServer_ZipFile_name + '.zip'    
    
    zip_native_path = PushServer_Native_path + '/' + PushServer_ZipFile_name
    svn_native_path = PushServer_Native_SVN_path + '/' + Destination
    svn_commit_message = 'Publish_Server:  Version:' + Version + '  Destination:' + Destination + '  Platform:' + Platform + '  time:' + timestr
    
def Download_FTP_Server():
    printlog('--------------------------run step Download_FTP_Server,please waiting--------------------------')
    global Version, zip_remote_path, zip_native_path
    del_file(zip_native_path + '.zip')
    del_folder(zip_native_path)
    
    if zip_remote_path!= '':        
        FTP_Download_zip_for_Directory(zip_native_path, zip_remote_path)
        
def Download_SVN_Server():
    printlog('--------------------------run step Download_SVN_Server,please waiting--------------------------')
    global Destination, svn_native_path
    
    if os.path.isdir(PushServer_Native_SVN_path):
        printlog('UpdateSVN: ' + PushServer_Svn_root + ' to path:' + PushServer_Native_SVN_path)
        run_cmd(PushServer_CleanUp_cmdstr.substitute(PATH=PushServer_Native_SVN_path))
        run_cmd(PushServer_Revert_cmdstr.substitute(PATH=PushServer_Native_SVN_path))
        run_cmd(PushServer_Update_cmdstr.substitute(PATH=PushServer_Native_SVN_path))
    else:
        printlog('CheckoutSVN: ' + PushServer_Svn_root + ' to path:' + PushServer_Native_SVN_path)
        run_cmd(PushServer_Checkout_cmdstr.substitute(URL=PushServer_Svn_root,PATH=PushServer_Native_SVN_path))
        
def Operation_SVN_Server():
    printlog('--------------------------run step Operation_Server,please waiting--------------------------')
    global svn_native_path
    dir_filter = ['.svn']
    file_filter = []
    for root, dirs, files in os.walk(svn_native_path, True):
        for foldername in dirs:
            if (foldername not in dir_filter):
                if os.path.isdir(os.path.join(root, foldername)):
                    run_cmd(PushServer_Del_Local_cmdstr.substitute(PATH=os.path.join(root, foldername)))
                else:
                    printlog('folder not exist!')
                print('del folder:' + os.path.join(root, foldername))
                
        for filename in files:
            if (filename not in file_filter):
                if os.path.isfile(os.path.join(root, filename)):
                    run_cmd(PushServer_Del_Local_cmdstr.substitute(PATH=os.path.join(root, filename)))
                else:
                    printlog('file not exist!')
                print('del file:' + os.path.join(root, filename))
    
def Operation_FTP_Server():
    printlog('--------------------------run step Operation_FTP_Server,please waiting--------------------------')
    global svn_native_path, zip_remote_path, zip_native_path
    
    zip_target_path = zip_native_path + '/' + Platform
    if os.path.isfile(zip_target_path + '.zip'):
        unzip_file(zip_target_path + '.zip', svn_native_path)
        #delete lib folder
        del_folder(svn_native_path + '/lib')
    else:
        print 'file not exist! target path:' + zip_target_path + '.zip'
        sys.exit(1)
        
    del_folder(PushServer_Native_path)
    
def Commit_SVN_Server():
    printlog('--------------------------run step Commit_SVN_Server,please waiting--------------------------')
    global svn_native_path
    run_cmd(PushServer_Add_cmdstr.substitute(PATH=svn_native_path))
    run_cmd(PushServer_Commit_cmdstr.substitute(MESSAGE=svn_commit_message,PATH=svn_native_path))
#---------------------------Define timestr------------------------------------ 
timestr = time.strftime('%Y-%m-%d_%H%M%S',time.localtime(time.time()))

#---------------------------init param------------------------------------

Version = ''
Destination = ''
Platform = ''
zip_remote_path = ''
zip_native_path = ''
svn_native_path = ''

svn_commit_message = ''

parseArgs()

printlog('Version = ' + Version)
printlog('----------Destination = ' + Destination)
printlog('----------Platform = ' + Platform)

#---------------------------init Operation param------------------------------------
init()
#---------------------------run Operation------------------------------------

Download_SVN_Server()
Download_FTP_Server()
Operation_SVN_Server()
Operation_FTP_Server()
Commit_SVN_Server()

del_folder(PushServer_Native_path)

printlog('--------------------------done!!!--------------------------')