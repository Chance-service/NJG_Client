#coding=utf-8

import shutil
import re
from mod_pbxproj import XcodeProject

from path_define import *
from svn_cmd import *
from utility import *
from FTPOperation import *

def usage():
    print 'usage: args.py arg_time arg_version arg_configuration [arg_platform]...'
    print 'Valid arg_time: if "0" then calculate by self'
    print 'Valid arg_version: x.xx.xx (eg. 1.79.0)'
    print 'Valid arg_configuration: Release|Debug'
    print 'Valid arg_platform: eg:[("GameEfun","5"),("GameR2","3")]'


#----------------------------get command line arg----------------------
if len(sys.argv) < 5:
    print 'At leaset 4 arguments'
    usage()
    sys.exit(1)

#---------------------------Define timestr------------------------------------ 
timestr='0'
if sys.argv[1] == '0':
    timestr = time.strftime('%Y-%m-%d_%H%M%S',time.localtime(time.time()))
else:
    timestr = sys.argv[1]
printlog('timestr = ' + timestr)

#---------------------------Define version------------------------------------ 
version = sys.argv[2]
if not re.match('\d+\.\d+\.\d+$',version) and version.find("trunk") == -1:
        print 'error:invalid arg_version Version Error!'
        usage()
        sys.exit(1)
printlog('version = ' + version)

#---------------------------Define configuration------------------------------------ 
configuration = sys.argv[3]
if not (configuration == 'Release' or configuration == 'Debug'):
    print 'error:invalid arg_configuration'
    usage()
    sys.exit(1)
printlog('configuration = ' + configuration)

#---------------------------Define platforms------------------------------------ 
#platforms =[('GameGNetop','2.143.0')]
#platforms =[('GameEfun','5'),('GameR2','3'),('GameGNetop','2.143.0')]
platforms = eval(sys.argv[4])
printlog('platforms = ' + str(platforms))

#---------------------------Define path------------------------------------
Base_URL = ''
Code_Client_URL = ''
Code_Core_URL = ''
ftp_remote_dir_sv = ''

if version.find("trunk") != -1:
    version = version.split("_")[-1]
    printlog('current_version = ' + version)
    Base_URL = Trunck_URL
    f.login()
    remote_dir = '/VersionBuild/Gjabd/DailyBuild/'
    remotenames = f.get_remotedir_list(remote_dir)
    latestuploadpath = remotenames[-1]
    ftp_remote_dir_sv = remote_dir + latestuploadpath
else:
    small_version = version
    big_version = small_version.rpartition('.')[0]
    Base_URL = Branch_URL + '/' + big_version
    ftp_remote_dir_sv = ftp_remote_dir + big_version + '/' + small_version

Code_Client_URL = Base_URL + '/Code_Client'
Code_Core_URL = Base_URL + '/Code_Core'
Code_iOS_URL = Base_URL + '/Code_iOS'

def printPath():
    printlog('Base_URL = ' + Base_URL)
    printlog('Code_Client_URL = ' + Code_Client_URL)
    printlog('Code_Core_URL = ' + Code_Core_URL)
    printlog('ftp_remote_dir_sv = ' + ftp_remote_dir_sv)
printPath()

app_path = Build_Path + configuration + '-iphoneos/'
ipa_path = Build_Path + configuration + '-iphoneos/'
#---------------------------Define others------------------------------------ 
Products_Name = []

key = 'SignerIdentity'
value = 'Apple iPhone OS Application Signing'

#---------------------------Define option------------------------------------ 
def DownLoad_Code_Client():
    printlog('----------------------run step DownLoad_Code_Client,please waiting ----------------------')
    if os.path.isdir(Code_Client_Native_Path_Mac):
        run_cmd(CleanUp_cmdstr.substitute(PATH=Code_Client_Native_Path_Mac)) #先cleanup 以防异常中断svn锁住
        run_cmd(Revert_cmdstr.substitute(PATH=Code_Client_Native_Path_Mac)) #revert code_client 
        run_cmd(Switch_cmdstr.substitute(URL=Code_Client_URL,PATH=Code_Client_Native_Path_Mac))
    else:
		run_cmd(Checkout_cmdstr.substitute(URL=Code_Client_URL ,PATH=Code_Client_Native_Path_Mac))  

def DownLoad_Code_Core():
    printlog('----------------------run step DownLoad_Code_Core,please waiting ----------------------')
    if os.path.isdir(Code_Core_Native_Path_Mac):
        run_cmd(CleanUp_cmdstr.substitute(PATH=Code_Core_Native_Path_Mac))
        run_cmd(Revert_cmdstr.substitute(PATH=Code_Core_Native_Path_Mac)) #revert code_core
        run_cmd(Switch_cmdstr.substitute(URL=Code_Core_URL,PATH=Code_Core_Native_Path_Mac))
    else:
        run_cmd(Checkout_cmdstr.substitute(URL=Code_Core_URL ,PATH=Code_Core_Native_Path_Mac))
 
