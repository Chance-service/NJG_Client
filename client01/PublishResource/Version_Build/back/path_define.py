#coding=utf-8
import os

#---------------------------other define------------------------------------
Resource_Enc_FileName = 'Resource_enc'
Pre_Resource_Enc_FileName = 'Pre_Resource_enc'

Resource_Client_FileName = 'Resource_Client'
Pre_Resource_Client_FileName = 'Pre_Resource_Client'

Resource_Update_FileName = 'Resource_Update'
Pre_Resource_Update_FileName = 'Pre_Resource_Update'

#---------------------------svn path define------------------------------------
svn_Root = 'http://svn.mxhzw.com/svn/gjabd/Version'

Trunck_URL = svn_Root + '/trunk'
Branch_URL = svn_Root + '/branches'
Tag_URL = svn_Root + '/tags'

Code_Server_Trunck_URL = Trunck_URL + '/Code_Server'
Code_Client_Trunck_URL = Trunck_URL + '/Code_Client'
Code_Core_Trunck_URL = Trunck_URL + '/Code_Core'
Resource_Client_Trunk_URL = Trunck_URL + '/Resource_Client'
Code_iOS_Trunck_URL = Trunck_URL + '/Code_iOS'
Code_Android_Trunk_URL = Trunck_URL + '/Code_Android'
#Code_Android_GameAndroid_Trunk_URL = Trunck_URL + '/Code_Android/GameAndroid'
#Code_Android_Platforms_Trunk_URL = Trunck_URL + '/Code_Android/Platforms'
#Code_Android_sdklibs_URL = Trunck_URL + '/Code_Android/sdklibs'

#---------------------------win path define------------------------------------
Native_SVN_Root_Path = os.getenv('svn_root')
if not Native_SVN_Root_Path:
    Native_SVN_Root_Path = 'd:/gjabd_svn_root'

Code_Server_Native_Path = Native_SVN_Root_Path + '/Code_Server'
Code_Client_Native_Path = Native_SVN_Root_Path + '/Code_Client'
Code_Core_Native_Path = Native_SVN_Root_Path + '/Code_Core'
Code_iOS_Native_Path = Native_SVN_Root_Path + '/Code_iOS'
Resource_Client_Native_Path = Native_SVN_Root_Path + '/Resource_Client'
Pre_Resource_Native_Path = Native_SVN_Root_Path + '/Pre_Resource_Client'
Resource_Update_Native_Path = Native_SVN_Root_Path + '/' + Resource_Update_FileName
Pre_Update_Native_Path = Native_SVN_Root_Path + '/' + Pre_Resource_Update_FileName
Resource_Encrypt_Native_Path = Native_SVN_Root_Path + '/' + Resource_Enc_FileName


Version_Build_Native_Path = Native_SVN_Root_Path + '/Version_Build'

Code_Android_Native_Path = Native_SVN_Root_Path + '/Code_Android'
Code_Android_GameAndroid_Native_Path = Code_Android_Native_Path + '/GameAndroid'
Code_Android_GameLib_Native_Path = Code_Android_Native_Path + '/sdklibs/GameLib'
Code_Android_Platforms_Native_Path = Code_Android_Native_Path + '/Platforms'
Code_Android_sdklibs_Native_Path = Code_Android_Native_Path + '/sdklibs'
Code_Android_GameAndroid_Asset_Native_Path = Code_Android_GameAndroid_Native_Path+'/assets'

Android_ApkOut_Path = Code_Android_Native_Path +'/ApkOut'
Android_WorkspaceOut_Path = Code_Android_Native_Path +'/workspace_backup'
#---------------------------mac path define------------------------------------
#Native_SVN_Root_Mac_Path = '/Users/youai-ci/Desktop/svn_root'
Mac_Home = os.getenv('HOME')
if not Mac_Home:
    Mac_Home = '/Users/wzy'
Native_SVN_Root_Mac_Path = Mac_Home + '/Desktop/gjabd_svn_root'

Version_Build_Native_Path_Mac = Native_SVN_Root_Mac_Path + '/Version_Build'
Code_Client_Native_Path_Mac = Native_SVN_Root_Mac_Path + '/Code_Client'
Code_Core_Native_Path_Mac = Native_SVN_Root_Mac_Path + '/Code_Core'
Code_iOS_Native_Path_Mac = Native_SVN_Root_Mac_Path + '/Code_iOS'

Plist_Path = Native_SVN_Root_Mac_Path + '/Code_Client/xcode/Game/'
WS_Path = Native_SVN_Root_Mac_Path + '/Code_Client/xcode/workspace.xcworkspace'
GameProj_Path = Native_SVN_Root_Mac_Path + '/Code_Client/xcode/Game/Game.xcodeproj/project.pbxproj'
Build_Path = Native_SVN_Root_Mac_Path + '/Code_Client/build/'

Resource_Enc_Path_Mac = Native_SVN_Root_Mac_Path + '/Resource'
Resource_Native_Path_Mac = Native_SVN_Root_Mac_Path + '/Resource_enc'

