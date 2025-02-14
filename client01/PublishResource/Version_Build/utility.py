#coding=utf-8

import os
import os.path
import sys
import time
from ftplib import FTP
import socket
import zipfile
import shutil
import json

from path_define import *
from svn_cmd import *

reload(sys)
sys.setdefaultencoding('utf-8')

def deal_error(e):   
    timenow  = time.localtime()   
    datenow  = time.strftime('%Y-%m-%d', timenow)   
    logstr = '%s an error occurred: %s' %(datenow, e)   
    printlog(logstr)   
    file.write(logstr)   
    sys.exit()  
    
def printlog(*args):
    timestr = time.strftime('%Y-%m-%d_%H%M%S',time.localtime(time.time()))
    sys.stdout.write('['+timestr+']')
    sys.stdout.write(" ".join(args))
    sys.stdout.write("\n")
    sys.stdout.flush()

def printDictLog(dict):
    str = '{'
    for key in dict:
        str = str + key + ':' + dict[key] + ','
    str = str + '}'
    printlog(str)
        
def run_cmd(cmdstr):
    printlog(cmdstr.split(' --username')[0])
    ret = os.system(cmdstr)
    if ret < 0:
        printlog('run_cmd result = ' + str(ret))
        exit(0)
    else:
        printlog('run_cmd result = ' + str(ret))

def CheckoutSVN(url, path):
    #printlog('CheckoutSVN: ' + url + ' to path:' + path)
    run_cmd(Checkout_cmdstr.substitute(URL=url,PATH=path))
    
def UpdateSVN(url, path):
    #printlog('UpdateSVN: ' + url + ' to path:' + path)
    run_cmd(CleanUp_cmdstr.substitute(PATH=path))
    run_cmd(Revert_cmdstr.substitute(PATH=path))
    run_cmd(Switch_cmdstr.substitute(URL=url,PATH=path))

def DownloadSVN(url, path, forceDelete = False):
    if forceDelete:
        del_folder(path)
        CheckoutSVN(url, path)
    else:
        if os.path.isdir(path):
            UpdateSVN(url, path)
        else:
            CheckoutSVN(url, path)

#    fileType: "all","file","folder"
def list_SVNURL(URL,fileType='all',recursive=False):
    cmd = ''
    if recursive:
        cmd = List_cmdstr_R.substitute(URL=URL)
    else:
        cmd = List_cmdstr.substitute(URL=URL)
    output = os.popen(cmd)
    pathlist = []
    if fileType == "all":
        pathlist = [ path.strip('\n') for path in output]
    elif fileType == "file":
        pathlist = [ path.strip('\n') for path in output if not path.strip('\n')[-1] == '/']
    elif fileType == "folder":
        pathlist = [ path.strip('\n') for path in output if path.strip('\n')[-1] == '/']
    output.close()
    
    return pathlist

def isFileExistInSVN(URL,fileName):
    pathlist = list_SVNURL(URL)
    return fileName in pathlist

def del_files(dir,filter_exts=[],filter_names=[],topdown=True):  
    for root, dirs, files in os.walk(dir, topdown):  
        for name in files:
            if (name in filter_names):
                os.remove(os.path.join(root, name))  
                print('del ' + os.path.join(root,name))
            else:
                pathname = os.path.splitext(os.path.join(root, name))  
                if (pathname[1] in filter_exts):  
                    os.remove(os.path.join(root, name))  
                    print('del ' + os.path.join(root,name))


def del_folder_content(dir, dir_filter=[], file_filter=[], topdown=True):
    for root, dirs, files in os.walk(dir, topdown):
        for foldername in dirs:
            if (foldername not in dir_filter):
                if os.path.isdir(os.path.join(root, foldername)):
                    shutil.rmtree(os.path.join(root, foldername),True,None)
                else:
                    printlog('folder not exist!')
                print('del folder:' + os.path.join(root, foldername))
                
        for filename in files:
            if (filename not in file_filter):
                if os.path.isfile(os.path.join(root, filename)):
                    os.remove(os.path.join(root, filename))
                else:
                    printlog('file not exist!')
                print('del file:' + os.path.join(root, filename))
                
                
def del_folder(folder_path, ignore_errors=True, onerror=None):
    printlog('del folder:' + folder_path)
    if os.path.isdir(folder_path):
        shutil.rmtree(folder_path,ignore_errors,onerror)
    else:
        printlog('folder not exist!')
        
def del_file(file_path):
    printlog('del file:' + file_path)
    if os.path.isfile(file_path):
        os.remove(file_path)
    else:
        printlog('file not exist!')

