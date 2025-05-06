#coding=utf-8

import json
import os

from utility import *
from FTPOperation import *
from CI_job_cmd import *

newVersion = ''
timestr = ''
IOS_args = [] #[('GameEfun','5'),('GameR2','3')]
Android_args = [] #[('R2Game_en','32'),('Efun_en',3)]

res_args = []  #android_R2Game_en,android_Efun_en

Base_URL = ''
Base_Tag_URL = ''

Code_Server_URL = ''
Code_Client_URL = ''
Code_Core_URL = ''
Resource_Client_URL = ''
Code_Android_URL = ''

ftp_remote_dir_sv = ''
ftp_remote_dir_psv = ''

#---------------------------Define param------------------------------------
def init(version,baseURL,times,psv=''):
    global timestr,newVersion,Base_URL,Base_Tag_URL,Code_Server_URL,Code_Client_URL,Code_Core_URL,Resource_Client_URL,Code_Android_URL,ftp_remote_dir_sv,ftp_remote_dir_psv
    timestr = times
    newVersion = version
    Base_URL = baseURL
    Code_Server_URL = Base_URL + '/Code_Server'
    Code_Client_URL = Base_URL + '/Code_Client'
    Code_Core_URL = Base_URL + '/Code_Core'
    Resource_Client_URL = Base_URL + '/Resource_Client'
    Code_Android_URL = Base_URL + '/Code_Android'
    
    if version.find("trunk") != -1:
        newVersion = version.split("_")[-1]
        ftp_remote_dir_sv = ftp_remote_dailyBuild_dir + timestr
    else:
        big_version =  version.rpartition('.')[0]
        Base_Tag_URL = Tag_URL + '/' + big_version + '/' + version
        ftp_remote_dir_sv = ftp_remote_dir + big_version + '/' + version
        f.mk_dir(ftp_remote_dir + big_version)
        
        if psv != '':
            ftp_remote_dir_psv = ftp_remote_dir +  big_version + '/' + psv
            if not f.is_remotedir_exist(ftp_remote_dir_psv):
                printlog('pre_small_version is not exist!')
                sys.exit(1)
        
    f.mk_dir(ftp_remote_dir_sv)
    
#---------------------------Define option------------------------------------
oplist = []
def printOplist(msg):
    printlog(msg)
    for value in oplist:
        printlog(str(value))

def initOplist():#决定各个op的执行顺序
    oplist.append(['op_d_s', False])
    oplist.append(['op_d_r', False])
    oplist.append(['op_d_c', False])
    oplist.append(['op_d_a', False])
    oplist.append(['op_b_s', False])
    oplist.append(['op_b_w', False])
    oplist.append(['op_b_r', False])
    oplist.append(['op_c_r', False])
    oplist.append(['op_b_i', False])
    oplist.append(['op_b_so', False])
    oplist.append(['op_b_jar', False])
    oplist.append(['op_b_a', False])
    oplist.append(['op_c_s', False])
    oplist.append(['op_c_w', False])
    oplist.append(['op_c_a', False])
    oplist.append(['op_c_so', False])
    oplist.append(['op_c_jar', False])
    oplist.append(['op_c_i', False])
    oplist.append(['op_t', False])
    printOplist('init oplist = ')

def bindOperation(op, func):
    for value in oplist:
        if value[0] == op:
            if len(value) == 2:
                value.append(func)
            elif len(value) == 3:
                value[2] = func
            else:
                printlog('bindOperation error!')
                sys.exit(1)

def needOperation(op):
    for value in oplist:
        if value[0] == op:
            return value[1]
    return False

def getOperationFunc(op):
    for value in oplist:
        if value[0] == op:
            return value[2]
    return

def bindOperations():
    printlog('--------------------------bind operations!!!--------------------------')
    bindOperation('op_d_s', Download_ServerCode)
    bindOperation('op_d_r', Download_Resource)
    bindOperation('op_d_c', Download_Client)
    bindOperation('op_d_a', Download_AndroidCode)
    bindOperation('op_b_s', Build_Server)
    bindOperation('op_b_w', Build_Win32)
    bindOperation('op_b_r', Build_Resource)
    bindOperation('op_b_so', Build_Android_SO)
    bindOperation('op_b_jar', Build_Android_Jar)
    bindOperation('op_b_a', Build_Android)
    bindOperation('op_b_i', Build_IOS)
    bindOperation('op_c_s', Commit_Server)
    bindOperation('op_c_r', Commit_Resource)
    bindOperation('op_c_w', Commit_Windows)
    bindOperation('op_c_a', Commit_Android)
    bindOperation('op_c_so', Commit_Android_SO)
    bindOperation('op_c_jar', Commit_Android_Jar)
    bindOperation('op_t', Creat_Tag)
    printOplist('bind oplist = ')
    
