#coding=utf-8

import os
import shutil
import time,datetime
import getopt
import re
from FTPOperation import *
from fileinput import filename

print sys.getdefaultencoding()


printlog('sys.argv = ' + str(sys.argv))

File1 = 'E:\\GuaJiABD\\trunk\\Resource_Client\\platforms\\android_R2Game_en\\i18nFiles\\English\\Lang\\Language.lang'
File2 = 'E:\\GuaJiABD\\trunk\\Resource_Client\\platforms\\android_R2Game_en\\i18nFiles\\French\\Lang\\Language.lang'

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
        opts, args = getopt.getopt(sys.argv[1:], "m:n:h")
    except getopt.GetoptError as err:
        print str(err)
        usage()
        sys.exit(1)
    global File1,File2
    for op, value in opts:
        if op == "-m":
            File1 = value
        elif op == "-n":
            File2 = value
        elif op == "-h":
            usage()
            sys.exit()
        else:
            assert False, "unhandled option"
            usage()
            sys.exit(1)


def CMP_JSON_FILE():
    printlog('----------CMP_JSON_FILE-------')
    global File1,File2
    if os.path.isfile(File1) and os.path.isfile(File2):
        jsonFile1 = open(File1, "r")
        readData1 = jsonFile1.read()
        jsonFile1.close()
        content1 = json.loads(readData1)
        strings1 = content1["strings"]
        
        jsonFile2 = open(File2, "r")
        readData2 = jsonFile2.read()
        jsonFile2.close()
        content2 = json.loads(readData2)
        strings2 = content2["strings"]
        
        len1 = len(strings1)
        len2 = len(strings2)
        
        printlog('string1 size:' + str(len1))
        printlog('string2 size:' + str(len(strings2)))
        lenIndex = 0
        strings1_list = []
        for stringItem1 in strings1:
            printlog('strings1 for i = ' + str(lenIndex))
            key1 = stringItem1['k']
            strings1_list.append(key1)
            lenIndex += 1
        
        lenIndex = 0
        strings2_list = []
        for stringItem2 in strings2:
            printlog('strings2 for i = ' + str(lenIndex))
            key2 = stringItem2['k']
            strings2_list.append(key2)
            lenIndex += 1
            
        outPutDic={}
        outPutDic1 = {}
        outPutDic2 = {}
        outPutDic['dic1'] = outPutDic1
        outPutDic['dic2'] = outPutDic2
        outPutDic['File1'] = File1
        outPutDic['File2'] = File2
        
        outPut1 = list(set(strings1_list).difference(set(strings2_list)))
        outPutDic1['des'] = 'InFile1AndNotInFile2'
        outPutDic1['list'] = outPut1
        
        outPut2 = list(set(strings2_list).difference(set(strings1_list)))  
        outPutDic2['des'] = 'InFile2AndNotInFile1'
        outPutDic2['list'] = outPut2
        
        path1 = os.path.split(File1)[0] + '/outPut.txt'
        del_file(path1)
        f1 = file(path1,"w")
        f1.write(json.dumps(outPutDic, ensure_ascii=False, encoding="utf-8", indent = 4, sort_keys=True))
        f1.close()
    else:
        printlog('file not exsit ')
#---------------------------Define timestr------------------------------------ 
timestr = time.strftime('%Y-%m-%d_%H%M%S',time.localtime(time.time()))

#---------------------------init param------------------------------------



parseArgs()

printlog('File1 = ' + File1)
printlog('File2 = ' + File2)


#---------------------------init Operation param------------------------------------

#---------------------------run Operation------------------------------------
CMP_JSON_FILE()

printlog('--------------------------done!!!-------------------------')
