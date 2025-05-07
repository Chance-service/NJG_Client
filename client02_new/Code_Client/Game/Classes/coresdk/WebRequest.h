#ifndef  _CORESDK_WEB_REQUEST_H_
#define  _CORESDK_WEB_REQUEST_H_

#include "cocos2d.h"

class WebRequest : public cocos2d::CCObject
{
public:
	typedef void(*OnHttpCallback)(bool, std::string);	// isSuccess, responseText

public:
	static WebRequest *create();

public:
	std::string get_url();
	void get(std::string url, OnHttpCallback callback);

private:
	void onHttpRequestCompleted(cocos2d::CCNode *sender, void *data);

private:
	std::string url;
	OnHttpCallback onHttpCallback;
};

#endif // _CORESDK_WEB_REQUEST_H_

