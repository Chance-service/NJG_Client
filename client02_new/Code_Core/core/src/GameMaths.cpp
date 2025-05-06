
#include "stdafx.h"
#include "cocos2d.h"
#include "GameMaths.h"
#include <stdarg.h>
#include <math.h>
#include <vector>
#include <time.h>
#include "../../extensions/cells/md5.h"
/*
utf-8多字节最高位字节组成部分    ：11110XXX 数据位为XXX 
utf-8多字节其他位字节固定组成部分：10XXXXXX 数据位为XXX
utf_HightByte_data:1-6字节 最高位字节的数据区
10XXXXXX	0x3F
110XXXXX	0x1F
1110XXXX	0x0F
11110XXX	0x07
111110XX	0x03
1111110X	0x01
*/
static const char utf_HightByte_data[6] = {
	0x3F, 0x1F, 0x0F, 0x07, 0x03, 0x01
};
/*
utf-8 第高位字节内 控制位中，1的个数 表示当前字符所占用的字节数量
11111101 ：此字符有5个字节
由于高位字节最大值为 11111101 utf8_Byte_Count[254-255] 填写默认值为1
*/
static const char utf8_Byte_Count[256] = {
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1,
	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
	2, 2, 2, 2, 2, 2, 2,
	3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 5,
	5, 5, 5, 6, 6, 1, 1
};
/*
thai音调符号的charcode，不可单独出现，
*/
/*static const unsigned short utf_thai_charcode_pitch[26] = {
	0x0E30, 0x0E31, 0x0E32, 0x0E33, 0x0E34, 0x0E35, 0x0E36, 0x0E37, 0x0E38, 0x0E39,
	0x0E3A,
	0x0E40, 0x0E41, 0x0E42, 0x0E43, 0x0E44, 0x0E45, 0x0E46, 0x0E47, 0x0E48, 0x0E49,
	0x0E4A, 0x0E4B, 0x0E4C, 0x0E4D, 0x0E4E
};*/
static const unsigned short utf_thai_charcode_pitch[] = {
	0x0E31, 0x0E34, 0x0E35, 0x0E36, 0x0E37, 0x0E38, 0x0E39,
0x0E3A,
0x0E47, 0x0E48, 0x0E49,
0x0E4A, 0x0E4B, 0x0E4C, 0x0E4D, 0x0E4E
};
/*
	判断是否为thai音调字符
	*/
#define CHECK_THAI_CHAR_CODE(code,result,index)\
for ((index) = 0; (index) < sizeof(utf_thai_charcode_pitch) / (sizeof(utf_thai_charcode_pitch[0])); (index++))\
{\
if (utf_thai_charcode_pitch[(index)] == (code))\
{\
	result = (code);\
	break; \
	}\
	result = -1;\
}\

unsigned short GameMaths::GetCRC16( 
	const unsigned char *p, /* points to chars to process */ 
	int n,/* how many chars to process */ 
	int start /*= 0 /* starting value */ )
{
	static unsigned int crcl6_table[16] = /* CRC-16s */
	{
		0x0000, 0xCC01, 0xD801, 0x1400,
		0xF001, 0x3C00, 0x2800, 0xE401,
		0xA001, 0X6C00, 0x7800, 0xB401,
		0x5000, 0x9C01, 0x8801, 0x4400
	};
	unsigned short int total; /* the CRC-16 value we compute */
	int r1;
	total = start;
	/* process each byte */
	while ( n-- > 0 )
	{
		/* do the lower four bits */
		r1 = crcl6_table[ total & 0xF ];
		total = ( total >> 4 ) & 0x0FFF;
		total = total ^ r1 ^ crcl6_table[ *p & 0xF ];
		/* do the upper four bits */
		r1 = crcl6_table[ total & 0xF ];
		total = ( total >> 4 ) & 0x0FFF;
		total = total ^ r1 ^ crcl6_table[ ( *p >> 4 ) & 0xF ];
		/* advance to next byte */
		p++;
	}
	return total;
}

