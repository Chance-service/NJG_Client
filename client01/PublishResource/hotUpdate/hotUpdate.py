#!/usr/bin/python
# -*- coding: utf-8 -*-

import os
import sys
import shutil
import glob
import json
import time
import zipfile
from struct import pack
from struct import unpack
import gc
import hashlib
#import datetime

workpath = ""
#output_path = ""
Res_assets = ""
Res_ZipDone =""
upjsonfile = "update.php"
buffsize = 1024*1024
zipsizelimit = 50*1024*1024

def printdebug(str):
    print str
    return

def _calcCRC(crc, byte): # 跑單一byte
    table = [0x0000, 0xCC01, 0xD801, 0x1400, 0xF001, 0x3C00, 0x2800, 0xE401,0xA001, 0x6C00, 0x7800, 0xB401, 0x5000, 0x9C01, 0x8801, 0x4400]
    # compute checksum of lower four bits of byte
    tmp = table[crc & 0xF]
    crc = (crc >> 4) & 0x0FFF
    crc = crc ^ tmp ^ table[byte & 0xF]
    # now compute checksum of upper four bits of byte
    tmp = table[crc & 0xF]
    crc = (crc >> 4) & 0x0FFF
    crc = crc ^ tmp ^ table[(byte >> 4) & 0xF]
    return crc

def _calcCRCByData(crc,data): # data = tuple

    table = [0x0000, 0xCC01, 0xD801, 0x1400, 0xF001, 0x3C00, 0x2800, 0xE401,0xA001, 0x6C00, 0x7800, 0xB401, 0x5000, 0x9C01, 0x8801, 0x4400]
    # compute checksum of lower four bits of byte
    for i in range(len(data)) :
        tmp = table[crc & 0xF]
        crc = (crc >> 4) & 0x0FFF
        crc = crc ^ tmp ^ table[data[i] & 0xF]
        # now compute checksum of upper four bits of byte
        tmp = table[crc & 0xF]
        crc = (crc >> 4) & 0x0FFF
        crc = crc ^ tmp ^ table[(data[i] >> 4) & 0xF]
    del i
    gc.collect()
    return crc

def getCRC16(apath):
    size = os.path.getsize(apath) #获得文件大小
    crcvalue = 0
    # with open(apath, 'rb', 0) as f: 
        # mm = mmap(f.fileno(), 0, access=ACCESS_READ)
        # for chunk in mm: # length is equal to the current file size
            # crcvalue = _calcCRCByData(crcvalue,unpack('b',chunk))
        # mm.close()
    with open(apath, 'rb') as binfile: #打开二进制文件
        if (size >= buffsize):
            for chunk in iter(lambda: binfile.read(buffsize), ''):
                crcvalue = _calcCRCByData(crcvalue,unpack(str(buffsize)+'b',chunk))
                size = size - buffsize
                if (size < buffsize):
                    break
            if (size > 0):
                for chunk in iter(lambda: binfile.read(size), ''):
                    crcvalue = _calcCRCByData(crcvalue,unpack(str(size)+'b',chunk))
        elif (size > 0):
            for chunk in iter(lambda: binfile.read(size), ''):
                crcvalue = _calcCRCByData(crcvalue,unpack(str(size)+'b',chunk))
    del chunk
    gc.collect()
    return crcvalue

def getMd5(filename):
    m = hashlib.md5()
    with open(filename, "rb") as f:
      for chunk in iter(lambda: f.read(4096), b""): # 分批讀取檔案內容，計算 MD5 雜湊值
        m.update(chunk)
    return m.hexdigest()

