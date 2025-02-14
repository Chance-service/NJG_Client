#coding=utf-8

import re

from path_define import *
from svn_cmd import *
from utility import *

def usage():
    print 'usage: args.py arg_command arg_version'
    print 'Valid arg_command: creatbranch|tagbranch|buildbranch|delbranch|deltag|lockbranch|unlockbranch'
    print 'Valid arg_version: x.xx.xx (eg. 1.1)'

args = len(sys.argv)
if args < 3:
    print 'At leaset 2 arguments'
    usage()
    sys.exit(1)

command = sys.argv[1]
printlog('command = ' + command)
version = sys.argv[2]
printlog('version = ' + version)

#---------------------------command fun define------------------------------------
def CreatBranch():
    printlog('--------------------------run step CreatBranch,please waiting--------------------------')
    
    if not re.match('\d+\.\d+$',version):
        print 'error:invalid arg_version'
        usage()
        sys.exit(1)
    
    run_cmd(CreatBranch_cmdstr.substitute(SRC_URL = Trunck_URL, DST_URL = Branch_URL + '/' + version))
    
def DelBranch():
    printlog('--------------------------run step DelBranch,please waiting--------------------------')
    
    if not re.match('\d+\.\d+$',version):
        print 'error:invalid arg_version'
        usage()
        sys.exit(1)
    
    run_cmd(DelBranch_cmdstr.substitute(URL = Branch_URL + '/' + version))
    
def TagBranch():
    printlog('--------------------------run step TagBranch,please waiting--------------------------')
    
    if not re.match('\d+\.\d+\.\d+$',version):
        print 'error:invalid arg_version'
        usage()
        sys.exit(1)
        
    big_version = version.rpartition('.')[0] #"0.2"
    
    run_cmd(TagBranch_cmdstr.substitute(SRC_URL = Branch_URL + '/' + big_version, DST_URL = Tag_URL + '/' + version))

def DelTag():
    printlog('--------------------------run step DelTag,please waiting--------------------------')
    
    if not re.match('\d+\.\d+\.\d+\.\d+$',version):
        print 'error:invalid arg_version'
        usage()
        sys.exit(1)
        
    run_cmd(DelTag_cmdstr.substitute(URL=Tag_URL + '/' + version))

def lockURL(URL):
    pathlist = list_SVNURL(URL,"file",True)
    comb_str=''
    for path in pathlist:
        comb_str = comb_str + ' ' + URL + '/' + path
        if len(comb_str) > 7900:
            cmdstr = 'svn lock -m "lock branch"' + comb_str + ' --force' + Auth_cmdstr
            printlog(str(len(cmdstr)))
            run_cmd(cmdstr)
            comb_str=''
    if not comb_str == '':
        cmdstr = 'svn lock -m "lock branch"' + comb_str + ' --force' + Auth_cmdstr
        printlog(str(len(cmdstr)))
        run_cmd(cmdstr)
    
def LockBranch():
    printlog('--------------------------run step LockBranch,please waiting--------------------------')
    
    if not re.match('\d+\.\d+$',version):
        print 'error:invalid arg_version'
        usage()
        sys.exit(1)
        
    lockURL(Branch_URL + '/' + version)

def unlockURL(URL):
    pathlist = list_SVNURL(URL,"file",True)
    comb_str=''
    for path in pathlist:
        comb_str = comb_str + ' ' + URL + '/' + path
        if len(comb_str) > 7900:
            cmdstr = 'svn unlock' + comb_str + ' --force' + Auth_cmdstr
            printlog(str(len(cmdstr)))
            run_cmd(cmdstr)
            comb_str=''
    if not comb_str == '':
        cmdstr = 'svn unlock' + comb_str + ' --force' + Auth_cmdstr
        printlog(str(len(cmdstr)))
        run_cmd(cmdstr)
    
def unLockBranch():
    printlog('--------------------------run step unLockBranch,please waiting--------------------------')
    
    if not re.match('\d+\.\d+$',version):
        print 'error:invalid arg_version'
        usage()
        sys.exit(1)
        
    unlockURL(Branch_URL + '/' + version)

#---------------------------command interpreter------------------------------------
printlog('--------------------------run step command interpreter,please waiting--------------------------')
if command.lower() == 'creatbranch':
    CreatBranch()
elif command.lower() == 'tagbranch':
    TagBranch()
elif command.lower() == 'delbranch':
    DelBranch()
elif command.lower() == 'deltag':
    DelTag()
elif command.lower() == 'lockbranch':
    LockBranch()
elif command.lower() == 'unlockbranch':
    unLockBranch()
else:
    print 'error:invalid arg_command'
    usage()
    sys.exit(1)
