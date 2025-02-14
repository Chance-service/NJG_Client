#include "BCWebRequest.h"
USING_NS_CC;

#include "cocos-ext.h"
#include "../extensions/network/HttpClient.h"
#include "../extensions/network/HttpRequest.h"
USING_NS_CC_EXT;

BCWebRequest::BCWebRequest()
{

}

BCWebRequest::~BCWebRequest()
{

}

std::string BCWebRequest::get_url() {
	return this->url;
}

void BCWebRequest::get(std::string url, OnHttpCallback callback) {
	this->url = url;
	this->onHttpCallback = callback;

    CCHttpRequest* request = new CCHttpRequest();
	request->setUrl(this->url.c_str());
    request->setRequestType(CCHttpRequest::kHttpGet);
	request->setResponseCallback(this, callfuncND_selector(BCWebRequest::onHttpRequestCompleted));
    
    CCHttpClient::getInstance()->send(request);
    request->release();
}

void BCWebRequest::post(std::string url, std::string tag, std::string data, OnHttpCallback callback) {
	this->url = url;
	this->onHttpCallback = callback;

	CCHttpRequest* request = new CCHttpRequest();
	request->setUrl(this->url.c_str());
	request->setRequestType(CCHttpRequest::kHttpPost);
	request->setTag(tag.c_str());
	if (data.size() > 0) {
		request->setRequestData(data.c_str(), data.size());
	}
	request->setResponseCallback(this, callfuncND_selector(BCWebRequest::onHttpRequestCompleted));

	CCHttpClient::getInstance()->send(request);
	request->release();
}

void BCWebRequest::onHttpRequestCompleted(cocos2d::CCNode *sender, void *data) {
    CCHttpResponse *response = (CCHttpResponse*)data;
	HttpResult httpresult = HttpResult();
    if (!response)
    {
		if (onHttpCallback){
			httpresult.code = -1;
			httpresult.isError = true;
			httpresult.tag = "";
			httpresult.responseData = "";
			onHttpCallback(httpresult);
		}
        return;
    }
    
    int statusCode = response->getResponseCode();
	const char* tag = response->getHttpRequest()->getTag();
    if (!response->isSucceed()) 
    {
        CCLog("response failed");
        CCLog("error buffer: %s", response->getErrorBuffer());

		std::string error(response->getErrorBuffer());

		if (onHttpCallback){
			httpresult.code = statusCode;
			httpresult.isError = true;
			httpresult.tag = tag;
			httpresult.responseData = error;
			onHttpCallback(httpresult);
		}
        return;
    }

	// 將結果合併成字串
	std::vector<char> *buffer = response->getResponseData();
	std::string res(buffer->begin(), buffer->end());
	//CCLog("%s", res.c_str());

	if (onHttpCallback){
		httpresult.code = statusCode;
		httpresult.isError = false;
		httpresult.tag = tag;
		httpresult.responseData = res;
		onHttpCallback(httpresult);
	}
}