void GameMaths::stringAutoReturn( const std::string& inString, std::string& outString, int width, int& lines )
{
	std::string::size_type start;
	outString = "";
	outString.reserve(inString.size()+64);

	width*=2;
	int count = 0;
	for(start = 0;start<inString.size();++start)
	{

		unsigned char cha = inString[start];
		unsigned char andres1 = cha&0x80;
		if(andres1==0)
		{
			int start2 = count;
			while(start2<=width && start+start2-count+1<inString.size() && (char)inString[start+start2-count]!=' ' && (char)inString[start+start2-count+1]!=' ' &&(((unsigned char)inString[start+start2-count+1])&0x80)==0)
			{
				start2++;
			}
			if(start2>width)
			{
				outString.push_back('\n');
				count = 0;
				lines++;
			}

			outString.push_back(cha);
			count++;
			
			if(count>=width)
			{

				outString.push_back('\n');
				count = 0;
				lines++;
			}		
		}
		else
		{
			unsigned char andres2 = cha&0x40;
			if(andres2!=0)
			{
				count+=2;
				if(count>=width)
				{
					outString.push_back('\n');
					count = 2;
					lines++;
				}
			}
			outString.push_back(cha);
		}
	}
}

std::string GameMaths::stringAutoReturnForLuaNewApi(const std::string& inString, int width, int& lines)
	{
		std::string::size_type start;
		std::string outString = "";
		outString.reserve(inString.size() + 64);
		int count = 0;
		for (start = 0; start < inString.size(); ++start)
		{
			unsigned char cha = inString[start];
			unsigned char andres1 = cha & 0x80;
			unsigned char andres2 = cha & 0x40;
			if (andres1 == 0x80)
			{
				outString.push_back(cha);
				if (andres2 == 0x40)
				{
					count++;
				}
				if (count > width)
				{
					outString.push_back('\n');
					count = 0;
					lines++;
				}
			}
			else if (andres1 == 0)
			{
				outString.push_back(cha);
				count++;
				if (count > width)
				{
					outString.push_back('\n');
					count = 0;
					lines++;
				}
			}
		}
		return outString;
}
std::string GameMaths::stringAutoReturnForLua( const std::string& inString,int width, int& lines )
{
	std::string::size_type start;
	std::string outString = "";
	outString.reserve(inString.size()+64);

	width*=2;
	int count = 0;
	for(start = 0;start<inString.size();++start)
	{

		unsigned char cha = inString[start];
		unsigned char andres1 = cha&0x80;
		if(andres1==0)
		{
			int start2 = count;
			while(start2<=width && start+start2-count+1<inString.size() && (char)inString[start+start2-count]!=' ' && (char)inString[start+start2-count+1]!=' ' &&(((unsigned char)inString[start+start2-count+1])&0x80)==0)
			{
				start2++;
			}
			
			if(start2>width)
			{
				outString.push_back('\n');
				count = 0;
				lines++;
			}

			count++;
			outString.push_back(cha);
			
			if(count>=width)
			{
				
				outString.push_back('\n');
				count = 0;
				lines++;
			}
		}
		else
		{
			unsigned char andres2 = cha&0x40;
			if(andres2!=0)
			{
				count+=2;
				if(count>width)
				{
					outString.push_back('\n');
					count = 2;
					lines++;
				}
			}
			outString.push_back(cha);
		}
	}
	return outString;
}

std::string GameMaths::stringCutWidthLen(const std::string& inString,int len)
{
	std::string::size_type start;
	std::string outString = "";
	outString.reserve(inString.size()+64);

	len*=2;
	int count = 0;
	for(start = 0;start<inString.size();++start)
	{

		unsigned char cha = inString[start];
		unsigned char andres1 = cha&0x80;
		if(andres1==0)
		{
			count++;
			outString.push_back(cha);
			if(count>=len)
			{
				return outString;
			}
		}
		else
		{
			unsigned char andres2 = cha&0x40;
			if(andres2!=0)
			{
				count+=2;
				if(count>len)
				{
					return outString;
				}
			}
			outString.push_back(cha);
		}
	}
	return outString;
}