def FolderToZip():
    filelist = os.listdir(Res_assets)
    printdebug(filelist)
    for adir in filelist:
        fulldir = os.path.join(Res_assets,adir)
        if os.path.isdir(fulldir):
            print("ZIP..... :"+fulldir)
            zippath = os.path.join(Res_ZipDone,adir+'.zip')
            zf = zipfile.ZipFile(zippath,mode='w',compression=zipfile.ZIP_DEFLATED)
            os.chdir(fulldir)
            fileidx = 1
            for root,folders,files in os.walk(fulldir):
                fpath = root.replace(Res_assets,'') #壓縮檔內的檔案路徑,加上與檔名相同的資料夾
                fpath = fpath and fpath + os.sep or ''
                for sfile in files:
                    if (os.path.getsize(zippath) >= zipsizelimit):
                        zf.close()
                        zippath = os.path.join(Res_ZipDone,adir+'_'+str(fileidx)+'.zip')
                        print("zippath..... :"+adir+'_'+str(fileidx)+'.zip')
                        zf = zipfile.ZipFile(zippath,mode='w',compression=zipfile.ZIP_DEFLATED)
                        fileidx = fileidx + 1
                    aFile = os.path.join(root,sfile)    #被壓縮的檔案路徑
                    #printdebug('aFile :'+ aFile) 
                    bfile = fpath+sfile     
                    #printdebug('bfile: '+ bfile) 
                    zf.write(aFile,bfile)
            zf.close()

def Expotr_Manifest():
    fulljsonfile = os.path.join(ResUp_path,upjsonfile)
    printdebug("jsonphp FilePath : "+ fulljsonfile)

    fileobj = open(fulljsonfile,"r") #開啟檔案設唯讀,預設位置文件頭
    astr = fileobj.read() #讀取檔案到STR
    fileobj.close()
    #printdebug("jsonString : "+ astr)
    jsondict = json.loads(astr) #轉為python dictionary字典
    #printdebug(jsondict)
    jsonex ={}
    jsonex['assets'] = list()
    if jsondict.has_key('files'):
        for dict in jsondict['files']:
            edict ={}
            if dict.has_key('c'):
                edict['crc'] = str(dict['c'])
            if dict.has_key('f'):
                edict['name'] = dict['f'][1:len(dict['f'])]
            if dict.has_key('s'):
                edict['size'] = round(dict['s']*0.001,3)
                #printdebug(edict['size'])
            edict['md5'] = 0 # getMd5(apath)
            #printdebug(edict)
            jsonex['assets'].append(edict);
            #edict.clear()
    #outjson = json.dumps(jsonex, indent = 4) 
    #printdebug(outjson)
    outfile_name = 'project.manifest'
    with open(outfile_name,'w') as file_object:
        json.dump(jsonex,file_object,indent = 4) #轉換成json,順便轉成易閱讀模式

def outputManifest():
    #filelist = os.listdir(Res_ZipDone)
    #printdebug(filelist)
    os.chdir(Res_ZipDone)
    filetype = os.path.join(Res_ZipDone,"*.zip")
    filelist = glob.glob(filetype) # 完整路徑 list
    print(filelist)
    jsonex ={}
    jsonex['assets'] = list()
    for fullpath in filelist:
        edict ={}
        edict['size'] = round(os.path.getsize(fullpath)*0.001,3)
        edict['name'] = os.path.basename(fullpath)
        edict['md5'] =  getMd5(fullpath)
        edict['crc'] = str(getCRC16(fullpath))
        print('%s = %.3f bytes crc = %s md5 = %s '% (edict['name'], edict['size'],edict['crc'],edict['md5']))
        jsonex['assets'].append(edict)
        outfile_name = 'project.manifest'
	jsonex['time'] = time.time()
    with open(outfile_name,'w') as file_object:
        json.dump(jsonex,file_object,indent = 4) #轉換成json,順便轉成易閱讀模式

def initPath():

    global workpath
    workpath = os.getcwd()
    printdebug("Now WorkPath : "+workpath)

    global Res_assets
    Res_assets =  os.path.join(workpath,"assets")

    global Res_ZipDone
    Res_ZipDone = os.path.join(workpath,"Resource_Client")

    if not os.path.exists(Res_assets):
        os.mkdir(Res_assets)
        
    if not os.path.exists(Res_ZipDone):
        os.mkdir(Res_ZipDone)
    else:
        shutil.rmtree(Res_ZipDone)
        os.mkdir(Res_ZipDone)
    return True

if __name__ == '__main__':
    if initPath():
        FolderToZip()
        outputManifest()
    print "All OK"