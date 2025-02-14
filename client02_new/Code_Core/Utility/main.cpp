// encryption_aes.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include <io.h>
#include <bitset>
#include <utility>
#include <string>
#include <fstream>
#include <iostream>
#include <list>
#include <vector>
#include <json/json.h>
#include <map>
#include <algorithm>
#include "zlib/zlib.h"
#include "AES.h"
#include "GameMaths.h"
#include "AsyncSocket.h"
#include "PacketManager.h"
//#include "GamePackets.h"
#include "pressureTest.h"
#include "rc4.h"
#include "GameEncryptKey.h"
using namespace std;
#define CC_BREAK_IF(cond) if(cond) break

unsigned char* _getFileData(const char* pszFileName, const char* pszMode, unsigned long* pSize)
{
	unsigned char* pBuffer = NULL;
	
	*pSize = 0;
	do 
	{
		// read the file from hardware
		FILE *fp = fopen(pszFileName, pszMode);
		CC_BREAK_IF(!fp);

		fseek(fp,0,SEEK_END);
		*pSize = ftell(fp);
		fseek(fp,0,SEEK_SET);
		pBuffer = new unsigned char[*pSize];
		*pSize = fread(pBuffer,sizeof(unsigned char), *pSize,fp);
		fclose(fp);
	} while (0);

	return pBuffer;
}

#define ARG_OPERATION (argv[1])
#define ARG_OUTFILE (argv[3])
#define ARG_INFILE (argv[2])
#define ARG_PARA (argv[4])
int checkFile(int argc, char* argv[])
{
	ifstream is(ARG_INFILE, ios::in | ios::binary);
	if(!is)
	{
		cerr << "InputFileNotFoundException" << endl;
		return 2;
	}

	is.close();
	return 0;
}
int encrypt(int argc, char* argv[])
{
	if(argc != 5)
		return 1;

	if(checkFile(argc,argv)!=0)
		return 2;
	
	if(strlen(ARG_PARA) != 16)
	{
		cerr << "Key must be 16 byte(128bit)" << endl;
		return 2;
	}

	AES aes;

	unsigned long size = 0;
	unsigned char* dataIn = _getFileData(ARG_INFILE,"rb",&size);
	unsigned char* dataOut = new unsigned char[size+2];
	dataOut[0]=0xef;
	dataOut[1]=0xfe;
	aes.Encrypt(dataIn,size,dataOut+2,(const unsigned char*)(ARG_PARA));

	FILE* fp;
	fp = fopen(ARG_OUTFILE,"wb");
	fwrite(dataOut,1, size+2,fp);
	fclose(fp); 
	delete[] dataOut; 
	delete[] dataIn;
	return 0;
}

int decrypt(int argc, char* argv[])
{

	if(argc != 5)
		return 1;
	if(checkFile(argc,argv)!=0)
		return 2;


	if(strlen(ARG_PARA)!=16)
	{
		cerr << "Key must be 16 byte(128bit)" << endl;
		return 2;
	}

	AES aes;
	unsigned long size = 0;
	unsigned char* dataIn = _getFileData(ARG_INFILE,"rb",&size);
	if(dataIn[0]!=0xef || dataIn[1]!=0xfe)
		printf("error file head!");
	size-=2;
	dataIn;
	unsigned char* data3 = new unsigned char[size];
	aes.Decrypt(dataIn+2,size,data3,(const unsigned char*)(ARG_PARA));

	FILE* fp;
	fp = fopen(ARG_OUTFILE,"wb");
	fwrite(data3,1,size,fp);
	fclose(fp);
	delete[] data3;
	delete[] dataIn;

}
class MyPacketHandler: public PacketHandler
{
public:
	virtual void onReceivePacket(const int opcode, const ::google::protobuf::Message* packet)
	{
		printf("received......opcode:%d\nMessage:\n\n",opcode);
		printf(packet->DebugString().c_str());
	}
	virtual void onSendPacketFailed(const int opcode)
	{
		printf("send packet failed! opcode:%d",opcode);
	}
	virtual void onConnectFailed(std::string ip, int port)
	{
		printf("connection failed! ip:%s port:%d",ip.c_str(),port);
	}
	virtual void onTimeout(const int opcode){};
	virtual void onPacketError(const int opcode){};
};

