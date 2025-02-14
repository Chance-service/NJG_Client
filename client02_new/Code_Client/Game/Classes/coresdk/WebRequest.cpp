#include "WebRequest.h"
USING_NS_CC;

#include "cocos-ext.h"
#include "../extensions/network/HttpClient.h"
#include "../extensions/network/HttpRequest.h"
USING_NS_CC_EXT;

WebRequest *WebRequest::create() {
	WebRequest *r = new WebRequest();
	return r;
}

std::string WebRequest::get_url() {
	return this->url;
}

void WebRequest::get(std::string url, OnHttpCallback callback) {
	this->url = url;
	this->onHttpCallback = callback;

    CCHttpRequest* request = new CCHttpRequest();
	request->setUrl(this->url.c_str());
    request->setRequestType(CCHttpRequest::kHttpGet);
    request->setResponseCallback(this, callfuncND_selector(WebRequest::onHttpRequestCompleted));
    
    CCHttpClient::getInstance()->send(request);
    request->release();
}

void WebRequest::onHttpRequestCompleted(cocos2d::CCNode *sender, void *data) {
    CCHttpResponse *response = (CCHttpResponse*)data;

    if (!response)
    {
		if (this->onHttpCallback)
			this->onHttpCallback(true, "");
        return;
    }
    
    int statusCode = response->getResponseCode();
    if (!response->isSucceed()) 
    {
        CCLog("response failed");
        CCLog("error buffer: %s", response->getErrorBuffer());

		std::string error(response->getErrorBuffer());

		if (this->onHttpCallback)
			this->onHttpCallback(true, error);
        return;
    }

	// 將結果合併成字串
	std::vector<char> *buffer = response->getResponseData();
	std::string res(buffer->begin(), buffer->end());
	//CCLog("%s", res.c_str());

	if (this->onHttpCallback)
		this->onHttpCallback(false, res);
}