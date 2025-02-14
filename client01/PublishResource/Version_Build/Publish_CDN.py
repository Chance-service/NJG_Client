#coding=utf-8

import os
import shutil
import time,datetime
import getopt
import re
from FTPOperation import *
from fileinput import filename

print sys.getdefaultencoding()


PushCDN_Svn_root = 'svn://23.91.96.225/publish_CDN/'
PushCDN_Svn_username = 'liyajiang'
PushCDN_Svn_password = 'liyajiang'
PushCDN_Auth_cmdstr = ' --username ' + PushCDN_Svn_username + ' --password ' + PushCDN_Svn_password

PushCDN_ZipFile_name = 'Resource_Update'

PushCDN_Native_SVN_path = Native_SVN_Root_Path + '/push_CDN_local'
PushCDN_Native_path = Native_SVN_Root_Path + '/PushCDN_Temp'

PushCDN_CleanUp_cmdstr = string.Template('svn cleanup ${PATH}'+PushCDN_Auth_cmdstr)
PushCDN_Switch_cmdstr = string.Template('svn switch --ignore-ancestry ${URL} ${PATH}'+PushCDN_Auth_cmdstr)
PushCDN_Checkout_cmdstr = string.Template('svn checkout ${URL} ${PATH}'+PushCDN_Auth_cmdstr)
PushCDN_Commit_cmdstr = string.Template('svn commit -m "ci commit:${MESSAGE}" ${PATH}'+PushCDN_Auth_cmdstr)
PushCDN_Add_cmdstr = string.Template('svn add ${PATH} --force'+PushCDN_Auth_cmdstr)
PushCDN_Import_cmdstr = string.Template('svn import -m "commit version Resource" --force ${PATH} ${URL}'+PushCDN_Auth_cmdstr)
PushCDN_Del_cmdstr = string.Template('svn delete -m "delete" ${URL}'+PushCDN_Auth_cmdstr)
PushCDN_Del_Local_cmdstr = string.Template('svn delete ${PATH}'+PushCDN_Auth_cmdstr)
PushCDN_Creatdir_cmdstr = string.Template('svn mkdir -m "creat dir" ${URL}'+PushCDN_Auth_cmdstr)
PushCDN_Copy_cmdstr = string.Template('svn copy -m "copy dir" ${SRC_URL} ${DST_URL}'+PushCDN_Auth_cmdstr)
PushCDN_Export_cmdstr = string.Template('svn export ${URL} ${PATH}'+PushCDN_Auth_cmdstr)
PushCDN_List_cmdstr_R = string.Template('svn ls ${URL} -R'+PushCDN_Auth_cmdstr)
PushCDN_List_cmdstr = string.Template('svn ls ${URL}'+PushCDN_Auth_cmdstr)
PushCDN_Revert_cmdstr = string.Template('svn revert --depth=infinity ${PATH}'+PushCDN_Auth_cmdstr)
PushCDN_Update_cmdstr = string.Template('svn update ${PATH} --no-auth-cache'+PushCDN_Auth_cmdstr)


