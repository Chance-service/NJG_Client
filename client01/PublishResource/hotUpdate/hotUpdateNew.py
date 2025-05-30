#!/usr/bin/python
# -*- coding: utf-8 -*-

import os
import sys
import shutil
import glob
import json
import time
import zipfile
import gc
import hashlib
from struct import pack
from struct import unpack

workpath = ""
Res_assets = ""
Res_ZipDone = ""
zipsizelimit = 50 * 1024 * 1024
unZipFolder = [ ]
audioFolder = [ "audio" ]
bgFolder = [ "BG" ]
imagesetFolder = [ "Imagesetfile" ]
spineFolder = [ "Spine" ]
uiFolder = [ "UI" ]
videoFolder = [ "Video" ]
jsonex = { }
oldManifestData = { }
savetime = time.time()
global isChangeData

def printdebug(str):
    print str
    return

def getMd5(filename):
    m = hashlib.md5()
    with open(filename, "rb") as f:
      for chunk in iter(lambda: f.read(4096), b""): # 分批讀取檔案內容，計算 MD5 雜湊值
        m.update(chunk)
    return m.hexdigest()

def createAssetsBundle():
    filelist = os.listdir(Res_assets)
    printdebug("0 : All")
    idx = 1
    for file in filelist:
        printdebug("{id:<2d}: {name}".format(id = idx, name = file))
        idx = idx + 1
    tip = u"\n>>>>>輸入編號(多個編號以空白分隔): ".encode("big5", "ignore")
    inputStr = str(raw_input(tip))
    inputStrSplit = inputStr.split(" ")

    isNeedLoadData = True
    for inputIdx in inputStrSplit:
        if inputIdx == "0": # All > 清除全部舊檔案
            print("rmtree.....")
            shutil.rmtree(Res_ZipDone)
            os.mkdir(Res_ZipDone)
            isNeedLoadData = False
            break
    if isNeedLoadData == True:
        loadOldManifest()
        print("loadOldManifest.....")
    else:
        initManifest()
        print("initManifest.....")
    for name in filelist:
        nameIdx = filelist.index(name) + 1
        export = -1
        for inputIdx in inputStrSplit:
            if inputIdx == str(nameIdx) or inputIdx == "0":
                export = 1
        if export > 0:
            print("packing..... : " + name)
            if imagesetFolder.count(name) > 0:
                FolderToImagesetZip(name)
            elif spineFolder.count(name) > 0:
                FolderToSpineZip(name)
            elif uiFolder.count(name) > 0:
                FolderToUiZip(name)
            elif videoFolder.count(name) > 0:
                FolderToVideoZip(name)
            elif bgFolder.count(name) > 0:
                FolderToBgZip(name)
            elif audioFolder.count(name) > 0:
                FolderToAudioZip(name)
            elif unZipFolder.count(name) > 0:
                FolderToCopyFile(name)
            else:
                FolderToZip(name)

def CreateZipPaths(rootFolder, zipNum):
    basePath = os.path.join(Res_ZipDone, rootFolder)
    path = [ ]
    for num in range(0, zipNum):
        path.append(basePath + '_' + str(num) + '.zip')
    return path

def CreateZipFiles(rootFolder, zipNum, path):
    basePath = os.path.join(Res_ZipDone, rootFolder)
    zf = [ ]
    for num in range(0, zipNum):
        zf.append(zipfile.ZipFile(path[num], mode = 'w', compression = zipfile.ZIP_DEFLATED))
    return zf