void GameMaths::replaceStringWithBlank( const std::string& inString, std::string& outString )
{
	std::string::size_type start;
	outString = "";
	outString.reserve(inString.size());
	for(start = 0;start<inString.size();++start)
	{

		unsigned char cha = inString[start];
		unsigned char andres1 = cha&0x80;
		if(andres1==0)
		{
			outString.push_back(' ');
		}
		else
		{
			unsigned char andres2 = cha&0x40;
			if(andres2!=0)
			{
				outString.push_back(' ');
				outString.push_back(' ');
			}

		}

	}
}

std::string GameMaths::formatSecondsToTime(int seconds)
{
	if(seconds<0)
	{
		seconds = 0; 
	}
	std::string time = "";
	unsigned int hour = (unsigned int)floor((float)(seconds/3600));
	unsigned int minute = ((unsigned int)floor((float)(seconds/60)))%60;
	unsigned int second = seconds%60;
	char timeStr[32];
	sprintf(timeStr,"%02d:%02d:%02d",hour,minute,second);
	return (std::string)timeStr;
}

std::string GameMaths::formatTimeToDate(int seconds)
{
	time_t tick=(time_t)(seconds);
	struct tm *l=localtime(&tick);
	char buf[128];
	sprintf(buf,"%04d-%02d-%02d %02d:%02d:%02d",l->tm_year+1900,l->tm_mon+1,l->tm_mday,l->tm_hour,l->tm_min,l->tm_sec);
	std::string s(buf);
	return s;
}

std::string GameMaths::replaceStringWithStringList(const std::string& inString,std::list<std::string>* _list)
{
	std::string newStr=inString;
	std::string outStr="";
	std::list<std::string>::iterator it=_list->begin();
	for(int i=1;it!=_list->end();++it,++i)
	{
		char key[128];
		sprintf(key,"#v%d#",i);
		std::string::size_type index=newStr.find(key);
		if(index!=newStr.npos)
		{
			int splitEnd=index+3+(i>9?2:1);
			outStr+=newStr.substr(0,index);
			outStr+=*it;
			newStr=newStr.substr(splitEnd,newStr.length());
		}
	}
	outStr+=newStr;
	_list->clear();
	return outStr;
} 

std::string GameMaths::replaceStringOneForLua(const std::string& inString,const std::string& param)
{
	std::list<std::string> list;
	list.push_back(param);

	return GameMaths::replaceStringWithStringList(inString,&list);
}

std::string GameMaths::replaceStringTwoForLua(const std::string& inString,const std::string& param1,const std::string& param2)
{
	std::list<std::string> list;
	list.push_back(param1);
	list.push_back(param2);

	return GameMaths::replaceStringWithStringList(inString,&list);
}
void GameMaths::readStringToMap( const std::string& inString, std::map<int, std::string>& strMap )
{
	std::string::size_type start = 0;
	std::string::size_type lastEnd = 0;
	int id = 0;
	for(start = 0;start<inString.size();++start)
	{

		char cha = inString[start];
		unsigned char andres1 = cha&0x80;
		unsigned char andres2 = cha&0x40;
		if(andres1==0 || (andres1!=0 && andres2!=0))
		{
			if(start>lastEnd)
			{
				strMap.insert(std::make_pair(id,inString.substr(lastEnd,start - lastEnd)));
				lastEnd = start;
				id++;
			}
		}
	}
	if(lastEnd<inString.size())
	{
		std::string lastStr = inString.substr(lastEnd,inString.size() - lastEnd);
		strMap.insert(std::make_pair(id,lastStr));
	}
}
std::vector<std::string> GameMaths::tokenize(const std::string& src,std::string tok)
{  
	if( src.empty() || tok.empty() )
	{
		throw "tokenize: empty string\0";  
	}  
	std::vector<std::string> v;  
	unsigned int pre_index = 0, index = 0, len = 0;  
	while( (index = src.find_first_of(tok, pre_index))!=-1 )  
	{  
		if( (len = index-pre_index)!=0 )
		{
			v.push_back(src.substr(pre_index, len));
		}
		else
		{
			v.push_back(""); 
		}
		pre_index = index+1;  
	}   
	std::string endstr = src.substr(pre_index);  
	v.push_back( endstr.empty()?"":endstr);   
	return v;  
}