// void protoNet(int opcode)
// {
// 	std::string ip("127.0.0.1");
// 	int port = 25523;
// 	PacketManager::Get()->init(ip.c_str(),port);
// 	//PacketManager::Get()->init("223.203.216.6",25523);// 		
// 
// 	PacketHandler* handler = new MyPacketHandler;
// 
// 	PacketManager::Get()->registerPacketHandler(OPCODE_PLAYER_LOGINRET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_GET_USER_BASIC_INFORET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_GET_USER_DISCIPLE_INFORET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_GET_USER_EQUIP_INFORET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_MARKET_RECRUIT_DISCIPLERET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_UPDATE_CAREERRET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_GET_SHOP_ITEM_LISTRET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_GET_SHOP_PURCHASE_RETURN_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_SEND_FRIEND_MESSAGERET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_GET_USER_TOOL_INFORET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_GET_USER_SOUL_INFORET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_TRAIN_DISCIPLERET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_DEAL_TRAIN_STATUSRET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_USE_TOOLRET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_SWALLOW_DISCIPLERET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_GET_BOARDCAST_INFORET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_CHAT_SEND_MSGRET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_DISPOSE_USER_FRIENDS_INFORET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_DISPOSE_USER_SYSMSG_INFORET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_GET_USER_FRIENDS_INFORET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_GET_USER_SYSMSG_INFORET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_CHATRET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_CHANGE_SETTINGRET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_GET_CONTINUE_LOGINRET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_REWARD_CONTINUE_LOGINRET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_GET_USER_SKILL_INFORET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_UPGRADE_EQUIPRET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_UPGRADE_DISCIPLERET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_RECRUIT_DISCIPLERET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_ADD_POWERRET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_GET_ADVENTURE_POWERINFORET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_GET_ADVENTURE_BOUNDLESSHOLEINFORET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_ADD_ADVENTURE_BOUNDLESSHOLEINFORET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_UPGRADE_ROLERET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_FIGHTEND_BATTLERET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_GET_FIGHTEND_INFORET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_FIGHTEND_ADD_YEST_ATTR_INFORET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_FIGHTEND_ADD_TEMP_ATTR_INFORET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_GET_FIGHTEND_REWARD_INFORET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_GET_FIGHTEND_RANK_INFORET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_GET_USER_BATTLE_ARRAY_INFORET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_ADD_ADVENTURE_TEACHEXPRET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_GET_ADVENTURE_TEACHERINFORET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_HANDBOOK_INFORET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_GET_WORLD_BOSS_INFORET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_GET_TEAM_BUFF_INFORET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_UPGRADE_TEAM_BUFF_INFORET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_BUY_TOOLSRET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_RESET_CAREER_COUNTRET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_GET_ADVENTURE_INFORET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_ADDPOWER_CAREERRET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_CHANE_NAMERET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_ADVENTURE_CONTINUELOGIN_GET_INFORET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_ADVENTURE_CONTINUELOGIN_REWARDRET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_CDKEY_REWARDRET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_RECORDREADMSGTIMERET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_GUIDE_BUY_TOOLRET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_GUIDE_RECORDRET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_ADD_INVITEKEYRET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_USER_INVITESTATUSRET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_GET_INVITE_REWARDRET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_UPGRADE_STONEINFORET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_INLAID_STONEINFORET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_REMOVE_STONEINFORET_S,handler);
// 	PacketManager::Get()->registerPacketHandler(OPCODE_PUNCH_STONEINFORET_S,handler);
// 	int _opcode;
// 	printf("input:\ninstruction:\tn means the opcode to send\n\t\t-1 means disconnet and connect again\n\t\t-n mean send packet continuely\n\t\t-100 means exit\n");
// 	printf("command:");
// 	scanf("%d",&_opcode);
// 	::google::protobuf::Message* msg = PacketManager::Get()->_getDefaultMessage(_opcode);
// 	bool testClose = true;
// 	bool bExit = false;
// 	while(!bExit)
// 	{
// 		
// 		if(_opcode == -1)
// 		{
// 			PacketManager::Get()->disconnect();
// 			PacketManager::Get()->init(ip.c_str(),port);
// 			msg = 0;
// 		}
// 		else if(_opcode<-1)
// 		{
// 			int count = -_opcode;
// 			if(count>10)count = 10;
// 			::google::protobuf::Message* msgs[10] = {0};
// 			int opcodes[10] = {0};
// 			for(int i=0;i<count;++i)
// 			{
// 				printf("\nopcode:\n");
// 				scanf("%d",&opcodes[i]);
// 				msgs[i] = PacketManager::Get()->_getDefaultMessage(opcodes[i]);
// 			}
// 			
// 			for(int i=0;i<count;++i)
// 			{
// 				if(msgs[i] && opcodes[i]>0)
// 				{
// 					printf("send......\n%s",msgs[i]->DebugString().c_str());
// 					PacketManager::Get()->sendPakcet(opcodes[i],msgs[i]);
// 				}
// 			}
// 		}
// 		else if(_opcode == -100)
// 		{
// 			bExit = true;
// 		}
// 		else
// 		{
// 			msg = PacketManager::Get()->_getDefaultMessage(_opcode);
// 
// 			if(msg)
// 			{
// 				printf("send......\n%s",msg->DebugString().c_str());
// 				PacketManager::Get()->sendPakcet(_opcode,msg);
// 			}
// 		}
// 
// 		for(int i=0;i<50;++i)
// 		{
// 			PacketManager::Get()->update(0.1f);
// 			Sleep(100);
// 		}
// 
// 		printf("command:");
// 		scanf("%d",&_opcode);
// 		
// 	}
// 	PacketManager::Get()->removePacketHandler(handler);
// 	PacketManager::Get()->disconnect();
// 	
// };

struct FileInfo
{
	std::string name;
	int crc;
	int size;
};

void getFiles(const std::string& rootpath,const std::string& subpath, std::list<FileInfo* > & filelist )
{
	_finddata_t file;
	std::string findfiles = rootpath;
	findfiles.append("/");
	findfiles.append(subpath);
	findfiles.append("/*.*");
	long lf;
	if((lf = _findfirst(findfiles.c_str(), &file))==-1l)//_findfirst返回的是long型; long __cdecl _findfirst(const char *, struct _finddata_t *)
		cout<<"Path:" + findfiles + " not found\n";
	else
	{
		//cout<<"\nfile list:\n";
		while( _findnext( lf, &file ) == 0 )//int __cdecl _findnext(long, struct _finddata_t *);如果找到下个文件的名字成功的话就返回0,否则返回-1
		{
			//cout<<file.name;
			if (file.attrib&_A_SUBDIR)//只要包含dir属性。就视为文件夹,继续递归
			{
				file.attrib = 0x10;
			}
			switch (file.attrib)
			{
			case _A_SUBDIR:
				//cout<<" subdir";
				if(strcmp(file.name,"..")!=0 && strcmp(file.name,".svn")!=0)
				{
					std::string thesubpath = subpath+"/"+file.name;
					getFiles(rootpath,thesubpath,filelist);
				}
				break;
			case _A_NORMAL:
			case _A_RDONLY:
			case _A_HIDDEN:
			case _A_SYSTEM:
			default:
				{
					//cout<<" file";
					if (strcmp(file.name,".svn") == 0)
						continue;

					std::string thefile = subpath+"/";
					thefile.append(file.name);
					unsigned long size = 0;
					unsigned char* dataIn = _getFileData((rootpath+"/"+thefile).c_str(),"rb",&size);
					unsigned short crcvalue = GameMaths::GetCRC16(dataIn,size);
					FileInfo *fileinfo = new FileInfo;
					fileinfo->name = thefile;
					fileinfo->crc = crcvalue;
					fileinfo->size = size;
					filelist.push_back(fileinfo);
					delete[] dataIn;
					break;
				}
			}
			//cout<<endl;
		}
	}
	_findclose(lf);
}

void subFileList_allSame(std::list<FileInfo* >  &modifyList, const std::list<FileInfo* >& sublist,std::set<std::string >& filelistChanged)
{
	std::list<FileInfo* > listmod;
	modifyList.swap(listmod);
	std::list<FileInfo* >::iterator it = listmod.begin();
	for(;it!=listmod.end();++it)
	{
		if(filelistChanged.find((*it)->name) != filelistChanged.end())
		{
			modifyList.push_back(*it);
			continue;
		}
		bool foundIt = false;
		std::list<FileInfo* >::const_iterator its = sublist.begin();
		for(;its!=sublist.end();++its)
		{
			if((*its)->name == (*it)->name &&
				(*its)->crc == (*it)->crc &&
				(*its)->size == (*it)->size )
			{
				foundIt = true;
				break;
			}
		}
		if(!foundIt)
		{
			modifyList.push_back(*it);
		}
	}
}


void subFileList_sameName(std::list<FileInfo* >  &modifyList_ori, const std::list<FileInfo* >& sublist)
{
	std::list<FileInfo* > listmod;
	modifyList_ori.swap(listmod);
	std::list<FileInfo* >::iterator it = listmod.begin();
	for(;it!=listmod.end();++it)
	{
		bool foundIt = false;
		std::list<FileInfo* >::const_iterator its = sublist.begin();
		for(;its!=sublist.end();++its)
		{
			if((*its)->name == (*it)->name)
			{
				foundIt = true;
				break;
			}
		}
		if(!foundIt)
		{
			modifyList_ori.push_back(*it);
		}
	}
}