#--------- audio
def FolderToAudioZip(rootFolder):
    fulldir = os.path.join(Res_assets, rootFolder)
    if os.path.isdir(fulldir):
        zipNum = 6
        path = CreateZipPaths(rootFolder, zipNum)
        zf = CreateZipFiles(rootFolder, zipNum, path)
        os.chdir(fulldir)
        for root, folders, files in os.walk(fulldir):
            fpath = root.replace(Res_assets, '') #壓縮檔內的檔案路徑,加上與檔名相同的資料夾
            fpath = fpath and fpath + os.sep or ''
            for sfile in files:
                aFile = os.path.join(root, sfile)    #被壓縮的檔案路徑
                bfile = fpath + sfile
                fileName = sfile.split(".mp3")
                stat_info = os.stat(aFile)
                aTime = stat_info.st_atime
                mTime = stat_info.st_mtime
                #os.utime(aFile, (315504000, 315504000))
                if sfile.find("bgm") > -1 or sfile.find("BGM") > -1 or sfile.find("Bgm") > -1:
                    zf[1].write(aFile, bfile) #bgm
                elif sfile.find("NGVODRR") > -1:
                    zf[2].write(aFile, bfile) #NGVODRR
                elif sfile.find("fetterGirl") > -1 or sfile.find("Album") > -1:
                    zf[3].write(aFile, bfile) #fetterGirl, Album
                elif sfile.find("Battle") > -1 or sfile.find("NewbieGuide") > -1:
                    zf[4].write(aFile, bfile) #Battle, NewbieGuide
                elif fileName[0].isdigit():
                    zf[5].write(aFile, bfile) #主線語音
                else:
                    zf[0].write(aFile, bfile)
                os.utime(aFile, (aTime, mTime))
        for num in range(0, zipNum):
            zf[num].close()
            addManifestData(path[num])
#--------- BG
def FolderToBgZip(rootFolder):
    fulldir = os.path.join(Res_assets, rootFolder)
    if os.path.isdir(fulldir):
        zipNum = 5
        path = CreateZipPaths(rootFolder, zipNum)
        zf = CreateZipFiles(rootFolder, zipNum, path)
        os.chdir(fulldir)
        for root, folders, files in os.walk(fulldir):
            fpath = root.replace(Res_assets, '') #壓縮檔內的檔案路徑,加上與檔名相同的資料夾
            fpath = fpath and fpath + os.sep or ''
            for sfile in files:
                aFile = os.path.join(root, sfile)    #被壓縮的檔案路徑
                bfile = fpath + sfile
                stat_info = os.stat(aFile)
                aTime = stat_info.st_atime
                mTime = stat_info.st_mtime
                #os.utime(aFile, (315504000, 315504000))
                if fpath.find("AVG") > -1:
                    zf[1].write(aFile, bfile) #主線BG
                elif fpath.find("Battle") > -1:
                    zf[2].write(aFile, bfile) #戰鬥BG
                elif fpath.find("NGEvent") > -1:
                    zf[3].write(aFile, bfile) #循環活動
                elif fpath.find("UI") > -1:
                    zf[4].write(aFile, bfile) #早期UI圖放置
                else:
                    zf[0].write(aFile, bfile)
                os.utime(aFile, (aTime, mTime))
        for num in range(0, zipNum):
            zf[num].close()
            addManifestData(path[num])
#--------- Imageset
def FolderToImagesetZip(rootFolder):
    fulldir = os.path.join(Res_assets, rootFolder)
    if os.path.isdir(fulldir):
        zipNum = 3
        path = CreateZipPaths(rootFolder, zipNum)
        zf = CreateZipFiles(rootFolder, zipNum, path)
        os.chdir(fulldir)
        for root, folders, files in os.walk(fulldir):
            fpath = root.replace(Res_assets, '') #壓縮檔內的檔案路徑,加上與檔名相同的資料夾
            fpath = fpath and fpath + os.sep or ''
            for sfile in files:
                aFile = os.path.join(root, sfile)    #被壓縮的檔案路徑
                bfile = fpath + sfile
                stat_info = os.stat(aFile)
                aTime = stat_info.st_atime
                mTime = stat_info.st_mtime
                #os.utime(aFile, (315504000, 315504000))
                if sfile[0:4] == "i18n":
                    zf[1].write(aFile, bfile) #i18n(多語系檔案)
                elif sfile[0:8] == "ItemIcon" or sfile[0:9] == "EquipIcon" or sfile[0:9] == "Common_UI" or sfile[0:9] == "GroupPage":
                    zf[2].write(aFile, bfile) #ItemIcon, EquipIcon, Common_UI, GroupPage(較常更新)
                else:
                    zf[0].write(aFile, bfile)
                os.utime(aFile, (aTime, mTime))
        for num in range(0, zipNum):
            zf[num].close()
            addManifestData(path[num])