void GameMaths::replaceStringWithCharacter( const std::string& inString, char partten, char dest, std::string& outCharacter )
{
	size_t start = 0;
	size_t length = inString.length();
	outCharacter = inString;
	for(;start<length && start!=std::string::npos;++start)
	{
		if(outCharacter[start]==partten)
			outCharacter[start]=dest;
			//outCharacter.replace(start,start+1,1,dest);
	}
}

std::string  GameMaths::replaceStringWithCharacterAll(std::string&  str,const std::string& old_value,const std::string& new_value)     
{     
	while(true)   
	{     
		std::string::size_type   pos(0);     
		if((pos=str.find(old_value))!=std::string::npos)     
			str.replace(pos,old_value.length(),new_value);     
		else   
			break;     
	}    
	return str;
}  

void  GameMaths::replaceStringWithCharacterAllDistinct(std::string& str,const std::string& old_value,const std::string& new_value)     
{     
	for(std::string::size_type pos(0);pos!=std::string::npos;pos+=new_value.length())  
	{     
		if((pos=str.find(old_value,pos))!=std::string::npos)     
			str.replace(pos,old_value.length(),new_value);     
		else  
			break;     
	}     
}
/*
得到字符的 code 值
最高位根据 utf_HightByte_data计算数据区value
其他位 根据 二进制00111111 （0x3F）计算
*/
int getutf8StringCharCode(const char* str,int  nstar ,int nLen)
{
	unsigned int charcode = -1;
	char HightByteData = utf_HightByte_data[nLen-1];//最高位字节 数据区
	if (strlen(str) < nstar + nLen)
	{
		return -1;
	}
	charcode = (unsigned char)str[nstar] & HightByteData;
	for (int index = 1; index < nLen; index++)
	{
		/*
		除了最高位 数据格式不是 10XXXXXX格式的 都是错误的utf-8
		*/
		unsigned char cha = str[index + nstar];
		if ((cha & 0xC0) != 0x80)
		{
			charcode = -1;
			break;
		}
		charcode = charcode << 6;
		charcode = charcode | (cha & 0x3F);
	}
	return charcode;
}
/*
计算字符的个数，由于thai的每一个字符都占用三个字节
音调和 帽子是上下叠加的，所以有帽子和音调的组合字 按照一个长度计算。
*/
int GameMaths::calculateStringCharacters( const std::string& str )
{
	std::string::size_type start;
	int count = 0;
	for(start = 0;start<str.size();++start)
	{
		unsigned char cha = str[start];
		unsigned char andres1 = cha&0x80;
		if(andres1==0)
		{//ansic 单字节 不处理
			count++;
		}
		else
		{
			unsigned char andres2 = cha&0x40;
			if(andres2!=0)
			{
				int nLen = utf8_Byte_Count[cha];/*当前字符包含的字节数量*/
				int charcode = getutf8StringCharCode(str.c_str(), start, nLen);
				int index, result = -1;
				int sindex = sizeof(utf_thai_charcode_pitch) / (sizeof(utf_thai_charcode_pitch[0]));
				CHECK_THAI_CHAR_CODE(charcode, result,index)
				if (result == -1)/*当前符号不是音调*/
				{
					count++;
				}
				start += nLen - 1;/* 跳过一个当前字节*/
				
			}
		}

	}
	
	return count;
}

int GameMaths::calculateStringCharactersOfChina(const std::string& str)
{
	std::string::size_type start;
	
	int chinaNum = 0;
	int englishNum = 0;
	
	for(start = 0;start<str.size();++start)
	{
		unsigned char cha = str[start];
		unsigned char andres1 = cha&0x80;
		if(andres1==0)
		{
			englishNum++;
		}else
		{
			unsigned char andres2 = cha&0x40;
			if(andres2!=0)
			{
				chinaNum++;
			}
		}
	}
	
	int tmp = englishNum%2>0?englishNum/2+1:englishNum/2;
	return tmp+chinaNum;
}