def copy_tree_overlap(src, dst, symlinks=False):
    names = os.listdir(src)
    if not os.path.isdir(dst):
        os.makedirs(dst)
        
    errors = []
    for name in names:
        srcname = os.path.join(src, name)
        dstname = os.path.join(dst, name)
        try:
            if symlinks and os.path.islink(srcname):
                linkto = os.readlink(srcname)
                os.symlink(linkto, dstname)
            elif os.path.isdir(srcname):
                copy_tree_overlap(srcname, dstname, symlinks)
            else:
                if os.path.isdir(dstname):
                    os.rmdir(dstname)
                elif os.path.isfile(dstname):
                    os.remove(dstname)
                shutil.copy2(srcname, dstname)
        except (IOError, os.error) as why:
            errors.append((srcname, dstname, str(why)))
        except OSError as err:
            errors.extend(err.args[0])
    try:
        shutil.copystat(src, dst)
    except WindowsError:
        pass
    except OSError as why:
        errors.extend((src, dst, str(why)))
    if errors:
        raise shutil.Error(errors)


def get_ios_cfg_name(key):
    platform_2_cfg = {'GameR2':'version_ios_r2_en.cfg','GameEfun':'version_ios_efun_en.cfg','GameEfunTri':'version_ios_efun_tw.cfg','GameEntermate':'version_ios_entermate_kr.cfg','GameGNetop':'version_ios_gnetop_jp.cfg'}
    res = platform_2_cfg.get(key, "version_ios_r2_en.cfg")
    return res

def modify_version_cfg(file_path, version):
    print ('modify file:' + file_path)
    print ('target version:' + version)
    if os.path.isfile(file_path):
        file = open(file_path, "r")
        readData = file.read()
        file.close()
        content = json.loads(readData)
        localVersion = content["localVerson"]
        serverURL = content["sever"]
        serverURLBackUp = content["severBackup"]
        print 'old version:' + localVersion
        print 'old serverURL:' + serverURL
        print 'old serverURLBackUp:' + serverURLBackUp
        
        localVersion = version		
        index_version = localVersion.rindex(".")
        
        index_1 = serverURL.rindex("/")
        index_2 = serverURL.rindex("/", 0, index_1 - 1)
        serverURL = serverURL.replace(serverURL[index_2 + 1:index_1], localVersion[0:index_version])
        
        index_1 = serverURLBackUp.rindex("/")
        index_2 = serverURLBackUp.rindex("/", 0, index_1 - 1)
        serverURLBackUp = serverURLBackUp.replace(serverURLBackUp[index_2 + 1:index_1], localVersion[0:index_version])
        
        content["localVerson"] = localVersion
        content["sever"]= serverURL
        content["severBackup"]= serverURLBackUp
        
        print 'new version:' + localVersion
        print 'new serverURL:' + serverURL
        print 'new serverURLBackUp:' + serverURLBackUp
        
        fileWrite = open(file_path,'w+')
        fileWrite.write(json.dumps(content, ensure_ascii=False, encoding="utf-8", indent = 4, sort_keys=True))
        fileWrite.flush()
    else:
        print 'file not exist! target path:' + file_path
#---------------------------zip function------------------------------------
def zip_dir(dirname,zipfilename):
    filelist = []
    if os.path.isfile(dirname):
        filelist.append(dirname)
    else :
        for root, dirs, files in os.walk(dirname):
            for name in files:
                filelist.append(os.path.join(root, name))
        
    zf = zipfile.ZipFile(zipfilename, "w", zipfile.zlib.DEFLATED)
    for tar in filelist:
        arcname = tar[len(dirname):]
        #print arcname
        zf.write(tar,arcname)
    zf.close()

def unzip_file(zipfilename, unziptodir):
    if not os.path.exists(unziptodir): os.mkdir(unziptodir, 0777)
    try: 
        zfobj = zipfile.ZipFile(zipfilename)
        for name in zfobj.namelist():
            name = name.replace('\\','/')
       
            if name.endswith('/'):
                os.mkdir(os.path.join(unziptodir, name))
            else:            
                ext_filename = os.path.join(unziptodir, name)
                ext_dir= os.path.dirname(ext_filename)
                if not os.path.exists(ext_dir) : 
                    os.makedirs(ext_dir,0777)
                outfile = open(ext_filename, 'wb')
                outfile.write(zfobj.read(name))
                outfile.close()
    except Exception:   
        printlog("unzip_file failed")