dependlist = {}
def initDependlist():#决定各个op的依赖关系
    dependlist['op_c_i'] = ['op_b_i']
    dependlist['op_b_i'] = ['op_c_r']
    dependlist['op_c_s'] = ['op_b_s']
    dependlist['op_c_w'] = ['op_b_w']
    dependlist['op_c_a'] = ['op_b_a']
    dependlist['op_c_so'] = ['op_b_so']
    dependlist['op_c_jar'] = ['op_b_jar']
    dependlist['op_c_r'] = ['op_b_r']
    dependlist['op_b_s'] = ['op_d_s']
    dependlist['op_b_r'] = ['op_d_r']
    dependlist['op_b_w'] = ['op_d_r','op_d_c']
    dependlist['op_b_a'] = ['op_d_c','op_d_a','op_b_r']
    dependlist['op_b_so'] = ['op_d_c','op_d_a']
    dependlist['op_b_jar'] = ['op_d_a']
    printlog('init dependlist = ')
    for key in dependlist:
        printlog('key=' + key + ' value=' + str(dependlist[key]))

def setop(op):
    for value in oplist:
        if value[0] == op:
            value[1] = True
            if op in dependlist:
                deps = dependlist[op]
                for dep in deps:
                    setop(dep)

def runOperation():
    printlog('--------------------------run operations!!!--------------------------')
    for value in oplist:
        if value[1] and len(value) == 3:
            value[2]()

#---------------------------Build function------------------------------------
def Download_CoreCode():
    printlog('--------------------------run step Download_CoreCode,please waiting--------------------------')
    DownloadSVN(Code_Core_URL, Code_Core_Native_Path)
        
def Download_ClientCode():
    printlog('--------------------------run step Download_ClientCode,please waiting--------------------------')
    del_folder(Code_Client_Native_Path+"/build")
    DownloadSVN(Code_Client_URL, Code_Client_Native_Path)

def Download_Client():
    Download_CoreCode()
    Download_ClientCode()
    
def Download_Resource():
    printlog('--------------------------run step Download_Resource,please waiting--------------------------')
    DownloadSVN(Resource_Client_URL, Resource_Client_Native_Path)
    #del_folder(Resource_Client_Native_Path+'/.svn')

    if ftp_remote_dir_psv!= '' and newVersion.split(".")[2] != '0':
        FTP_Download_zip_for_Directory(Pre_Resource_Native_Path, ftp_remote_dir_psv + '/' + Resource_Client_FileName + '.zip')
        FTP_Download_zip_for_Directory(Pre_Update_Native_Path, ftp_remote_dir_psv + '/' + Resource_Update_FileName + '.zip')
    else:
        printlog('Download_PreResource:build big version, skip this op')

def Download_AndroidCode():
    printlog('--------------------------run step Download_AndroidCode,please waiting--------------------------')
    DownloadSVN(Code_Android_URL, Code_Android_Native_Path)

def Download_ServerCode():
    printlog('--------------------------run step Download_ServerCode,please waiting--------------------------')
    DownloadSVN(Code_Server_URL, Code_Server_Native_Path)
    
def Build_Resource():
    printlog('--------------------------run step Build_Resource,please waiting--------------------------')
    #del_files(Resource_Client_Native_Path,['.dll','.exe','.pdb','.bat','.log'])
    Build_EncResource()
    if ftp_remote_dir_psv!= '':
        Build_UpdateResource()

def Build_EncResource():
    run_cmd(Version_Build_Native_Path + "/Utility_Build_EncResource.bat")