std::string GameMaths::getStringSubCharacters( const std::string& inString, int offset, int length )
{
	std::string::size_type start;
	std::string outString = "";
	
	int count = 0;
	
	for(start = 0;start<inString.size();++start)
	{

		unsigned char cha = inString[start];
		
		unsigned char andres1 = cha&0x80;
		if(andres1==0)
		{
			count++;
		}
		else
		{
			unsigned char andres2 = cha&0x40;
			if(andres2!=0)
			{
				int nLen = utf8_Byte_Count[cha];/*当前字符包含的字节数量*/
				int charcode = getutf8StringCharCode(inString.c_str(), start, nLen);
				int index, result = -1;
				int sindex = sizeof(utf_thai_charcode_pitch) / (sizeof(utf_thai_charcode_pitch[0]));
				CHECK_THAI_CHAR_CODE(charcode, result, index)
				if (result == -1)/*当前符号不是音调*/
				{
					count++;
				}
			}
		}

		if(count>offset && count<= offset+length)
			outString.push_back(cha);
		else if(count>offset+length)
			break;

	}
	return outString;
}

bool GameMaths::hasSubString(const char * str_trgt, const char * str_src)
{
    
    while(*str_trgt){
        
        if(strncmp(str_trgt++, str_src,strlen(str_src)) == 0)
        {
            return true;
        }
    }
    return false;
}

bool GameMaths::isStringHasUTF8mb4( const std::string& inString )
{
	std::string::size_type start;
	int count = 1;

	for(start = 0;start<inString.size();++start)
	{
		unsigned char cha = inString[start];

		unsigned char andres1 = cha&0x80;
		if(andres1==0)
		{
			count=1;
		}
		else
		{
			unsigned char andres2 = cha&0x40;
			if(andres2!=0)
				count=1;
			else
				count++;
		}

		if(count==4)
			return true;

	}
	return false;
}
int GameMaths::ReverseAuto( int value )
{
	union BE_Check
	{
		int i;
		char c[4];
	}bec;
	bec.i=1;
	if (bec.c[0] = 1)
	{
		return Reverse<int>(value); /* little endian */
	}
	else
	{
		return value; /* big endian */		
	}
}

std::string GameMaths::getTimeByTimeZone(int seconds,int timeZone)
{
	time_t tick=(time_t)(seconds + timeZone * 3600);

	struct tm * timeinfo;
	timeinfo = gmtime ( &tick );
	char buf[128];
	strftime(buf,128,"%b %d %H:%M:%S",timeinfo);
	std::string timeStr = buf;
	return timeStr;
}
bool GameMaths::isPassWordAllow(std::string pwd)
{
	for (int i = 0; i < pwd.length(); i++)
	{
		unsigned char cha = pwd[i];
		if (!(cha >= '0'&& cha <= '9') && !(cha >= 'a'&& cha <= 'z') && !(cha >= 'A'&& cha <= 'Z'))
		{
			return false;
		}
	}
	return true;
}
std::string& GameMaths::trim(std::string &str)
{
	if (str.empty())
	{
		return str;
	}
	str.erase(0, str.find_first_not_of(" "));
	str.erase(str.find_last_not_of(" ") + 1);
	return str;
}
std::string GameMaths::calMd5(FILE* fp, char* buf, size_t buf_size, double* pnow /*= NULL*/, double* ptotal /*= NULL*/)
{
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
	if (ptotal)
	{
		fseek(fp, 0, SEEK_END);
		*ptotal = ftell(fp);
		fseek(fp, 0, SEEK_SET);
	}

	md5_state_t state;
	md5_byte_t digest[16];
	char hex_output[16 * 2 + 1];
	size_t file_size = 0;
	md5_init(&state);
	do
	{
		size_t readsize = fread(buf, 1, buf_size, fp);
		file_size += readsize;
		md5_append(&state, (const md5_byte_t *)buf, readsize);

		if (pnow)
		{
			*pnow = file_size;
		}
	} while (!feof(fp) && !ferror(fp));
	md5_finish(&state, digest);

	for (int di = 0; di < 16; ++di)
		sprintf(hex_output + di * 2, "%02x", digest[di]);

	hex_output[16 * 2] = 0;
	return std::string(hex_output);
#else
	return "0";
#endif
	
}