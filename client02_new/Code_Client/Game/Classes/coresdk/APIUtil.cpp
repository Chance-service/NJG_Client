#include "APIUtil.h"
USING_NS_CC;

#include "cocos-ext.h"
#include "../extensions/network/HttpClient.h"
#include "../extensions/network/HttpRequest.h"
USING_NS_CC_EXT;

#include "rapidjson/rapidjson.h"
#include "rapidjson/document.h"

namespace coresdk {
	// 定義函式指標
	APIUtil::OnRequestAPICallback onRequestAPICallback;

	APIUtil *APIUtil::create() {
		APIUtil *r = new APIUtil();
		return r;
	}

	void APIUtil::requestAPI(
		std::string url, 
		std::map<std::string, std::string> queryStringMap, 
		std::string authorization, 
		std::string body, 
		OnRequestAPICallback callback)
	{
		onRequestAPICallback = callback;

		std::string _url(url);
		// 將query 拼接成字串
		if (queryStringMap.size() > 0) {
			std::map<std::string, std::string>::iterator it;
			std::string buf("");
			for (it = queryStringMap.begin(); it != queryStringMap.end(); it++) {
				std::string key = (*it).first;
				std::string value = (*it).second;

				if (buf.length() > 0) {
					buf.append("&");
				}
				buf.append(key);
				buf.append("=");
				buf.append(value);
			}

			_url.append("?");
			_url.append(buf);
		}

		CCHttpClient* httpClient = CCHttpClient::getInstance();  
		CCHttpRequest* httpReq = new CCHttpRequest();
		httpReq->setRequestType(body.empty() ? CCHttpRequest::kHttpGet : CCHttpRequest::kHttpPost);
		httpReq->setUrl(_url.c_str());  

		std::vector<std::string> headers;
		if (!authorization.empty()) {
			headers.push_back("Authorization: " + authorization);
		}

		if (!body.empty()) {
			headers.push_back("Content-Type: application/x-www-form-urlencoded; charset=UTF-8");
		}

		httpReq->setHeaders(headers);
		httpReq->setResponseCallback(this, callfuncND_selector(APIUtil::onHttpRequestCompleted));  

		// write the post data
		const char* postData = body.c_str();
		httpReq->setRequestData(postData, strlen(postData));

		/*
		CCLog("url:%s", url.c_str());
		CCLog("RequestType:%s", httpReq->getRequestType() == CCHttpRequest::kHttpGet ? "GET" : 
			httpReq->getRequestType() == CCHttpRequest::kHttpPost ? "POST" : "unknown" );
		CCLog("body:%s", body.c_str());
		*/

		httpClient->setTimeoutForConnect(30);  
		httpClient->send(httpReq);  
		httpReq->release();	
	}

	void APIUtil::onHttpRequestCompleted(cocos2d::CCNode *sender, void *data)
	{
		CCHttpResponse *response = (CCHttpResponse*)data;

		if (!response)
		{
			return;
		}
    
		// You can get original request type from: response->request->reqType
		if (0 != strlen(response->getHttpRequest()->getTag())) 
		{
			CCLog("%s completed", response->getHttpRequest()->getTag());
		}
    
		int statusCode = response->getResponseCode();
		//char statusString[64] = {};
		//sprintf(statusString, "HTTP Status Code: %d, tag = %s", statusCode, response->getHttpRequest()->getTag());
		//CCLog("%s", statusString);
		//CCLog("response code: %d", statusCode);
    
		if (!response->isSucceed()) 
		{
			CCLog("response failed");
			CCLog("error buffer: %s", response->getErrorBuffer());
			return;
		}

		// 將結果合併成字串
		std::vector<char> *buffer = response->getResponseData();
		std::string res(buffer->begin(), buffer->end());
		//CCLog("%s",res.c_str());

		// json 解析
		/*
		rapidjson::Document d;
		d.Parse < 0 > (res.c_str());
		if (d.IsObject() && d.HasMember("result")) { 
			CCLOG("%s\n", d["result"].GetString());
		}
		*/

		struct RawResponse rawResponse;
		rawResponse.StatusCode = statusCode;
		rawResponse.Data = res;

		if (onRequestAPICallback)
			onRequestAPICallback(rawResponse);
	}
}