def BuildUpdateFileForPlatform(platform):
    printlog("----------BuildUpdateFileForPlatform:"+platform+"----------")
    filePath = Resource_Update_Native_Path + '/update.php'
    updateFile = []
    if os.path.exists(filePath):
        f = open(filePath)
        updateFile = json.load(f)
        printlog(str(updateFile))
        f.close()
    
    files = updateFile['files']
    newfiles = []
    newsize = 0
    if files != None:
        #add outside path files
        for fileItem in files:
            filepath = fileItem['f']
            if filepath.find('/platforms/') == -1:
                newfiles.append(fileItem)
                newsize = newsize + fileItem['s']

        #add inside path files, ensure replace them when there are same files
        for fileItem in files:
            filepath = fileItem['f']
            if filepath.find('/platforms/') != -1:
                if filepath.find('/platforms/android_' + platform + '/') != -1:                    
                    newfileItem = fileItem
                    newfileItem['f'] = newfileItem['f'].replace('/platforms/android_' + platform + '/', '/')
                    #check same file
                    isHasSameFile = False
                    for fileItemInNew in newfiles:
                        if fileItemInNew['f'] == newfileItem['f']:
                            sizeGap = newfileItem['s'] - fileItemInNew['s']
                            fileItemInNew['s'] = newfileItem['s']
                            fileItemInNew['c'] = newfileItem['c']
                            newsize = newsize + sizeGap
                            isHasSameFile = True

                    if not isHasSameFile:
                        newfiles.append(newfileItem)
                        newsize = newsize + newfileItem['s']    
                    
                elif filepath.find('/platforms/ios_' + platform + '/') != -1:
                    newfileItem = fileItem
                    newfileItem['f'] = newfileItem['f'].replace('/platforms/ios_' + platform + '/', '/')
                    #check same file
                    isHasSameFile = False
                    for fileItemInNew in newfiles:
                        if fileItemInNew['f'] == newfileItem['f']:
                            sizeGap = newfileItem['s'] - fileItemInNew['s']
                            fileItemInNew['s'] = newfileItem['s']
                            fileItemInNew['c'] = newfileItem['c']
                            newsize = newsize + sizeGap
                            isHasSameFile = True

                    if not isHasSameFile:
                        newfiles.append(newfileItem)
                        newsize = newsize + newfileItem['s']
    
    updateFile['files'] = newfiles
    updateFile['totalByteSize'] = newsize
    
    f = file(Resource_Update_Native_Path + '/update_' + platform + '.php',"w")
    f.write(json.dumps(updateFile, ensure_ascii=False, encoding="utf-8", indent = 4, sort_keys=True))
    f.close()
         
def Build_UpdateResource():
    printlog('--------------------------run step Build_UpdateResource,please waiting--------------------------')
    if newVersion.split(".")[2] != '0':
        run_cmd(Version_Build_Native_Path + "/Utility_Build_UpdateResource.bat " + newVersion)
        del_folder(Pre_Update_Native_Path)
        del_folder(Pre_Resource_Native_Path)

        targetsNeedBuild = []
        for target in res_args:
            if target not in targetsNeedBuild and target != '':
               targetsNeedBuild.append(target)
            
        for target in Android_args:
            if target[0] not in targetsNeedBuild and target[0] != '':
               targetsNeedBuild.append(target[0])
            
        for target in IOS_args:
            if target[0] not in targetsNeedBuild and target[0] != '':
               targetsNeedBuild.append(target[0])                

        for target in targetsNeedBuild:
            BuildUpdateFileForPlatform(target)
    else:
        printlog('Build_UpdateResource:build big version, skip this op')

def Build_Server():
    printlog('--------------------------run step Build_Server,please waiting--------------------------')
    run_cmd('ant -f ' + Code_Server_Native_Path + '/build.xml')
    
def Build_Win32():
    printlog('--------------------------run step Build_Win32,please waiting--------------------------')
    run_cmd(Code_Client_Native_Path + '/buildWin32.bat')
    
    client_path = Native_SVN_Root_Path+'/Client.zip'
    del_file(client_path)
    zip_dir(Resource_Client_Native_Path,client_path)

def Build_Android_SO():
    printlog('--------------------------run step Build_Android_SO,please waiting--------------------------')
    run_cmd(Code_Client_Native_Path + '/buildAndroid.bat')

def Build_Android_Jar():
    printlog('--------------------------run step Build_Android_Jar,please waiting--------------------------')
    run_cmd(Code_Android_Native_Path + '/sdklibs/antbuild/BuildRelease.bat')
        
def Build_Android():
    printlog('--------------------------run step Build_Android,please waiting--------------------------')
    if os.path.isdir(Android_ApkOut_Path):
        shutil.rmtree(Android_ApkOut_Path)
    run_cmd(Makedir_cmdstr.substitute(PATH=Android_ApkOut_Path.replace('/','\\')))

    run_cmd(Code_Android_Native_Path + '/copyAssets.bat')

    for target in Android_args:
        run_cmd(Code_Android_Native_Path + '/buildApk.bat ' + target[0] + ' ' + target[1] + ' ' + newVersion)

    #for target in Android_args:
    #    run_cmd(Code_Android_Native_Path + '/buildWorkspace.bat ' + target[0] + ' ' + target[1] + ' ' + newVersion + ' ' + timestr)
    #Commit_Android_workspace()
        
    #for target in Android_args[:-1]:
    #    run_cmd(BuildAndroid_cmdstr.substitute(platform=target[0],versionCode=target[1],versionName=newVersion,time=timestr))
    
    #if len(Android_args) >0:
    #    run_cmd(BuildAndroidWait_cmdstr.substitute(platform=Android_args[-1][0],versionCode=Android_args[-1][1],versionName=newVersion,time=timestr))