def DownLoad_Code_iOS():
    printlog('----------------------run step DownLoad_Code_iOS,please waiting ----------------------')
    if os.path.isdir(Code_iOS_Native_Path_Mac):
        run_cmd(CleanUp_cmdstr.substitute(PATH=Code_iOS_Native_Path_Mac))
        run_cmd(Revert_cmdstr.substitute(PATH=Code_iOS_Native_Path_Mac))
        run_cmd(Switch_cmdstr.substitute(URL=Code_iOS_URL,PATH=Code_iOS_Native_Path_Mac))
    else:
        run_cmd(Checkout_cmdstr.substitute(URL=Code_iOS_URL ,PATH=Code_iOS_Native_Path_Mac)) 

def DownLoad_Resource():
    printlog('----------------------run step DownLoad_Resource,please waiting ----------------------')
    FTP_Download_zip_for_Directory(Resource_Enc_Path_Mac, ftp_remote_dir_sv +  '/' + Resource_Enc_FileName + '.zip')
    del_files(Resource_Enc_Path_Mac,filter_names=['FZPWJ.ttf','FZPWJW--GB1-0.ttf','version_win32.cfg'])
    
def clean_Scheme(key):
    printlog('----------------------run step clean_Scheme:' + key + ',please waiting ----------------------')
    run_cmd(clean_cmdstr.substitute(WS_Path=WS_Path,Scheme_Name=key,Build_Config=configuration))

def build_Scheme(key):
    printlog('----------------------run step build_Scheme:' + key + ',please waiting ----------------------')
    #run_cmd(CleanUp_cmdstr.substitute(PATH=Resource_Native_Path_Mac))
    #run_cmd(Revert_cmdstr.substitute(PATH=Resource_Native_Path_Mac))
    #run_cmd(CopyFile_cmdstr_Mac.substitute(src_Path=Resource_Native_Path_Mac+'/platform/ios/Resource/*.*',des_Path=Resource_Native_Path_Mac))
    #run_cmd(CopyFile_cmdstr_Mac.substitute(src_Path=Resource_Native_Path_Mac + '/platform/ios/'+key+'/Build/*.*', des_Path=Code_Client_Native_Path+'/xcode/Game'))
    #run_cmd(CopyFile_cmdstr_Mac.substitute(src_Path=Resource_Native_Path_Mac+'/platform/ios/'+key+'/Resource/*.*',des_Path=Resource_Native_Path_Mac))
    #run_cmd(setPlist_cmdstr.substitute(key='Bundle versions string, short',value=version,File_Path=Plist_Path+key+'-info.plist'))
    #run_cmd(setPlist_cmdstr.substitute(key='Bundle version',value=version,File_Path=Plist_Path+key+'-info.plist'))
    run_cmd(build_cmdstr.substitute(WS_Path=WS_Path,Scheme_Name=key,Build_Config=configuration))

def archive_Scheme(key,value):
    printlog('----------------------run step archive_Scheme:' + key + ',please waiting ----------------------')
    run_cmd(setPlist_cmdstr.substitute(key='CFBundleShortVersionString',value=version,Plist_Path=Plist_Path+key+'-info.plist'))
    run_cmd(setPlist_cmdstr.substitute(key='CFBundleVersion',value=value,Plist_Path=Plist_Path+key+'-info.plist'))

    target_app_path = app_path + key + '.xcarchive'
    run_cmd(archive_cmdstr.substitute(WS_Path=WS_Path,Scheme_Name=key,Build_Config=configuration,ArchiveName=target_app_path))

def export_IPA(key):
    printlog('----------------------run step export_IPA:' + key + ',please waiting ----------------------')
    target_app_path = app_path + key + '.xcarchive'
    
    ipa_dev_name = key+'_dev_'+timestr+'_App.ipa'
    run_cmd(expoet_cmdstr.substitute(ArchiveName=target_app_path,IPA_Path=ipa_path + ipa_dev_name, ProvisioningProfile=dev_ProvisionProfile[key]))
    Products_Name.append(ipa_dev_name)
    if version != "trunk":
        ipa_dis_name = key+'_dis_'+timestr+'_App.ipa'
        run_cmd(expoet_cmdstr.substitute(ArchiveName=target_app_path,IPA_Path=ipa_path + ipa_dis_name, ProvisioningProfile=dis_ProvisionProfile[key]))
        Products_Name.append(ipa_dis_name)
        
