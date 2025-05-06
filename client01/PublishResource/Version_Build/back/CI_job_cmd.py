#coding=utf-8

import string

from utility import *

ci_username = 'admin'
ci_password = 'admin123456'
Head_cmdstr = 'java -jar '+ Native_SVN_Root_Path +'/Version_Build/jenkins-cli.jar -s http://10.0.1.161:8080/ build '
Auth_cmdstr = ' --username ' + ci_username + ' --password ' + ci_password

BuildIOS_cmdstr = string.Template(Head_cmdstr + 'gjabd_VersionBuildIOS -p arg_time=${time} -p arg_version=${version} -p arg_Configuration=${config} -p arg_platform="${platform}" ' + Auth_cmdstr)
BuildServer_cmdstr = string.Template(Head_cmdstr + 'gjabd_VersionBuildServer -p arg_time=${time} -p arg_version=${version}' + Auth_cmdstr)
BuildWin32_cmdstr = string.Template(Head_cmdstr + 'gjabd_VersionBuildWin32 -p arg_time=${time} -p arg_version=${version}' + Auth_cmdstr)
BuildAndroid_cmdstr = string.Template(Head_cmdstr + 'gjabd_VersionBuildAndroid -p arg_platform=${platform} -p arg_versionCode=${versionCode} -p arg_versionName=${versionName} -p arg_time=${time}' + Auth_cmdstr)
BuildAndroidWait_cmdstr = string.Template(Head_cmdstr + 'gjabd_VersionBuildAndroid -p arg_platform=${platform} -p arg_versionCode=${versionCode} -p arg_versionName=${versionName} -p arg_time=${time} -s' + Auth_cmdstr)

