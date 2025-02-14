#coding=utf-8

import string
import os
import sys

def printlog(*args):
    sys.stdout.write(" ".join(args))
    sys.stdout.write("\n")
    sys.stdout.flush()
    
def run_cmd(cmdstr):
    printlog(cmdstr.split(' --username')[0])
    os.system(cmdstr)

svn_username = 'wangzhengyu'
svn_password = 'wangzhengyu!@#'
Auth_cmdstr = ' --username ' + svn_username + ' --password ' + svn_password

CleanUp_cmdstr = string.Template('svn cleanup ${PATH}'+Auth_cmdstr)
Revert_cmdstr = string.Template('svn revert --depth=infinity ${PATH}'+Auth_cmdstr)
Update_cmdstr = string.Template('svn update ${PATH} --no-auth-cache'+Auth_cmdstr)

Version_Build_Native_Path = os.getenv('svn_root') + '/Version_Build'

run_cmd(CleanUp_cmdstr.substitute(PATH=Version_Build_Native_Path))
run_cmd(Revert_cmdstr.substitute(PATH=Version_Build_Native_Path))
run_cmd(Update_cmdstr.substitute(PATH=Version_Build_Native_Path))