void _parseUpdateFile( const std::string& severfile ,std::list<FileInfo* >  &modifyList)
{
	Json::Value root;
	Json::Reader jreader;
	Json::Value data;
	unsigned long filesize;
	char* pBuffer = (char*)_getFileData(severfile.c_str(),"rt",&filesize);

	if(!pBuffer)
	{
		printf("FAILED to get Update file!!");
		return;
	}

	jreader.parse(pBuffer,data,false);
	if(	data["version"].empty() || 
		data["version"].asInt()!=1 ||
		data["severVersion"].empty() ||
		data["files"].empty() ||
		!data["files"].isArray())
	{
		printf("FAILED to get Update file!!");
		return;
	}
	{


		Json::Value files = data["files"];
		for(int i=0;i<files.size();++i)
		{
			if(	!files[i]["c"].empty() &&
				!files[i]["f"].empty() &&
				!files[i]["s"].empty())
			{
				FileInfo* fileatt = new FileInfo;
				fileatt->name = files[i]["f"].asString();
				fileatt->crc = files[i]["c"].asInt();
				fileatt->size = files[i]["s"].asInt();

				modifyList.push_back(fileatt);
			}
		}
	}
}
void createVersonFile(
	const std::string& versonfile, 
	const std::string& rootdir, 
	const std::string& fileExt = "", 
	const std::string& comparePath = "", 
	const std::string& _version = "", 
	const std::string& lastVersionFile = "")
{
	std::list<FileInfo* >  orilist;
	if(lastVersionFile!="")
		_parseUpdateFile(lastVersionFile,orilist);

	std::list<FileInfo* >  filelist;
	getFiles(rootdir,"",filelist);

	std::list<FileInfo* >  filelistCmp;
	if(comparePath!="")
	{
		getFiles(comparePath,"",filelistCmp);
		std::set<std::string > filelistChanged;
		subFileList_allSame(filelist,filelistCmp,filelistChanged);
	}

	subFileList_sameName(orilist,filelist);

	std::list<FileInfo* >::iterator itcpy = filelist.begin();
	for(;itcpy!=filelist.end();++itcpy)
	{
		orilist.push_back(*itcpy);
	}

	std::string version = _version;
	if(version == "")
	{
		char versonstr[512];
		printf("Please input the target verson:");
		scanf("%s",versonstr);
		version = versonstr;
	}

	Json::Value fileroot;
	fileroot["version"] = 1;
	fileroot["severVersion"] = version.c_str();
	Json::Value files;

	int iTotalByteSize = 0;

	std::list<FileInfo*>::iterator it = filelist.begin();
	for(;it!=filelist.end();++it)
	{
		std::string ext = fileExt;
		if(!fileExt.empty())
		{
			if(fileExt.find_first_of('.') != 0)
				ext = std::string(".")+fileExt;
			int extpos = (*it)->name.find_last_of('.');
			if((*it)->name=="version.cfg")
			{
				continue;
			}
			if((*it)->name=="/version.cfg")
			{
				continue;
			}

			if(extpos!=-1)
			{
				std::string oriExt = (*it)->name.substr(extpos,(*it)->name.length());
				transform(oriExt.begin(), oriExt.end(), oriExt.begin(), (int (*)(int))tolower);
				transform(ext.begin(), ext.end(), ext.begin(), (int (*)(int))tolower);
				if(ext == oriExt)
					continue;
				if(oriExt == ".dll")
					continue;
				if(oriExt == ".exe")
					continue;
				if(oriExt == ".bat")
					continue;
				if(oriExt == ".log")
					continue;
				if(oriExt == ".pdb")
					continue;
				if(oriExt == ".cfg")
				{
					//version_ios.cfg
					//version_android.cfg
					//version_360.cfg
					std::string strTmp = (*it)->name;
					transform(strTmp.begin(), strTmp.end(), strTmp.begin(), (int (*)(int))tolower);
					if (strTmp.find("version_") == 0 || strTmp.find("/version_") == 0)
					{
						continue;
					}
				}
				if(oriExt == ".lua")
					continue;
			}
		}
		Json::Value unitFile;
		unitFile["f"] = (*it)->name;
		unitFile["c"] = (*it)->crc;
		unitFile["s"] = (*it)->size;
		files.append(unitFile);

		iTotalByteSize += (*it)->size;
	}
	fileroot["files"] = files;
	fileroot["totalByteSize"] = iTotalByteSize;
	
	Json::StyledWriter writer;
	std::string outstr = writer.write(fileroot);
	FILE* fp;
	fp = fopen(versonfile.c_str(),"wb");
	fwrite(outstr.c_str(),1, outstr.size(),fp);
	fclose(fp); 
}

//////////////////////////////////////////////////////////////////////////
bool changeElToLuaAndSave(const std::string& filePath, const std::string& destPath)
{
	unsigned long filesize = 0;
	unsigned char* filebuf = _getFileData(filePath.c_str(), "rb", &filesize);

	if(filebuf)
	{
		unsigned long outBufferSize = 0;
		unsigned char* outBuffer = 0;
		if(decBuffer(filesize,filebuf,outBufferSize,outBuffer))
		{
			FILE* fp = fopen(destPath.c_str(), "wb"); //
			size_t return_size = fwrite(outBuffer, 1, outBufferSize, fp);  
			fclose(fp);

			delete[] outBuffer;
			delete[] filebuf;

			return true;
		}
		delete[] outBuffer;
		delete[] filebuf;
	}

	return false;
}

bool changeLuaToElAndSave(const std::string& filePath, const std::string& destPathDir, FileInfo* pInfo, std::string& destPath,std::string& newfilepath)
{

	unsigned long filesize = 0;
	unsigned char* filebuf = _getFileData(filePath.c_str(), "rb", &filesize);

	if(filebuf)
	{
		unsigned long outBufferSize = 0;
		unsigned char* outBuffer = 0;
		if(encBuffer(filesize,filebuf,outBufferSize,outBuffer))
		{
			std::string::size_type pos1 = filePath.find_last_of("/");
			std::string::size_type pos2 = filePath.find_last_of(".");

			newfilepath = destPathDir + 
				filePath.substr(pos1, pos2-pos1) + ".el";

			FILE* fp = fopen(newfilepath.c_str(), "wb"); //
			size_t return_size = fwrite(outBuffer, 1, outBufferSize, fp);  
			fclose(fp);
			

			{
				unsigned short crcvalue = GameMaths::GetCRC16(outBuffer,outBufferSize);
				
				char szTemp[512] = {0};
				strcpy(szTemp, pInfo->name.c_str());
				int iLen = pInfo->name.length();
				szTemp[iLen-1] = 0;
				szTemp[iLen-2] = 'l';
				szTemp[iLen-3] = 'e';
				
				pInfo->name = szTemp;
				pInfo->crc = crcvalue;
				pInfo->size = outBufferSize;
			}

			delete[] outBuffer;
			delete[] filebuf;

			destPath = newfilepath;
			return true;
		}
		delete[] outBuffer;
		delete[] filebuf;
	}
	

	return false;
}

