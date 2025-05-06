#coding=utf-8

from utility import *
import time
#---------------------------setup FTP command------------------------------------
hostaddr = '10.0.2.20' 
username = 'youai'   
password = 'youaihudong'   
port  =  21
rootdir_remote = './'
             
myFTP = MYFTP(hostaddr, username, password, rootdir_remote, port)
f = myFTP
f.login()
ftp_remote_dir = '/VersionBuild/Gjabd/VersionBuild/'
ftp_remote_dailyBuild_dir = '/VersionBuild/Gjabd/DailyBuild/'
#---------------------------FTP function------------------------------------
def getReleaseVersionList():
    rlist = f.get_remotedir_list(ftp_remote_dir,2)
    printlog(str(rlist))
    return rlist

def getBigVersionList(releaseversion):
    blist = f.get_remotedir_list(ftp_remote_dir + releaseversion,2)
    printlog(str(blist))
    return blist
    
def getSmallVersionList(bigversion):
    releaseversion = bigversion.rpartition('.')[0]
    slist = f.get_remotedir_list(ftp_remote_dir + releaseversion + '/' + bigversion,2)
    printlog(str(slist))
    return slist 

def getLatestSmallVersion():
    release_versions = f.get_remotedir_list(ftp_remote_dir,2)
    if len(release_versions) > 0:
        release_version = release_versions[0]
        curNum = 0
        for ver in release_versions:
            try: 
                verNum = string.atoi(ver.split(".")[1])
            except:
                printlog('invalid %s literal for convert to int' %ver)
                continue
            if verNum > curNum:
                curNum = verNum
                release_version = ver
    else:
        printlog('getLatestSmallVersion error:get can not find release_version')
        sys.exit(1)
    release_version_path = ftp_remote_dir + release_version
    big_versions = f.get_remotedir_list(release_version_path,2)
    if len(big_versions) > 0:
        big_version = big_versions[0]
        curNum = 0
        for ver in big_versions:
            try: 
                verNum = string.atoi(ver.split(".")[1])
            except:
                printlog('invalid %s literal for convert to int' %ver)
                continue
            if verNum > curNum:
                curNum = verNum
                big_version = ver
    else:
        printlog('getLatestSmallVersion error:get a invalid release_version')
        sys.exit(1)
    big_version_path = release_version_path + '/' + big_version
    small_versions = f.get_remotedir_list(big_version_path,2)
    if len(small_versions) > 0:
        curNum = 0
        for ver in small_versions:
            try: 
                verNum = string.atoi(ver.split(".")[3])
            except:
                printlog('invalid %s literal for convert to int' %ver)
                continue
            if verNum > curNum:
                curNum = verNum
        return  big_version +  '.' + str(curNum + 1)
    else:
        printlog('getLatestSmallVersion error:get a invalid big_version')
        sys.exit(1)

def FTP_Commit_Directory_for_zip(native_folderPath, ftp_url):
    native_zipfile_path = Native_SVN_Root_Path+ '/temp_'+str(time.time())+'.zip'
    zip_dir(native_folderPath, native_zipfile_path)
    
    f.login()
    f.upload_file(native_zipfile_path, ftp_url)

    del_file(native_zipfile_path)
    
def FTP_Download_zip_for_Directory(native_folderPath, ftp_url):
    native_zipfile_path = native_folderPath + '.zip'
    del_folder(native_folderPath)
    
    f.login()
    f.download_file(native_zipfile_path, ftp_url)
    unzip_file(native_zipfile_path,native_folderPath)
    
    del_file(native_zipfile_path)