printlog('sys.argv = ' + str(sys.argv))
#---------------------------Define option------------------------------------
def usage():
    print 'usage: args.py  -v arg_version -d arg_destination -h'
    print '-h show usage'
    print 'Valid -v arg_version: xxxx.xxxx.xxxx (eg. 2.140.0)'
    print '''Valid -d arg_destination: [a,b]...
        valid a param:
        1-    android_Efun_en
        2-    android_Entermate
        3-    android_gNetop
        4-    android_R2Game_en
        5-    ios_GameEfun
        6-    ios_GameEntermate
        7-    ios_GameGNetop
        8-    ios_GameR2
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
    global Version,Destinations
    for op, value in opts:
        if op == "-v":
            Version = value
        elif op == "-d":
            desTargets = value.split(",")
            for desValue in desTargets:
                Destinations.append(desValue)
        elif op == "-h":
            usage()
            sys.exit()
        else:
            assert False, "unhandled option"
            usage()
            sys.exit(1)

def init():
    global timestr, Version, zip_remote_path, zip_native_path, svn_native_path
    del_folder(PushCDN_Native_path)
    run_cmd(Makedir_cmdstr.substitute(PATH=PushCDN_Native_path).replace('/','\\'))
    
    big_version =  Version.rpartition('.')[0]    
    zip_remote_path = ftp_remote_dir + big_version + '/' + Version + '/' + PushCDN_ZipFile_name + '.zip'    
    
    zip_native_path = PushCDN_Native_path + '/' + PushCDN_ZipFile_name
    svn_native_path = PushCDN_Native_SVN_path
    
def Download_FTP_CDN():
    printlog('--------------------------run step Download_FTP_CDN,please waiting--------------------------')
    global Version, zip_remote_path, zip_native_path
    del_file(zip_native_path + '.zip')
    del_folder(zip_native_path)
    
    if zip_remote_path!= '':        
        FTP_Download_zip_for_Directory(zip_native_path, zip_remote_path)
        
def Download_SVN_CDN():
    printlog('--------------------------run step Download_SVN_CDN,please waiting--------------------------')    
    if os.path.isdir(PushCDN_Native_SVN_path):
        printlog('UpdateSVN: ' + PushCDN_Svn_root + ' to path:' + PushCDN_Native_SVN_path)
        run_cmd(PushCDN_CleanUp_cmdstr.substitute(PATH=PushCDN_Native_SVN_path))
        run_cmd(PushCDN_Revert_cmdstr.substitute(PATH=PushCDN_Native_SVN_path))
        run_cmd(PushCDN_Update_cmdstr.substitute(PATH=PushCDN_Native_SVN_path))
    else:
        printlog('CheckoutSVN: ' + PushCDN_Svn_root + ' to path:' + PushCDN_Native_SVN_path)
        run_cmd(PushCDN_Checkout_cmdstr.substitute(URL=PushCDN_Svn_root,PATH=PushCDN_Native_SVN_path))

def Operation_CDN():
    printlog('--------------------------run step Operation_CDN,please waiting--------------------------')
    for desValue in Destinations:
        Operation_SVN_CDN_ByTarget(desValue)
        Operation_FTP_CDN_ByTarget(desValue)
        
def Operation_SVN_CDN_ByTarget(target):
    printlog('--------------------------run step Operation_SVN_CDN_ByTarget, target=' + target + ',please waiting--------------------------')
    global svn_native_path
    
    cfgFilePath =  svn_native_path + '/' + target + '/' + Version.rpartition('.')[0] + '/servers.cfg'
    Operation_Cfg_ByName(cfgFilePath)
    
    targetNativePath = svn_native_path + '/' + target + '/' + Version.rpartition('.')[0] + '/UpdateFiles'
    dir_filter = ['.svn']
    file_filter = []
    for root, dirs, files in os.walk(targetNativePath, True):
        for foldername in dirs:
            if (foldername not in dir_filter):
                if os.path.isdir(os.path.join(root, foldername)):
                    run_cmd(PushCDN_Del_Local_cmdstr.substitute(PATH=os.path.join(root, foldername)))
                else:
                    printlog('folder not exist!')
                print('del folder:' + os.path.join(root, foldername))
                
        for filename in files:
            if (filename not in file_filter):
                if os.path.isfile(os.path.join(root, filename)):
                    run_cmd(PushCDN_Del_Local_cmdstr.substitute(PATH=os.path.join(root, filename)))
                else:
                    printlog('file not exist!')
                print('del file:' + os.path.join(root, filename))
                
    del_folder(targetNativePath)
    
def Operation_Cfg_ByName(filePath):
    printlog('--------------------------run step Operation_Cfg_ByName, filePath=' + filePath + ',please waiting--------------------------')
    global Version
    cfgFile = []
    if os.path.exists(filePath):
        f = open(filePath)
        cfgFile = json.load(f)
        printlog(str(cfgFile))
        f.close()
        
        cfgVersion = cfgFile['severVerson']
        if cfgVersion != None and Version != '':
            cfgFile['severVerson'] = Version
            del_file(filePath)
            f = file(filePath,"w")
            f.write(json.dumps(cfgFile, ensure_ascii=False, encoding="utf-8", indent = 4, sort_keys=True))
            f.close()
        else:
            printlog('Error:Version Error! Version = ' + Version)
            sys.exit(1)
    else:
        printlog('Error:cfg file not exist')
        sys.exit(1)
    
        
def Operation_FTP_CDN_ByTarget(target):
    printlog('--------------------------run step Operation_FTP_CDN_ByTarget, target=' + target + ',please waiting--------------------------')
    global svn_native_path, zip_remote_path, zip_native_path
    targetNativePath = svn_native_path + '/' + target + '/' + Version.rpartition('.')[0] + '/UpdateFiles'
    printlog('copy files from:' + zip_native_path + ' to:' + targetNativePath)
    shutil.copytree(zip_native_path, targetNativePath)
    
    
    targetPlatFormPath = targetNativePath + '/platforms/' + target
    printlog('copy files from:' + targetPlatFormPath + ' to:' + targetNativePath) 
    copy_tree_overlap(targetPlatFormPath, targetNativePath)
    
    
    del_folder(targetNativePath + '/platforms')
    
    targetUpdatePhpPath = targetNativePath + '/update.php'
    del_file(targetUpdatePhpPath)
    
    platFormName = target.partition('_')[2]
    targetPlatFormPhpPath = targetNativePath + '/update_' + platFormName + '.php'
    printlog('rename file from:' + targetPlatFormPhpPath + ' to:' + targetUpdatePhpPath)
    os.rename(targetPlatFormPhpPath, targetUpdatePhpPath)
    
    #del other php files
    filter_exts = ['.php']
    for name in os.listdir(targetNativePath):  
        if name != 'update.php':
            pathname = os.path.splitext(os.path.join(targetNativePath, name))  
            if (pathname[1] in filter_exts):
                os.remove(os.path.join(targetNativePath, name))  
                print('del ' + os.path.join(targetNativePath,name))
    
def Commit_SVN_CDN():
    printlog('--------------------------run step Commit_SVN_CDN,please waiting--------------------------')
    global svn_native_path
    Destinations
    svn_commit_message = 'Publish_CDN  Version:' + Version + ' Destinations:' + ','.join(Destinations) + '       time:' + timestr
    run_cmd(PushCDN_Add_cmdstr.substitute(PATH=svn_native_path))
    run_cmd(PushCDN_Commit_cmdstr.substitute(MESSAGE=svn_commit_message,PATH=svn_native_path))
#---------------------------Define timestr------------------------------------ 
timestr = time.strftime('%Y-%m-%d_%H%M%S',time.localtime(time.time()))

#---------------------------init param------------------------------------

Version = ''
Destinations = []
zip_remote_path = ''
zip_native_path = ''
svn_native_path = ''


parseArgs()

printlog('Version = ' + Version)
for desValue in Destinations:
    printlog('----------Destination = ' + desValue)


#---------------------------init Operation param------------------------------------
init()
#---------------------------run Operation------------------------------------

Download_SVN_CDN()
Download_FTP_CDN()
Operation_CDN()
Commit_SVN_CDN()

del_folder(PushCDN_Native_path)

printlog('--------------------------done!!!Publish_CDN--------------------------')