#--------- Spine (CharacterFX, NG2D, NG2DHCG, NGUI內容較大 特殊處理)
def FolderToSpineZip(rootFolder):
    fulldir = os.path.join(Res_assets, rootFolder)
    if os.path.isdir(fulldir):
        zipNum = 9
        path = CreateZipPaths(rootFolder, zipNum)
        zf = CreateZipFiles(rootFolder, zipNum, path)
        #char zip
        charZipNum = 25
        charPath = []
        for num in range(0, charZipNum):
            charPath.append(os.path.join(Res_ZipDone, 'Spine_Char_' + str(num + 1)) + '.zip')
        charZf = []
        for num in range(0, charZipNum):
            charZf.append(zipfile.ZipFile(charPath[num], mode = 'w', compression = zipfile.ZIP_DEFLATED))
        os.chdir(fulldir)
        for root, folders, files in os.walk(fulldir):
            fpath = root.replace(Res_assets, '') #壓縮檔內的檔案路徑,加上與檔名相同的資料夾
            fpath = fpath and fpath + os.sep or ''
            for sfile in files:
                aFile = os.path.join(root, sfile)    #被壓縮的檔案路徑
                bfile = fpath + sfile
                stat_info = os.stat(aFile)
                aTime = stat_info.st_atime
                mTime = stat_info.st_mtime
                #os.utime(aFile, (315504000, 315504000))
                if fpath.find("Buff\\") > -1 or fpath.find("hit\\") > -1:
                    zf[0].write(aFile, bfile) #Buff, hit
                elif fpath.find("MiniGame\\") > -1:
                    zf[1].write(aFile, bfile) #H小遊戲
                elif fpath.find("Gloryhole\\") > -1:
                    zf[2].write(aFile, bfile) #壁尻
                elif fpath.find("NGEvent\\") > -1:
                    zf[3].write(aFile, bfile) #循環活動
                elif fpath.find("NG2D_nobg\\") > -1:
                    zf[4].write(aFile, bfile) #無背景立繪
                elif fpath.find("CharacterFX\\") > -1 or fpath.find("CharacterSpine\\") > -1 or fpath.find("CharacterBullet\\") > -1:
                    subStr = sfile[3:5]
                    if subStr.isdigit() and int(subStr) <= charZipNum - 1:
                        charZf[int(subStr) - 1].write(aFile, bfile)
                    else: #戰鬥小人相關
                        charZf[charZipNum - 1].write(aFile, bfile)
                elif fpath.find("NG2D\\") > -1 :
                    subStr = sfile[5:7]
                    if subStr.isdigit() and int(subStr) <= charZipNum - 1:
                        charZf[int(subStr) - 1].write(aFile, bfile)
                    else: #角色立繪
                        charZf[charZipNum - 1].write(aFile, bfile)
                elif fpath.find("HScene\\") > -1:
                    subStr = sfile[3:5]
                    if subStr.isdigit() and int(subStr) <= charZipNum - 1:
                        charZf[int(subStr) - 1].write(aFile, bfile)
                    else: #HCG
                        charZf[charZipNum - 1].write(aFile, bfile)
                elif fpath.find("NGUI\\") > -1:
                    if sfile.find("NGUI_53_") > - 1 or sfile.find("NGUI_79_") > - 1 or sfile.find("NGUI_80_") > - 1:
                        zf[5].write(aFile, bfile) #召喚spine
                    elif sfile.find("NGUI_61_") > - 1 or sfile.find("NGUI_62_") > - 1:
                        zf[6].write(aFile, bfile) #精靈島, 精靈召喚spine
                    else:
                        subStr = sfile[5:7]
                        subStr2 = sfile[5:8]
                        if subStr.isdigit() and subStr2.isdigit():
                            zf[8].write(aFile, bfile)
                        elif subStr.isdigit() and int(subStr) <= 90:
                            zf[7].write(aFile, bfile)
                        else:
                            zf[8].write(aFile, bfile)
                else:
                    zf[0].write(aFile, bfile)
                os.utime(aFile, (aTime, mTime))
        for num in range(0, zipNum):
            zf[num].close()
            addManifestData(path[num])
        for num in range(0, charZipNum):
            charZf[num].close()
            addManifestData(charPath[num])