def Package_App_jailbreak(key):
    printlog('----------------------run step Package_App_jailbreak:' + key + ',please waiting ----------------------')
    app_name = key + '.app'
    ipa_name = key+'_'+timestr+'_jailbreak.ipa'
    target_app_path = app_path + app_name
    target_ipa_path = ipa_path + ipa_name
    run_cmd(InsertPlist_cmdstr.substitute(Plist_Path=target_app_path+'/Info.plist'))
    run_cmd(packeage_cmdstr.substitute(APP_Path=target_app_path,IPA_Path=target_ipa_path))
    run_cmd(CopyFile_cmdstr_Mac.substitute(src_Path=Code_Client_Native_Path_Mac + '/xcode/Game/' + key + '_512.png', des_Path='iTunesArtwork'))
    run_cmd(InsertFile_cmdstr.substitute(IPA_Path=target_ipa_path,File_Path='iTunesArtwork'))
    Products_Name.append(ipa_name)

def Package_App_normal(key):
    printlog('----------------------run step Package_App_normal:' + key + ',please waiting ----------------------')
    app_name = key + '.app'
    ipa_name = key+'_'+timestr+'_App.ipa'
    target_app_path = app_path + app_name
    target_ipa_path = ipa_path + ipa_name
    run_cmd(packeage_cmdstr.substitute(APP_Path=target_app_path,IPA_Path=target_ipa_path))
    Products_Name.append(ipa_name)

def Package_App(key, opt='1'):
    printlog('----------------------run step Package_App,please waiting ----------------------')
    if opt == '0':
        Package_App_jailbreak(key)
    elif opt == '1':
        Package_App_normal(key)
    elif opt == '2':
        Package_App_normal(key)
        Package_App_jailbreak(key)
    else:
        print 'error:invalid arg_platform'
        usage()
        sys.exit(1)

def Clean_Build():
    printlog('----------------------run step Clean_Build,please waiting ----------------------')
    for platform in platforms:
        clean_Scheme(platform[0])
    run_cmd('rm ' + ipa_path + '*.ipa')

def Build_IPA():
    printlog('----------------------run step Build_IPA,please waiting ----------------------')
    for platform in platforms:
        ConfigResource(platform[0])
        archive_Scheme(platform[0],platform[1])
        export_IPA(platform[0])

def Commit_IPA():
    printlog('----------------------run step Commit_IPA,please waiting ----------------------')
    printlog('Products_Path = ')
    print Products_Name
    f.login()
    for name in Products_Name:
        f.upload_file(ipa_path+name, ftp_remote_dir_sv + '/' + name)

def ConfigProj():
    printlog('----------------------run step ConfigProj,please waiting ----------------------')
    project = XcodeProject.Load(GameProj_Path)
    
    printlog('remove_group_by_name:Classes')
    project.remove_group_by_name('Classes')
    
    printlog('remove_group_by_name:Protobuf')
    project.remove_group_by_name('Protobuf')

    Game_group = project.get_or_create_group('Game')

    printlog('add_folder:Classes')
    project.add_folder(Native_SVN_Root_Mac_Path + '/Code_Client/Game/Classes',parent=Game_group,recursive = True)
    
    printlog('add_folder:Protobuf')
    project.add_folder(Native_SVN_Root_Mac_Path + '/Code_Client/Game/Protobuf',parent=Game_group,recursive = True)
    
    if project.modified:
        printlog('save project...')
        project.saveFormat3_2()

def ConfigResource(key):
    printlog('----------------------run step ConfigResource,please waiting ----------------------')
    del_folder(Resource_Native_Path_Mac)
    run_cmd(Makedir_cmdstr.substitute(PATH=Resource_Native_Path_Mac))

    run_cmd(CopyFile_cmdstr_Mac.substitute(src_Path=Resource_Enc_Path_Mac+'/*',des_Path=Resource_Native_Path_Mac))
    run_cmd(CopyFile_cmdstr_Mac.substitute(src_Path=Resource_Enc_Path_Mac+'/platforms/ios_'+key+'/*', des_Path=Resource_Native_Path_Mac))
    
    #add ios modify cfg func --by lyj
    cfg_file_name=get_ios_cfg_name(key)
    modify_version_cfg(Resource_Native_Path_Mac + '/' + cfg_file_name, version)
    
    project = XcodeProject.Load(GameProj_Path)

    printlog('remove_group_by_name: Resource_enc')
    project.remove_group_by_name('Resource_enc')
    project.remove_group_by_name('Resources_enc')

    Game_group = project.get_or_create_group('Game')

    printlog('add_folder:Resource_Client')
    project.add_folder(Resource_Native_Path_Mac,parent=Game_group,excludes=['platforms'],recursive = False)

    if project.modified:
        printlog('save project...')
        project.saveFormat3_2()

run_cmd("security list-keychains")
run_cmd("security unlock-keychain -p com4loves /Users/ancientmountain/Library/Keychains/login.keychain")        
DownLoad_Code_Client()
DownLoad_Code_Core()
DownLoad_Code_iOS()
DownLoad_Resource()
ConfigProj()
Clean_Build()
Build_IPA()
Commit_IPA()