bool decryptTxtAndSave(const std::string& filePath, const std::string& destPath)
{
	unsigned long size = 0;
	unsigned char* dataIn = _getFileData(filePath.c_str(), "rb", &size);

	if (dataIn)
	{
		{
			unsigned long outBufferSize = 0;
			unsigned char* outBuffer = 0;
			if(decBuffer(size-2,dataIn+2,outBufferSize,outBuffer))//
			{
				FILE* fp = fopen(destPath.c_str(), "wb"); //
				size_t return_size = fwrite(outBuffer, 1, outBufferSize, fp);  
				fclose(fp);

				delete[] outBuffer;
				delete[] dataIn;

				return true;
			}
			delete[] outBuffer;
			delete[] dataIn;
		}
	}

	return false;
}

bool encryptTxtAndSave(const std::string& filePath, const std::string& destPathDir, FileInfo* pInfo, std::string& destPath)
{
	
	unsigned long size = 0;
	unsigned char* dataIn = _getFileData(filePath.c_str(), "rb", &size);
	
	if (dataIn)
	{
		std::string::size_type pos1 = filePath.find_last_of("/");
		std::string::size_type pos2 = filePath.find_last_of(".");

		std::string newfilepath = destPathDir + 
			filePath.substr(pos1);
		
		{
			unsigned long outBufferSize = 0;
			unsigned char* outBuffer = 0;
			if(encBuffer(size,dataIn,outBufferSize,outBuffer))//先压缩再加密
			{
				FILE* fp = fopen(newfilepath.c_str(), "wb"); //

				if(!fp)
				{
					return false;
				}
				unsigned char head[2];
				head[0] = 0xef;
				head[1] = 0xfe;

				fwrite(head, 1, 2, fp);

				size_t return_size = fwrite(outBuffer, 1, outBufferSize, fp);  
				fclose(fp);

				{
					{
						unsigned char* szTemp = new unsigned char[outBufferSize+5];
						szTemp[0] = 0xef;
						szTemp[1] = 0xfe;
						szTemp[outBufferSize+2] = 0;
						szTemp[outBufferSize+3] = 0;
						szTemp[outBufferSize+4] = 0;
						memcpy(szTemp+2, outBuffer, outBufferSize);

						unsigned short crcvalue = GameMaths::GetCRC16(szTemp,outBufferSize+2);

						pInfo->crc = crcvalue;
						pInfo->size = outBufferSize+2;

						delete[] szTemp;
					}
				}

				delete[] outBuffer;
				delete[] dataIn;

				destPath = newfilepath;
				return true;
			}
			delete[] outBuffer;
			delete[] dataIn;
		}
	}

	return false;
}

/************************************************************************/
/* 加密图片文件                                                                     */
/************************************************************************/
bool encryptImageAndSave(std::string sourceFilePath,const std::string& destPathDir,std::string& destPath, FileInfo* pInfo)
{
	unsigned char* dataOut=NULL;
	unsigned long sourceBufferSize = 0;
	const int pngEncodeSize = 128;
	const int dataBufferSize = 1024*1024;
	unsigned char* codeBuffer = _getFileData(sourceFilePath.c_str(),"rb",&sourceBufferSize);
	unsigned long writeBufferSize = 0;
	AVRC4 rc4_key;
	memset(&rc4_key,0,sizeof(AVRC4));
	av_rc4_init(&rc4_key,gamekey,strlen((char*)gamekey)*8);
	int markSize = 3;
	dataOut = new unsigned char[sourceBufferSize+markSize];
	dataOut[0] = 0xef;
	dataOut[1] = 0xfe;
	dataOut[2] = 0x80;
	int bufferSize = 0;
	int encodeSize = 0x80;
	(sourceBufferSize > encodeSize) ? bufferSize = encodeSize : bufferSize = sourceBufferSize;
	av_rc4_crypt(&rc4_key,dataOut + markSize,codeBuffer,bufferSize);
	if (bufferSize < sourceBufferSize)
	{
		memcpy(dataOut + encodeSize + markSize,codeBuffer+encodeSize,sourceBufferSize - encodeSize);
	}					
	writeBufferSize = sourceBufferSize+markSize;
	std::cout << "Encrypt file : " << sourceFilePath << " done." << std::endl;

	std::string::size_type pos1 = sourceFilePath.find_last_of("/");
	std::string::size_type pos2 = sourceFilePath.find_last_of(".");

	std::string newfilepath = destPathDir + 
		sourceFilePath.substr(pos1);
	destPath=newfilepath;
	FILE *g_fpLog;
	g_fpLog = fopen(newfilepath.c_str(), "wb");
	assert(g_fpLog);
	fwrite(dataOut,1,writeBufferSize,g_fpLog);
	unsigned short crcvalue = GameMaths::GetCRC16(dataOut,writeBufferSize);
	pInfo->crc = crcvalue;
	pInfo->size = writeBufferSize;
	fclose(g_fpLog);
	delete[] dataOut;
	delete[] codeBuffer;
	
	return true;
}

/************************************************************************/
/* 解密图片文件                                                                     */
/************************************************************************/
bool decodeRC4TextureBuffer(const std::string& filePath, const std::string& destPath)
{
	unsigned long inSize = 0;
	unsigned char* inBuffer = _getFileData(filePath.c_str(), "rb", &inSize);

	if (inBuffer)
	{
		unsigned char* outBuffer = NULL;

		inBuffer=rc4TextureBuffer(inSize,inBuffer,&inSize);
		FILE* fp = fopen(destPath.c_str(), "wb"); //
		if(fp)
		{
			size_t return_size = fwrite(inBuffer, 1, inSize, fp);  
		}
		fclose(fp);
		return true;
	}

	return false;
}

