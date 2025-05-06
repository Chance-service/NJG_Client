#coding=utf-8

import string

svn_username = 'wangzhengyu'
svn_password = 'wangzhengyu!@#'
Auth_cmdstr = ' --username ' + svn_username + ' --password ' + svn_password

dis_ProvisionProfile = {'GameR2':'R2_EZPZ_DIS_20150409_2','GameEfun':'disqmgj20141230','GameGNetop':'Acloth_20150516_gnetop_Dis','GameGNetopNormal':'GameGNetopNormal_dis_20150306','GameGNetopSpecial':'Acloth_20150516_gnetop_Dis'}
dev_ProvisionProfile = {'GameR2':'R2_EZPZ_DEV_20150409_2','GameEfun':'devqmgj20141230','GameGNetop':'Acloth_20150516_gnetop_Dev','GameGNetopNormal':'GameGNetopNormal_dev_20150306','GameGNetopSpecial':'Acloth_20150516_gnetop_Dev'}

CleanUp_cmdstr = string.Template('svn cleanup ${PATH}'+Auth_cmdstr)
Switch_cmdstr = string.Template('svn switch --ignore-ancestry ${URL} ${PATH}'+Auth_cmdstr)
Checkout_cmdstr = string.Template('svn checkout ${URL} ${PATH}'+Auth_cmdstr)
Commit_cmdstr = string.Template('svn commit -m "ci commit" ${PATH}'+Auth_cmdstr)
Add_cmdstr = string.Template('svn add ${PATH}'+Auth_cmdstr)
Import_cmdstr = string.Template('svn import -m "commit version Resource" --force ${PATH} ${URL}'+Auth_cmdstr)
Del_cmdstr = string.Template('svn delete -m "delete" ${URL}'+Auth_cmdstr)
Creatdir_cmdstr = string.Template('svn mkdir -m "creat dir" ${URL}'+Auth_cmdstr)
Copy_cmdstr = string.Template('svn copy -m "copy dir" ${SRC_URL} ${DST_URL}'+Auth_cmdstr)
Export_cmdstr = string.Template('svn export ${URL} ${PATH}'+Auth_cmdstr)
List_cmdstr_R = string.Template('svn ls ${URL} -R'+Auth_cmdstr)
List_cmdstr = string.Template('svn ls ${URL}'+Auth_cmdstr)
Revert_cmdstr = string.Template('svn revert --depth=infinity ${PATH}'+Auth_cmdstr)
Update_cmdstr = string.Template('svn update ${PATH} --no-auth-cache'+Auth_cmdstr)

CreatBranch_cmdstr = string.Template('svn copy --parents -m "creat branch" ${SRC_URL} ${DST_URL}'+Auth_cmdstr)
CreatBranchFolder_cmdstr = string.Template('svn mkdir -m "creat branch folder" ${URL}'+Auth_cmdstr)
DelBranch_cmdstr = string.Template('svn delete -m "delete branch" ${URL}'+Auth_cmdstr)
TagBranch_cmdstr = string.Template('svn copy --parents -m "tag branch" ${SRC_URL} ${DST_URL}'+Auth_cmdstr)
DelTag_cmdstr = string.Template('svn delete -m "delete tag" ${URL}'+Auth_cmdstr)
LockBranch_cmdstr = string.Template('svn lock -m "lock branch" ${URL} --force'+Auth_cmdstr)
UnLockBranch_cmdstr = string.Template('svn unlock -m "lock branch" ${URL} --force'+Auth_cmdstr)


CopyFile_cmdstr = string.Template('xcopy ${SRC} ${DST} /e /y')
DelFile_cmdstr = string.Template('del ${PATH}')
Makedir_cmdstr = string.Template('mkdir ${PATH}')


clean_cmdstr = string.Template('xcodebuild -workspace ${WS_Path} -scheme ${Scheme_Name} -configuration ${Build_Config} -destination generic/platform=iOS clean')
build_cmdstr = string.Template('xcodebuild -workspace ${WS_Path} -scheme ${Scheme_Name} -configuration ${Build_Config} -destination generic/platform=iOS build')
archive_cmdstr = string.Template('xcodebuild -workspace ${WS_Path} -scheme ${Scheme_Name} -configuration ${Build_Config} -destination generic/platform=iOS archive -archivePath ${ArchiveName}.xcarchive')
packeage_cmdstr = string.Template('xcrun --sdk iphoneos PackageApplication -v ${APP_Path} -o ${IPA_Path}')
expoet_cmdstr = string.Template('xcodebuild -exportArchive -exportFormat IPA -archivePath ${ArchiveName}.xcarchive -exportPath ${IPA_Path} -exportProvisioningProfile ${ProvisioningProfile}')
packeage_cmdstr = string.Template('xcrun --sdk iphoneos PackageApplication -v ${APP_Path} -o ${IPA_Path}')
InsertPlist_cmdstr = string.Template('/usr/libexec/PlistBuddy -c "Add SignerIdentity string Apple iPhone OS Application Signing" ${Plist_Path}')
setPlist_cmdstr = string.Template('/usr/libexec/PlistBuddy -c "Set ${key} ${value}" ${Plist_Path}')
InsertFile_cmdstr = string.Template('zip -m ${IPA_Path} ${File_Path}' )
RemoveFile_cmdstr = string.Template('zip -d ${IPA_Path} ${File_Path}' )
CopyFile_cmdstr_Mac = string.Template('cp -f -r ${src_Path} ${des_Path}' )