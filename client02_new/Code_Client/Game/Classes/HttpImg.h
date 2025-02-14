#ifndef __HTTPIMG_H_
#define __HTTPIMG_H_

#include "Singleton.h"

#include "cocos2d.h"
#include "ExtensionMacros.h"
#include "network/HttpRequest.h"
#include "network/HttpClient.h"
#include "network/HttpResponse.h"
NS_CC_EXT_BEGIN

class HttpImgListener
{
public:
	virtual void onHttpImgCompleted(std::string& imgName){};
};
class HttpImg : public CCObject,public Singleton<HttpImg>
{
public:
	HttpImg();
	~HttpImg();

	void getHttpImg(const std::string& imgPath,const std::string& imgName);
	void onHttpImgCompleted(CCHttpClient *sender, CCHttpResponse *response);

	void addListener(HttpImgListener* listener,const std::string& imgName);
	void removeListener(HttpImgListener* listener);
	static HttpImg* getInstance() {return HttpImg::Get();}
private:
	bool isImgIsDowning(const std::string& imgName);
	void addImgToDowningSet(const std::string& imgName);
	void removeImgFromDowningSet(const std::string& imgName);
	std::multimap<std::string, HttpImgListener*> mListeners;
	std::set<std::string> mImgDowningSet;
};
NS_CC_EXT_END
#endif