/************************************************************************/
/* 加密plist和ccbi文件                                                                     */
/************************************************************************/
bool encryptRC4DocumentAndSave(std::string sourceFilePath,const std::string& destPathDir,std::string& destPath, FileInfo* pInfo)
{
	unsigned char* dataOut=NULL;
	unsigned long sourceBufferSize = 0;
	const int pngEncodeSize = 128;
	const int dataBufferSize = 1024*1024;
	unsigned char* codeBuffer = _getFileData(sourceFilePath.c_str(),"rb",&sourceBufferSize);
	unsigned long writeBufferSize = 0;
	AVRC4 rc4_key;
	memset(&rc4_key,0,sizeof(AVRC4));
	av_rc4_init(&rc4_key,gamekey,strlen((char*)gamekey)*8);
	int markSize = 3;
	unsigned long compressSize = (unsigned long)(sourceBufferSize * 1.5);
	unsigned char* compressData = new unsigned char[compressSize];
	int ret = compress(compressData,&compressSize,codeBuffer,sourceBufferSize);
	if (ret == Z_OK)
	{
		dataOut = new unsigned char[compressSize+3];
		dataOut[0] = 0xef;
		dataOut[1] = 0xfe;
		dataOut[2] = 0xff;
		av_rc4_crypt(&rc4_key,dataOut+3,compressData,compressSize);
		writeBufferSize = compressSize+3;
		
		delete[] compressData;
	}
	else
	{
		delete[] dataOut;
		delete[] codeBuffer;
		delete[] compressData;
		std::cout << "Encrypt file Failed : " << sourceFilePath << " done." << std::endl;
		return false;
	}
	

	std::string::size_type pos1 = sourceFilePath.find_last_of("/");
	std::string::size_type pos2 = sourceFilePath.find_last_of(".");

	std::string newfilepath = destPathDir + 
		sourceFilePath.substr(pos1);
	if(sourceFilePath.find(".lua")!=std::string::npos)
	{
		newfilepath = destPathDir + 
			sourceFilePath.substr(pos1, pos2-pos1) + ".el";
		char szTemp[512] = {0};
		strcpy(szTemp, pInfo->name.c_str());
		int iLen = pInfo->name.length();
		szTemp[iLen-1] = 0;
		szTemp[iLen-2] = 'l';
		szTemp[iLen-3] = 'e';
		pInfo->name = szTemp;
	}

	destPath=newfilepath;
	FILE *g_fpLog;
	g_fpLog = fopen(newfilepath.c_str(), "wb");
	assert(g_fpLog);
	fwrite(dataOut,1,writeBufferSize,g_fpLog);
	unsigned short crcvalue = GameMaths::GetCRC16(dataOut,writeBufferSize);
	pInfo->crc = crcvalue;
	pInfo->size = writeBufferSize;
	fclose(g_fpLog);
	delete[] dataOut;
	delete[] codeBuffer;
	std::cout << "Encrypt file : " << sourceFilePath << " done." << std::endl;
	return true;
}

/************************************************************************/
/* 解密plist和ccbi文件                                                  */
/************************************************************************/
bool decodeRC4DocumentBuffer(const std::string& filePath, const std::string& destPath)
{
	unsigned long inSize = 0;
	unsigned char* inBuffer = _getFileData(filePath.c_str(), "rb", &inSize);

	if (inBuffer)
	{
		unsigned char* outBuffer = NULL;
		inBuffer=rc4DocumentBuffer(inSize,inBuffer,&inSize);
		FILE* fp = fopen(destPath.c_str(), "wb"); //
		if(fp)
		{
			if(inBuffer)
			{
				size_t return_size = fwrite(inBuffer, 1, inSize, fp);  
			}
		}
		fclose(fp);
		return true;
	}

	return false;
}

void getpreviousChangedVersionFiles(const std::string& findfile, std::set<std::string > & filelist )
{
	unsigned long size = 0;
	std::string path = findfile;
	unsigned char* dataIn = _getFileData(path.c_str(), "rb", &size);
	
	if(!dataIn)
	{
		cout<<"Failed open file :" + findfile + "\n";
		return;
	}
	else
	{
		Json::Reader jreader;
		Json::Value data;
		jreader.parse((char*)dataIn,data,false);
		Json::Value& Files = data["files"];
		Json::Value::iterator itr = Files.begin();
		Json::Value::iterator itrend = Files.end();
		for (;itr!=itrend; itr++)
		{
			Json::Value ele = *itr;
			std::string fileName=ele["f"].asString();
			if(fileName.find(".el")!=std::string::npos)
			{
				std::string::size_type pos=fileName.find_last_of(".");
				filelist.insert(fileName.substr(0,pos)+".lua");
			}
			else
			{
				filelist.insert(fileName);
			}
		}
	}
}

std::string rightPath(const std::string& s)
{
	std::string str(s);
	while(true)
	{
		string::size_type pos(0);
		if( (pos=str.find("/")) != string::npos )
			str.replace(pos,1,"\\");
		else
			return str;
	}
	return str;
}

void run_cmd(const char* cmdstr)
{
	::system((std::string("echo  ") + std::string(cmdstr)).c_str());
	::system(cmdstr);
}

void copy_cmd(std::string newDir,std::string filename,std::string destPath,std::string updateVersionPath,std::string updateFileVersionDir)
{
	std::string strCmd = "COPY /Y \"" + 
		rightPath(newDir + filename) + "\" \"" + rightPath(destPath) + "\"";
	run_cmd(strCmd.c_str());

	if(updateFileVersionDir!="")
	{
		strCmd = "COPY /Y \"" + 
			rightPath(newDir + filename) + "\" \"" + rightPath(updateVersionPath) + "\"";
		run_cmd(strCmd.c_str());
	}
}

