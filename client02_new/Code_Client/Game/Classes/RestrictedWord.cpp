
#include "stdafx.h"

#include "RestrictedWord.h"
#include "TableReader.h"
#include "GameMaths.h"
#include "SeverConsts.h"

RestrictedWord::RestrictedWord(void)
{
//	if (SeverConsts::Get()->IsJgg()){
//		init("restrict_jgg.txt");
//	}
//	else{
		init("restrict.txt");
//	}
}

RestrictedWord::~RestrictedWord(void)
{
}

class ResWordReader : public TableReader
{
	std::list<std::string>& limitlist;
public:
	ResWordReader(std::list<std::string>& _list):limitlist(_list){}

	virtual void readline(std::stringstream& _stream) 
	{
		int id;
		std::string word;
		_stream
			>>id
			>>word;
		if(id<10000 && !word.empty())
			limitlist.push_back(word);
	}

};
void RestrictedWord::init( const std::string& filename )
{
	ResWordReader reader(mRestrictList);
	reader.parse(filename,1);
}

bool RestrictedWord::isChatWorldStringOK( const std::string& str )
{
	std::list<std::string>::iterator it = mRestrictList.begin();
	for(; it != mRestrictList.end(); ++it)
	{
		std::map<int, std::string> strMap;
		GameMaths::readStringToMap(*it,strMap);
		const char* start = str.c_str();

		int i=0;
		while(i+it->length()<=str.length())
		{
			if(strncmp(str.c_str()+i,it->c_str(),it->length())==0)
			{
				return false;
			}
			else
				i++;
		}

	}
	//
	return true;//no modify
}

bool RestrictedWord::isStringOK( const std::string& str )
{
	//不能不能用英文语句，空格、逗号
	const char* strChar = str.c_str();
	for(int i=0;i<str.length();++i)
	{
		unsigned char cha = (*strChar);
		if((cha&0x80) == 0)
		{
			bool isOK = false;
			if(cha>='0' && cha<='9')//number
				isOK = true;
			if(cha>='a' && cha<='z')//number
				isOK = true;
			if(cha>='A' && cha<='Z')//
				isOK = true;
			if(cha=='.')//dot
				isOK = true;

			if(isOK == false)
				return false;
		}
		strChar++;
	}
	
	std::list<std::string>::iterator it = mRestrictList.begin();
	for(; it != mRestrictList.end(); ++it)
	{
		std::map<int, std::string> strMap;
		GameMaths::readStringToMap(*it,strMap);
		const char* start = str.c_str();

		int i=0;
		while(i+it->length()<=str.length())
		{
			if(strncmp(str.c_str()+i,it->c_str(),it->length())==0)
			{
				return false;
			}
			else
				i++;
		}

	}
	//
	return true;//no modify

}

bool RestrictedWord::isSecretOK(const std::string& str)
{
	const char* strChar = str.c_str();
	for(int i=0;i<str.length();++i)
	{
		unsigned char cha = (*strChar);
		if((cha&0x80) == 0)
		{
			bool isOK = false;
			if(cha>='0' && cha<='9')//number
				isOK = true;
			if(cha>='a' && cha<='z')//number
				isOK = true;
			if(cha>='A' && cha<='Z')//
				isOK = true;			

			if(isOK == false)
				return false;
		}
		else
		{
			return false;
		}
		strChar++;
	}

	return true;
}

std::string RestrictedWord::filterWordSentence( const std::string& str )
{
	std::string newStr = str;
	//
	int x = 0; 
	std::list<std::string>::iterator it = mRestrictList.begin();
	for(; it != mRestrictList.end(); ++it)
	{
		std::map<int, std::string> strMap;
		GameMaths::readStringToMap(*it,strMap);
		const char* start = str.c_str();

		int i=0;
		//if (!SeverConsts::Get()->IsJgg()){
		if (filterTargetWord(newStr, *it)){
			newStr = "**********";
		}
		//}
		while(i+it->length()<=str.length())
		{
			if(strncmp(str.c_str()+i,it->c_str(),it->length())==0)
			{
				newStr.replace(i, it->length(), it->length(), '*');
				i+=it->length();
				
			}
			else
				i++;
		}
		x++;
	}
	//
	return newStr;//no modify
	//
}

bool RestrictedWord::filterTargetWord(const std::string& str, const std::string& regex)
{
	std::string regexStr = regex;
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)

	std::regex targetRule(regexStr);
	return (std::regex_match(str, targetRule));

#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID||CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	char ss[200] = {};
	sprintf(ss, "%s", str.c_str());
	regmatch_t pmatch[4];
	regex_t match_regex;

	regcomp(&match_regex,
		regexStr.c_str(),
		REG_EXTENDED);
	if (regexec(&match_regex, ss, 4, pmatch, 0) != 0)
	{
		regfree(&match_regex);
		return false;
	}
	regfree(&match_regex);
	return true;
#endif
}