#--------- UI
def FolderToUiZip(rootFolder):
    fulldir = os.path.join(Res_assets, rootFolder)
    if os.path.isdir(fulldir):
        zipNum = 3
        path = CreateZipPaths(rootFolder, zipNum)
        zf = CreateZipFiles(rootFolder, zipNum, path)
        os.chdir(fulldir)
        for root, folders, files in os.walk(fulldir):
            fpath = root.replace(Res_assets, '') #壓縮檔內的檔案路徑,加上與檔名相同的資料夾
            fpath = fpath and fpath + os.sep or ''
            for sfile in files:
                aFile = os.path.join(root, sfile)    #被壓縮的檔案路徑
                bfile = fpath + sfile
                stat_info = os.stat(aFile)
                aTime = stat_info.st_atime
                mTime = stat_info.st_mtime
                #os.utime(aFile, (315504000, 315504000))
                if fpath.find("AncientWeaponSystem") > -1:
                    zf[1].write(aFile, bfile) #專武
                elif fpath.find("Common") > -1:
                    zf[2].write(aFile, bfile) #相簿圖
                else:
                    zf[0].write(aFile, bfile)
                os.utime(aFile, (aTime, mTime))
        for num in range(0, zipNum):
            zf[num].close()
            addManifestData(path[num])
#--------- Video (單一檔案較大 獨立生成zip)
def FolderToVideoZip(rootFolder):
    fulldir = os.path.join(Res_assets, rootFolder)
    if os.path.isdir(fulldir):
        os.chdir(fulldir)
        for root, folders, files in os.walk(fulldir):
            fpath = root.replace(Res_assets, '') #壓縮檔內的檔案路徑,加上與檔名相同的資料夾
            fpath = fpath and fpath + os.sep or ''
            for sfile in files:
                fileName = sfile.split(".mp4")
                path = os.path.join(Res_ZipDone, "Video_" + fileName[0]) + '.zip'
                zf = zipfile.ZipFile(path, mode = 'w', compression = zipfile.ZIP_DEFLATED)
                aFile = os.path.join(root, sfile)    #被壓縮的檔案路徑
                bfile = fpath + sfile
                stat_info = os.stat(aFile)
                aTime = stat_info.st_atime
                mTime = stat_info.st_mtime
                #os.utime(aFile, (315504000, 315504000))
                zf.write(aFile, bfile)
                zf.close()
                addManifestData(path)
                os.utime(aFile, (aTime, mTime))

def FolderToZip(rootFolder):
    fulldir = os.path.join(Res_assets, rootFolder)
    if os.path.isdir(fulldir):
        zippath = os.path.join(Res_ZipDone, rootFolder + '.zip')
        zf = zipfile.ZipFile(zippath, mode = 'w', compression = zipfile.ZIP_DEFLATED)
        os.chdir(fulldir)
        fileidx = 1
        for root, folders, files in os.walk(fulldir):
            fpath = root.replace(Res_assets, '') #壓縮檔內的檔案路徑,加上與檔名相同的資料夾
            fpath = fpath and fpath + os.sep or ''
            for sfile in files:
                #if (os.path.getsize(zippath) >= zipsizelimit):
                #    zf.close()
                #    zippath = os.path.join(Res_ZipDone, rootFolder + '_' + str(fileidx) + '.zip')
                #    #print("zippath..... :"+rootFolder+'_'+str(fileidx)+'.zip')
                #    zf = zipfile.ZipFile(zippath, mode = 'w', compression = zipfile.ZIP_DEFLATED)
                #    fileidx = fileidx + 1
                aFile = os.path.join(root, sfile)    #被壓縮的檔案路徑
                bfile = fpath + sfile  
                stat_info = os.stat(aFile)
                aTime = stat_info.st_atime
                mTime = stat_info.st_mtime
                #os.utime(aFile, (315504000, 315504000))
                zf.write(aFile, bfile)
                os.utime(aFile, (aTime, mTime))
        zf.close()
        addManifestData(zippath)