void createDiffVersionFile(
		const std::string& currentFileDir,	//参与比较的新资源目录
		const std::string& originalFileDir,	//参与比较的旧资源目录
		const std::string& difDir,	//比较结果，差异文件输出目录，lua文件转el，txt、cfg加密
		/*const */std::string& difListFile,	//在difDir输出这个文件，json格式差异列表
		const std::string& previousVersion="",	//前一个版本的update文件
		const std::string& verionStr="",//本次版本号
		const std::string& updateFileVersionDir="",
		const std::string& excludeFileExt = "",
		const std::string& includeFileExt = "",
		bool isNeedDecryptOut=false,
		const std::string& verionStrNew=""//本次版本号,先这样改，用来生成所有文件的AllFileCRC_
	)
{
	std::vector<std::string> echoFailedList;
	//
	static std::map<std::string,std::string> DirMap;
	std::list<FileInfo* >  filelist;
	getFiles(currentFileDir,"",filelist);
	
	//
	std::list<FileInfo* >  filelistCmp;
	getFiles(originalFileDir,"",filelistCmp);

	//拿到上一个版本的更新列表，供检测曾经有变更的文件
	std::string previousVersionUpdateFile = previousVersion;
	std::set<std::string >  filelistChanged;
	if(!previousVersionUpdateFile.empty())
		getpreviousChangedVersionFiles(previousVersionUpdateFile,filelistChanged);
	
	//
	subFileList_allSame(filelist,filelistCmp,filelistChanged);
	std::string currUpdateFileVersionDir="";
	if(verionStr!="")
	{
		//创建产出本次版本的文件夹
		currUpdateFileVersionDir=updateFileVersionDir+"/"+verionStr;
		if(updateFileVersionDir!="")
		{
			std::string strCmdcurrUpdateFile = "mkdir \"" + currUpdateFileVersionDir + "\"";
			run_cmd(strCmdcurrUpdateFile.c_str());
			DirMap.insert(std::make_pair(currUpdateFileVersionDir,currUpdateFileVersionDir));
		}
	}

	std::string outDirStr=difDir;
	if(updateFileVersionDir!="")
	{
		outDirStr=difDir+"/"+verionStr;
	}
	//
	std::string strCmd = "mkdir \"" + outDirStr + "\"";
	run_cmd(strCmd.c_str());
	DirMap.insert(std::make_pair(outDirStr,outDirStr));

	std::string decryptDir = outDirStr + "Decrypt";
	//modify by dylan at 20140515,这个目录不需要，平时就没用过
	
	if(isNeedDecryptOut)
	{
		std::string strCmd0 = "mkdir \"" + decryptDir + "\"";
		run_cmd(strCmd0.c_str());
		DirMap.insert(std::make_pair(decryptDir,decryptDir));
	}
	//
	//filelist now is new aded and modified files
	//
	Json::Value fileroot;
	fileroot["version"] = 1;
	fileroot["severVersion"] = verionStr;
	Json::Value files;

	int iTotalByteSize = 0;
	std::string strIncludeFileExt = includeFileExt;
	std::string strExcludeFileExt = excludeFileExt;

	//需要加密的文件
	std::vector<std::string> fileFilterVec;//暂未使用
	//不加密的文件夹
	std::vector<std::string> pathFilterVec;

	//load encrypt config 
	Json::Value root;
	Json::Reader jreader;
	Json::Value data;
	unsigned long filesize;
	char* pBuffer = (char*)_getFileData("Utility.cfg","rt",&filesize);

	if(!pBuffer)
	{
		std::string strCmd = "echo failed: FAILED to get Utility.cfg ConfigFile!!";
		run_cmd(strCmd.c_str());
		return ;
	}

	jreader.parse(pBuffer,data,false);

	if (!data["Encode"].empty())
	{
		Json::Value encodeData = data["Encode"];
		if (!encodeData["files"].empty())
		{
			Json::Value files = encodeData["files"];
			for(int i=0;i<files.size();++i)
			{
				if(	!files[i]["suffix"].empty() )
				{
					fileFilterVec.push_back(files[i]["suffix"].asString());
				}
			}
		}
		if (!encodeData["floder"].empty())
		{
			Json::Value files = encodeData["floder"];
			for(int i=0;i<files.size();++i)
			{
				if(	!files[i]["suffix"].empty() )
				{
					pathFilterVec.push_back(files[i]["suffix"].asString());
				}
			}
		}
	}


	std::list<FileInfo*>::iterator it = filelist.begin();
	for(;it!=filelist.end();++it)
	{
		if((*it)->name=="version.cfg")
		{
			continue;
		}
		if((*it)->name=="/version.cfg")
		{
			continue;
		}
		if((*it)->name=="empty.png")
		{
			std::string strCmd = "COPY /Y \"" + 
				rightPath(currentFileDir + (*it)->name) + "\" \"" + rightPath(outDirStr + (*it)->name) + "\"";
			run_cmd(strCmd.c_str());
			continue;
		}
		if((*it)->name=="/empty.png")
		{
			std::string strCmd = "COPY /Y \"" + 
				rightPath(currentFileDir + (*it)->name) + "\" \"" + rightPath(outDirStr + (*it)->name) + "\"";
			run_cmd(strCmd.c_str());
			continue;
		}
		if((*it)->name=="/.svn")
		{
			continue;
		}
		int extpos = (*it)->name.find_last_of('.');

		if(extpos!=-1)
		{
			std::string oriExt = (*it)->name.substr(extpos,(*it)->name.length());
			transform(oriExt.begin(), oriExt.end(), oriExt.begin(), (int (*)(int))tolower);

			transform(strIncludeFileExt.begin(), strIncludeFileExt.end(), strIncludeFileExt.begin(), (int (*)(int))tolower);
			transform(strExcludeFileExt.begin(), strExcludeFileExt.end(), strExcludeFileExt.begin(), (int (*)(int))tolower);
				
			if(strExcludeFileExt.find(oriExt) != std::string::npos)
				continue;

			if (!strIncludeFileExt.empty() && strIncludeFileExt.find(oriExt) == std::string::npos)
				continue;

			if(oriExt == ".dll")
				continue;
			if(oriExt == ".exe")
				continue;
			if(oriExt == ".bat")
				continue;
			if(oriExt == ".log")
				continue;
			if(oriExt == ".pdb")
				continue;
			if(oriExt == ".php")
				continue;
			if(oriExt == ".luaprj")
				continue;
			if(oriExt == ".cfg")
			{
				std::string strTmp = (*it)->name;
				transform(strTmp.begin(), strTmp.end(), strTmp.begin(), (int (*)(int))tolower);
				if (strTmp.find("version_") == 0 || strTmp.find("/version_") == 0)
				{
					//continue;
					std::string strCmd = "COPY /Y \"" + 
						rightPath(currentFileDir + (*it)->name) + "\" \"" + rightPath(outDirStr + (*it)->name) + "\"";
					run_cmd(strCmd.c_str());
					continue;
				}
			}

			std::string destPath = outDirStr + (*it)->name;
			std::string updateVersionPath = currUpdateFileVersionDir + (*it)->name;
			std::string destDir;
			std::string destUpdateVersionDir;
			std::string::size_type pos = destPath.find_last_of("/");

			if (pos != 0 && pos != std::string::npos)
			{
				destDir = destPath.substr(0, pos);
				if (DirMap.find(destDir) == DirMap.end())
				{
					std::string strCmd = "mkdir \"" + destDir + "\"";
					run_cmd(strCmd.c_str());
					DirMap.insert(std::make_pair(destDir,destDir));
					std::string::size_type updateVersionPos=updateVersionPath.find_last_of("/");
					destUpdateVersionDir=updateVersionPath.substr(0,updateVersionPos);

					if(updateFileVersionDir!="")
					{
						strCmd = "mkdir \"" + destUpdateVersionDir + "\"";
						run_cmd(strCmd.c_str());
						DirMap.insert(std::make_pair(destUpdateVersionDir,destUpdateVersionDir));
					}
				}
			}

			bool isNotEncrptFolder=false;
			std::vector<std::string>::iterator pathFliterIter = pathFilterVec.begin();
			for (; pathFliterIter != pathFilterVec.end(); ++pathFliterIter )
			{
				if(((*it)->name).find((*pathFliterIter+"/"))!=std::string::npos)
				{
					isNotEncrptFolder=true;
					break;
				}
			}

			if(!isNotEncrptFolder)
			{
				isNotEncrptFolder=true;
				std::vector<std::string>::iterator fileFilterIter=fileFilterVec.begin();
				for (; fileFilterIter != fileFilterVec.end(); ++fileFilterIter )
				{
					if(oriExt==(*fileFilterIter))
					{
						isNotEncrptFolder=false;
						break;
					}
				}
			}

			if(isNotEncrptFolder)
			{
				copy_cmd(currentFileDir,(*it)->name,destPath,updateVersionPath,currUpdateFileVersionDir);
			}
			else
			{
				if(isNeedDecryptOut)
				{
					if (oriExt == ".lua" || oriExt == ".txt" || oriExt == ".cfg" || oriExt ==".json" || oriExt==".plist" || oriExt==".png" || oriExt == ".ccbi")
					{
						std::string destPath11 = decryptDir + (*it)->name;
						std::string destDir11;
						std::string::size_type pos = destPath11.find_last_of("/");
						if (pos != 0 && pos != std::string::npos)
						{
							destDir11 = destPath11.substr(0, pos);
							if (DirMap.find(destDir11) == DirMap.end())
							{
								std::string strCmd = "mkdir \"" + destDir11 + "\"";
								run_cmd(strCmd.c_str());
								DirMap.insert(std::make_pair(destDir11,destDir11));
							}
						}
					}
				}
				//--begin
				if (oriExt == ".lua")
				{//处理lua文件，转el
					std::string destPath0;
					std::string tempName = (*it)->name;
					std::string newFilePath="";
					bool bret = changeLuaToElAndSave(currentFileDir + (*it)->name, destDir, (*it), destPath0,newFilePath);
					if (bret)
					{
						if(updateFileVersionDir!="")
						{
							std::string::size_type pos = updateVersionPath.find_last_of(".");

							strCmd = "COPY /Y \"" + 
								rightPath(newFilePath) + "\" \"" + rightPath(updateVersionPath.substr(0,pos)+".el") + "\"";
							run_cmd(strCmd.c_str());
						}


						if(isNeedDecryptOut) 
						{
							changeElToLuaAndSave(destPath0, decryptDir+tempName);
						}
					}
					else
					{
						std::string strCmd = "echo failed: \"" + currentFileDir + (*it)->name + "\"";
						run_cmd(strCmd.c_str());
						echoFailedList.push_back(strCmd);
						copy_cmd(currentFileDir,(*it)->name,destPath,updateVersionPath,currUpdateFileVersionDir);
					}
				}
				else if (oriExt == ".txt" || oriExt == ".cfg" || oriExt==".json" )
				{//处理txt文件，加密
					std::string destPath1;
					bool bret = encryptTxtAndSave(currentFileDir + (*it)->name, destDir, (*it), destPath1);
					if (bret)
					{
						if(updateFileVersionDir!="")
						{
							strCmd = "COPY /Y \"" + 
								rightPath(destPath1) + "\" \"" + rightPath(updateVersionPath) + "\"";
							run_cmd(strCmd.c_str());
						}
						if(isNeedDecryptOut) 
						{
							decryptTxtAndSave(destPath1, decryptDir+(*it)->name);
						}
					}
					else
					{
						std::string strCmd = "echo failed: \"" + currentFileDir + (*it)->name + "\"";
						run_cmd(strCmd.c_str());
						echoFailedList.push_back(strCmd);
						copy_cmd(currentFileDir,(*it)->name,destPath,updateVersionPath,currUpdateFileVersionDir);
					}
				}
				else if(oriExt==".png")
				{//处理图片资源加密
					std::string destPath1;
					bool bRet=encryptImageAndSave(currentFileDir + (*it)->name,destDir,destPath1,(*it));
					if(bRet)
					{
						if(updateFileVersionDir!="")
						{
							strCmd = "COPY /Y \"" + 
								rightPath(destPath1) + "\" \"" + rightPath(updateVersionPath) + "\"";
							run_cmd(strCmd.c_str());
						}
						if(isNeedDecryptOut) 
						{
							decodeRC4TextureBuffer(destPath1, decryptDir+(*it) ->name);
						}
					}
					else
					{
						std::string strCmd = "echo failed: \"" + currentFileDir + (*it)->name + "\"";
						run_cmd(strCmd.c_str());
						echoFailedList.push_back(strCmd);
						//run_cmd("pause");
						copy_cmd(currentFileDir,(*it)->name,destPath,updateVersionPath,currUpdateFileVersionDir);
					}
				}
				else if(oriExt==".ccbi" || oriExt==".plist")
				{//处理ccbi文件加密
					std::string destPath1;
					std::string tempName=(*it) ->name;
					bool bRet=encryptRC4DocumentAndSave(currentFileDir + (*it)->name,destDir,destPath1,(*it));
					if(bRet)
					{
						if(updateFileVersionDir!="")
						{
							strCmd = "COPY /Y \"" + 
								rightPath(destPath1) + "\" \"" + rightPath(updateVersionPath) + "\"";
							run_cmd(strCmd.c_str());
						}
						if(isNeedDecryptOut) 
						{
							decodeRC4DocumentBuffer(destPath1, decryptDir+tempName);
						}
					}
					else
					{
						std::string strCmd = "echo failed: \"" + currentFileDir + (*it)->name + "\"";
						run_cmd(strCmd.c_str());
						echoFailedList.push_back(strCmd);

						copy_cmd(currentFileDir,(*it)->name,destPath,updateVersionPath,currUpdateFileVersionDir);
					}
				}
				else
				{//only copy
					copy_cmd(currentFileDir,(*it)->name,destPath,updateVersionPath,currUpdateFileVersionDir);
				}
				//--end
			}

		}

		Json::Value unitFile;
		unitFile["f"] = (*it)->name;
		unitFile["c"] = (*it)->crc;
		unitFile["s"] = (*it)->size;
		files.append(unitFile);

		iTotalByteSize += (*it)->size;
	}

	fileroot["files"] = files;
	fileroot["totalByteSize"] = iTotalByteSize;
	
	Json::StyledWriter writer;
	std::string outstr = writer.write(fileroot);

// 	if (difListFile.find(":") == std::string::npos && 
// 		difListFile.find(".") != 0)
// 	{
// 		difListFile = difDir + "\\" + difListFile;
// 	}
	if (verionStrNew != "")
	{
		std::string smallVersion = verionStrNew.substr(verionStrNew.find_last_of(".")+1,verionStrNew.length());
		char outCfg[32];
		sprintf_s(outCfg, "AllFileCRC_%s.cfg", smallVersion.c_str());
		std::string strCmd1 = "echo AllFileCRC_: \"" +smallVersion;
		run_cmd(strCmd1.c_str());
		std::string outAllFileCRC = outDirStr+"/../Resource_Update/"+outCfg;
		std::string strCmd = "mkdir \"" + outDirStr+"/../Resource_Update/" + "\"";
		run_cmd(strCmd.c_str());
		FILE* fpCrc;
		fpCrc = fopen(outAllFileCRC.c_str(),"wb");
		if (fpCrc)
		{
			fwrite(outstr.c_str(),1, outstr.size(),fpCrc);
			fclose(fpCrc);
			strCmd1 = "echo AllFileCRC_: \"" +smallVersion + "save done";
			run_cmd(strCmd1.c_str());
		}
	}
	
	std::string outUpdateFileName=outDirStr+"/"+difListFile;
	FILE* fp;
	fp = fopen(outUpdateFileName.c_str(),"wb");
	if(fp)
	{
		fwrite(outstr.c_str(),1, outstr.size(),fp);
		fclose(fp);

		if(updateFileVersionDir!="")
		{
			//输出本次加密版本的列表文件
			std::string strCmd = "COPY /Y \"" + 
				rightPath(outUpdateFileName) + "\" \"" + rightPath(currUpdateFileVersionDir+"/"+difListFile) + "\"";
			run_cmd(strCmd.c_str());
		}
	}
	else
	{
		std::string strCmd = "echo failed: \"" +difListFile+ "\"";
		run_cmd(strCmd.c_str());
	}

	for (int i = 0; i < echoFailedList.size(); ++i)
	{
		run_cmd(echoFailedList.at(i).c_str());
	}

	//run_cmd("pause");
}