def Build_IOS():
    printlog('--------------------------run step Build_IOS,please waiting--------------------------')
    Build_IOS_Job()
    
def Commit_Server():
    printlog('--------------------------run step Commit_Server,please waiting--------------------------')
    f.login()
    f.upload_file(Code_Server_Native_Path+'/Server.zip', ftp_remote_dir_sv+'/Server.zip')

def Commit_Windows():
    printlog('--------------------------run step Commit_Windows,please waiting--------------------------')
    f.login()
    f.upload_file(Native_SVN_Root_Path+'/Client.zip', ftp_remote_dir_sv+'/Client_win32.zip')

def Commit_Android_workspace():
    printlog('--------------------------run step Commit_Android_workspace,please waiting--------------------------')
    f.login()
    for target in Android_args:
        workspaceName = 'workspace_' + target[0] + '_' +target[1] + '_' + newVersion + '_' + timestr
        workspacePath = Code_Android_Native_Path + '/' + workspaceName
        FTP_Commit_Directory_for_zip(workspacePath, ftp_remote_dir_sv+'/'+workspaceName+'.zip')
    
def Commit_Android():
    printlog('--------------------------run step Commit_Android,please waiting--------------------------')
    f.login()
    f.upload_files(Android_ApkOut_Path, ftp_remote_dir_sv)

    workspacefile = Android_WorkspaceOut_Path +'.zip'
    zip_dir(Android_WorkspaceOut_Path,workspacefile)
    f.upload_file(workspacefile, ftp_remote_dir_sv+'/android_workspace_backup_' + timestr + '.zip')
    
    del_file(workspacefile)
    del_folder(Android_WorkspaceOut_Path)
      
def Commit_Android_SO():
    printlog('--------------------------run step Commit_Android_SO,please waiting--------------------------')
    run_cmd(Commit_cmdstr.substitute(PATH=Code_Android_GameAndroid_Native_Path+'/libs/armeabi'))
    run_cmd(Commit_cmdstr.substitute(PATH=Code_Android_GameLib_Native_Path+'/libs/armeabi'))

def Commit_Android_Jar():
    printlog('--------------------------run step Commit_Android_SO,please waiting--------------------------')
    run_cmd(Commit_cmdstr.substitute(PATH=Code_Android_Native_Path+'/sdklibs'))
        
def Commit_Resource():
    printlog('--------------------------run step Commit_Resource,please waiting--------------------------')
    
    tempPath = Resource_Client_Native_Path+'_temp'
    del_folder(tempPath)
    run_cmd(Makedir_cmdstr.substitute(PATH=tempPath.replace('/','\\')))
    run_cmd(CopyFile_cmdstr_Mac.substitute(src_Path=Resource_Client_Native_Path+'/*',des_Path=tempPath))
    del_folder(tempPath+'/.svn')
    del_files(tempPath,['.dll','.exe','.pdb','.bat','.log'])
    FTP_Commit_Directory_for_zip(tempPath, ftp_remote_dir_sv + '/' + Resource_Client_FileName+'.zip')
    
    FTP_Commit_Directory_for_zip(Resource_Encrypt_Native_Path, ftp_remote_dir_sv + '/' + Resource_Enc_FileName + '.zip')
    #del_folder(Resource_Encrypt_Native_Path)
    
    if ftp_remote_dir_psv!= '' and newVersion.split(".")[2] != '0':
        FTP_Commit_Directory_for_zip(Resource_Update_Native_Path, ftp_remote_dir_sv + '/' + Resource_Update_FileName + '.zip')
        del_folder(Resource_Update_Native_Path)

def Creat_Tag():
    printlog('--------------------------run step Creat_Tag,please waiting--------------------------')
    if Base_Tag_URL !='':
        run_cmd(TagBranch_cmdstr.substitute(SRC_URL = Base_URL, DST_URL = Base_Tag_URL))

#---------------------------Build job------------------------------------
def Build_Server_Job():
    run_cmd(BuildServer_cmdstr.substitute(time=timestr,version=newVersion))
    
def Build_Win32_Job():
    run_cmd(BuildWin32_cmdstr.substitute(time=timestr,version=newVersion))

def Build_IOS_Job():
    config_ios = 'Release'
    platform_ios = repr(IOS_args)
    printlog(platform_ios)
    if platform_ios != '':
        run_cmd(BuildIOS_cmdstr.substitute(time=timestr,version=newVersion,config=config_ios,platform=platform_ios))
    