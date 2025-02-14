#pragma once
#include "Singleton.h"
#include <string>
using namespace std;


typedef enum
{
	CHKVERSION
} EnumReportType;


class CLogReport :public Singleton<CLogReport>
{
private: 
	string reportUrl;
public:
	void   init(string initUrl);
	string getReportType(EnumReportType type);
	void   webReportLog(string action, string deviceType, string deviceId,string version,string strlog);
	

};