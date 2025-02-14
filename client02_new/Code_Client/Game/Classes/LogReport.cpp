
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
			//�ާ@����
			url.append("/" + action + "?");

			//�S��r�Ŧ����
			string old_value = "#";
			string new_value = "";
			while (true)   {
				string::size_type   pos(0);
				if ((pos = deviceType.find(old_value)) != string::npos)
					deviceType.replace(pos, old_value.length(), new_value);
				else   
					break;
			}

			//deviceType  �]������
			url.append("deviceType=" + deviceType);
			//deviceId �]�ƽs��
			url.append("&deviceId=" + deviceId);
			//version ������
			url.append("&version=" + version);
			//strlog �ާ@���
			url.append("&strlog=" + strlog);

			//�ƾڥu�޵o������^�B�z
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