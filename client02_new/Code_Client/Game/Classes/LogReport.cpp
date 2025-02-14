
#include "stdafx.h"
#include "LogReport.h"
#include <string>
#include "network/HttpClient.h"
#include "network/HttpRequest.h"
#include "DataTableManager.h"

USING_NS_CC;
USING_NS_CC_EXT;

using namespace cells;

void CLogReport::init(string initUrl)
{
	reportUrl = initUrl;
}

string CLogReport::getReportType(EnumReportType type)
{
	switch (type)
	{
	case EnumReportType::CHKVERSION: return "chkversion"; break;
	default: return "error"; break;
	}
}

void CLogReport::webReportLog(string action, string deviceType, string deviceId, string version, string strlog)
{

	string isOpen=VaribleManager::Get()->getSetting("OpenReportUpdate", "","1");
	if (isOpen=="1")
	{
		try
		{
			std::string url = reportUrl;
			//操作類型
			url.append("/" + action + "?");

			//特殊字符串替換
			string old_value = "#";
			string new_value = "";
			while (true)   {
				string::size_type   pos(0);
				if ((pos = deviceType.find(old_value)) != string::npos)
					deviceType.replace(pos, old_value.length(), new_value);
				else   
					break;
			}

			//deviceType  設備類型
			url.append("deviceType=" + deviceType);
			//deviceId 設備編號
			url.append("&deviceId=" + deviceId);
			//version 版本號
			url.append("&version=" + version);
			//strlog 操作日志
			url.append("&strlog=" + strlog);

			//數據只管發不做返回處理
			auto request = new CCHttpRequest();
			request->setUrl(url.c_str());
			request->setRequestType(CCHttpRequest::HttpRequestType::kHttpGet);
			CCHttpClient::getInstance()->send(request);

			request->release();
		}
		catch (...)
		{
			CCLog("URL REQUEST IS NOT  REACH");
		}
	}

}