def FolderToCopyFile(rootFolder):
    fulldir = os.path.join(Res_assets, rootFolder)
    if os.path.isdir(fulldir):
        os.chdir(fulldir)
        for root, folders, files in os.walk(fulldir):
            fpath = root.replace(Res_assets, '') #壓縮檔內的檔案路徑,加上與檔名相同的資料夾
            fpath = fpath and fpath + os.sep or ''
            if not os.path.exists(Res_ZipDone + fpath):
                os.mkdir(Res_ZipDone + fpath)
            for sfile in files:
                aFile = os.path.join(root, sfile)    #被壓縮的檔案路徑
                bfile = fpath + sfile
                bfile = Res_ZipDone + bfile
                #os.utime(aFile, (315504000, 315504000))
                shutil.copyfile(aFile, bfile)
                addManifestData(bfile)

def loadOldManifest():
    os.chdir(Res_ZipDone)
    outfile_name = 'project.manifest'
    with open(outfile_name, 'r') as file:
        oldManifestData = json.load(file)
    jsonex['assets'] = list()
    for key, value in oldManifestData.items():
        if isinstance(value, list):
            for inner_value in value:
                edict = { }
                edict['size'] = inner_value['size']
                edict['name'] = str(inner_value['name'])
                edict['md5'] =  str(inner_value['md5'])
                edict['time'] = inner_value['time']
                jsonex['assets'].append(edict)
        else:
            jsonex['time'] = value
    #outfile_name = 'projectNew.manifest'
    #with open(outfile_name, 'w') as file_object:
    #    json.dump(jsonex,file_object, indent = 4)

def initManifest():
    jsonex = { }
    jsonex['assets'] = list()

def addManifestData(fullpath):
    splitStr = fullpath.split(Res_ZipDone + os.sep)
    nameStr = splitStr[1].replace('\\', '/')
    #print('splitStr ' + splitStr[1])
    isHaveData = False
    global isChangeData
    md5 = getMd5(fullpath)
    if 'assets' in jsonex:
        for value in jsonex['assets']:
            if nameStr == str(value['name']) :
                isHaveData = True
                if md5 != str(value['md5']): #md5值不同 > 複寫資料
                    value['size'] = round(os.path.getsize(fullpath) * 0.001, 3)
                    value['md5'] = getMd5(fullpath)
                    value['time'] = savetime
                    print('Old Data %s = %.3f bytes md5 = %s '% (value['name'], value['size'], value['md5']))
                    isChangeData = True
                else:
                    print(u"%s ......檔案內容沒有改變"% (value['name']))
    else:
        jsonex['assets'] = list()
    if isHaveData == False:	# 沒有舊資料 > 新增
        edict = { }
        edict['size'] = round(os.path.getsize(fullpath) * 0.001, 3)
        edict['name'] = nameStr
        edict['md5'] =  md5
        edict['time'] = savetime
        print('New Data %s = %.3f bytes md5 = %s '% (edict['name'], edict['size'], edict['md5']))
        jsonex['assets'].append(edict)
        isChangeData = True

def outputManifest():
    filelist = os.listdir(Res_ZipDone)
    global isChangeData
    if isChangeData == True:
        jsonex['time'] = savetime
    os.chdir(Res_ZipDone)
    outfile_name = 'project.manifest'
    with open(outfile_name, 'w') as file_object:
        json.dump(jsonex,file_object, indent = 4) #轉換成json,順便轉成易閱讀模式

def initPath():
    global workpath
    workpath = os.getcwd()
    printdebug("Now WorkPath : " + workpath)

    global Res_assets
    Res_assets =  os.path.join(workpath, "assets")

    global Res_ZipDone
    Res_ZipDone = os.path.join(workpath, "hotUpdate")

    if not os.path.exists(Res_assets):
        os.mkdir(Res_assets)

    os.chdir(Res_assets)
    if not os.path.exists(Res_ZipDone):
        os.mkdir(Res_ZipDone)
    return True

if __name__ == '__main__':
    if initPath():
        global isChangeData
        isChangeData = False
        createAssetsBundle()
        outputManifest()
    print "All OK"