#---------------------------FTP function------------------------------------
class MYFTP:   
    def __init__(self, hostaddr, username, password, remotedir, port=21):   
        self.hostaddr = hostaddr   
        self.username = username   
        self.password = password   
        self.remotedir  = remotedir   
        self.port     = port   
        self.ftp      = FTP()   
        self.file_list = []   
        # self.ftp.set_debuglevel(2)

    def __del__(self):   
        self.ftp.close()   
        # self.ftp.set_debuglevel(0)
        
    def login(self):   
        ftp = self.ftp   
        try:    
            timeout = 60  
            socket.setdefaulttimeout(timeout)   
            ftp.set_pasv(False)   
            print 'Begin to connect to  %s' %(self.hostaddr)   
            ftp.connect(self.hostaddr, self.port)   
            print 'Successfully connected to the %s' %(self.hostaddr)   
            print 'start to log in %s' %(self.hostaddr)   
            ftp.login(self.username, self.password)   
            print 'success to log in  %s' %(self.hostaddr)   
            printlog(ftp.getwelcome())   
        except Exception:   
            deal_error("connections or login failed")   
        try:   
            ftp.cwd(self.remotedir)   
        except(Exception):   
            deal_error('fail to change directory')   
  
    def is_same_size(self, localfile, remotefile):   
        try:   
            remotefile_size = self.ftp.size(remotefile)   
        except:   
            remotefile_size = -1  
        try:   
            localfile_size = os.path.getsize(localfile)   
        except:   
            localfile_size = -1  
        printlog('lo:%d  re:%d' %(localfile_size, remotefile_size),)   
        if remotefile_size == localfile_size:   
            return 1  
        else:   
            return 0

    def download_file(self, localfile, remotefile):   
        if self.is_same_size(localfile, remotefile):   
            printlog('%s file of the same size, no download' %localfile)   
            return  
        else:   
            printlog('>>>>>>>>>>>>download file  %s ... ...' %localfile)   
        #return   
        file_handler = open(localfile, 'wb')   
        self.ftp.retrbinary('RETR %s'%(remotefile), file_handler.write)   
        file_handler.close()   
  
    def download_files(self, localdir='./', remotedir='./'):   
        try:   
            self.ftp.cwd(remotedir)   
        except:   
            printlog('directory %s does not exist��continue...' %remotedir)
            return  
        if not os.path.isdir(localdir):   
            os.makedirs(localdir)   
        printlog('change to the directory  %s' %self.ftp.pwd())   
        self.file_list = []   
        self.ftp.dir(self.get_file_list)   
        remotenames = self.file_list   
        #print(remotenames)   
        #return   
        for item in remotenames:   
            filetype = item[0]   
            filename = item[1]   
            local = os.path.join(localdir, filename)   
            if filetype == 'd':   
                self.download_files(local, filename)   
            elif filetype == '-':   
                self.download_file(local, filename)   
        self.ftp.cwd('..')   
        printlog('Return to parent directory  %s' %self.ftp.pwd())

    def upload_file(self, localfile, remotefile):   
        if not os.path.isfile(localfile):   
            return  
        if self.is_same_size(localfile, remotefile):   
            printlog('Skip [equal]: %s' %localfile)   
            return  
        file_handler = open(localfile, 'rb')   
        self.ftp.storbinary('STOR %s' %remotefile, file_handler)   
        file_handler.close()   
        printlog('already upload: %s' %localfile)

    def upload_files(self, localdir='./', remotedir = './'):   
        if not os.path.isdir(localdir):   
            return  
        localnames = os.listdir(localdir)
        if '.svn' in localnames:
            localnames.remove('.svn')
        try:   
            self.ftp.cwd(remotedir)   
        except:   
            printlog('dir is not exist  %s' %remotedir)
            self.mk_dir(remotedir)
            
        printlog(self.ftp.pwd())
        for item in localnames:   
            src = os.path.join(localdir, item)   
            if os.path.isdir(src):   
                try:   
                    self.ftp.mkd(item)   
                except:   
                    printlog('dir is exist  %s' %item)   
                self.upload_files(src, item)
            else:   
                self.upload_file(src, item)   
        self.ftp.cwd('..')
  
    def get_file_list(self, line):   
        ret_arr = []   
        file_arr = self.get_filename(line)   
        if file_arr[1] not in ['.', '..']:   
            self.file_list.append(file_arr)   
               
    def get_filename(self, line):   
        pos = line.rfind(':')   
        while(line[pos] != ' '):   
            pos += 1  
        while(line[pos] == ' '):   
            pos += 1  
        file_arr = [line[0], line[pos:]]   
        return file_arr

    def mk_dir(self, remotedir):
        try:
            printlog('creat dir %s' %remotedir)   
            self.ftp.mkd(remotedir)
            self.ftp.cwd(remotedir)
        except:   
            printlog('dir is exist  %s' %remotedir)
    
    def get_remotedir_list(self, remotedir, type=0):#0-all,1-file,2-folder
        try:   
            self.ftp.cwd(remotedir)
        except:   
            printlog('directory %s does not exist��continue...' %remotedir)
            return
        printlog('change to the directory  %s' %self.ftp.pwd())
        self.file_list = []   
        self.ftp.dir(self.get_file_list)
        remotenames = self.file_list
        if  type==0:  
            return [x[1] for x in remotenames]
        elif type==2:
            return [x[1] for x in remotenames if x[0] == 'd']
        elif type==1:
            return [x[1] for x in remotenames if x[0] == '-']
        
    def is_remotedir_exist(self, remotedir):
        try:   
            self.ftp.cwd(remotedir)
            return True
        except:
            return False