int main(int argc, char* argv[])
{
	

	const string USAGE =	"Usage:	Utility [-OPERATION]\n" \
							"	-E:	(Encrypt): Utility -E sourcefile destinationfile key\n" \
							"	-D:	(Decrypt): Utility -D sourcefile destinationfile key\n" \
							"	-C:	(CRC validate): Utility -C checkfile\n" \
							"	-N:	(Network test): Utility -N opcode" \
							"	-V:	(Verson file creation): Utility -V rootdir versonfile excludeFileExtension compareDir version"; \
							"	-P:	(Pressure test): Utility -P type(0:Login 1:PlayerSimulate 2:MassivePlayers"; 
	if(argc>=2 &&(strcmp(ARG_OPERATION, "-P") == 0 || strcmp(ARG_OPERATION, "-p") == 0))
	{
// 		if(strcmp(ARG_INFILE,"0")==0)
// 			pressureTest::Get()->testLogin();
// 		if(strcmp(ARG_INFILE,"1")==0)
// 			pressureTest::Get()->testPlay();
// 		if(strcmp(ARG_INFILE,"2")==0)
// 			pressureTest::Get()->testAmount();
	}
	else if(argc>=3 &&(strcmp(ARG_OPERATION, "-V") == 0 || strcmp(ARG_OPERATION, "-v") == 0))
	{
		if(argc == 5)
			createVersonFile(ARG_OUTFILE,ARG_INFILE);
		else if(argc == 6)
			createVersonFile(ARG_OUTFILE,ARG_INFILE,ARG_PARA);
		else if(argc == 7)
			createVersonFile(ARG_OUTFILE,ARG_INFILE,ARG_PARA,argv[5],argv[6]);
		else
			createVersonFile(ARG_OUTFILE,ARG_INFILE,ARG_PARA,argv[5],argv[6],argv[7]);
	}
	else if(argc>=3 &&(strcmp(ARG_OPERATION, "-VE") == 0 || strcmp(ARG_OPERATION, "-ve") == 0))
	{
		std::string destDiffFile = argv[5];
		std::string includeFileExt = "";
		std::string excludeFileExt = ".el";
		std::string version = "";
		std::string previousUpdateFile="";
		std::string updateFileVersionDir="";
		bool isNeedDecryptOut=false;
		if (argc >= 7)
			previousUpdateFile = argv[6];
		if (argc >= 8)
			version = argv[7];
		if(argc >=9)
			updateFileVersionDir=argv[8];
		if (argc >= 10)
			isNeedDecryptOut=true;
		if (argc >= 11)
			excludeFileExt = argv[10];
		if (argc >= 12)
			includeFileExt = argv[11];
		createDiffVersionFile(argv[2],argv[3],argv[4],destDiffFile,previousUpdateFile,version,updateFileVersionDir,excludeFileExt,includeFileExt,isNeedDecryptOut);
		return 0;
	}
	else if(argc>=3 &&(strcmp(ARG_OPERATION, "-VEN") == 0 || strcmp(ARG_OPERATION, "-ven") == 0))
	{
		std::string destDiffFile = "update.cfg";
		std::string includeFileExt = "";
		std::string excludeFileExt = ".el";
		std::string version = "";
		std::string previousUpdateFile="";
		std::string updateFileVersionDir="";
		bool isNeedDecryptOut=false;
		std::string versionNew = argv[4];
		createDiffVersionFile(argv[2],"../none",argv[3],destDiffFile,previousUpdateFile,version,updateFileVersionDir,excludeFileExt,includeFileExt,isNeedDecryptOut,versionNew);
		return 0;
	}
// 	if(argc>=2 &&(strcmp(ARG_OPERATION, "-N") == 0 || strcmp(ARG_OPERATION, "-n") == 0))
// 	{
// 		_gamePacketsCreatePackets();
// 		//if(ARG_INFILE)
// 		{
// 			//int opcode;
// 			//sscanf(ARG_INFILE,"%d",&opcode);
// 			protoNet(0);
// 			return 0;
// 		}
// 	}

	if(argc>=3 &&(strcmp(ARG_OPERATION, "-C") == 0 || strcmp(ARG_OPERATION, "-c") == 0))
	{
		if(checkFile(argc,argv)!=0)
			return 2;
		unsigned long size = 0;
		unsigned char* dataIn = _getFileData(ARG_INFILE,"rb",&size);
		unsigned short crcvalue = GameMaths::GetCRC16(dataIn,size);
		printf("CRC:%d",crcvalue);
		return crcvalue;
	}
	

	if(argc>=5 &&(strcmp(ARG_OPERATION, "-E") == 0 || strcmp(ARG_OPERATION, "-e") == 0))
	{
		if(encrypt(argc,argv) !=0)
		{
			cout << USAGE << endl;
			return 1;
		}
	}

	if(argc>=5 && (strcmp(ARG_OPERATION, "-D") == 0 || strcmp(ARG_OPERATION, "-d") == 0))
	{
		if(decrypt(argc,argv) !=0)
		{
			cout << USAGE << endl;
			return 1;
		}
	}

	cout << USAGE << endl;
	return 0;
}

