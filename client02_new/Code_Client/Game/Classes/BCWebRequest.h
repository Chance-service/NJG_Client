
#include "cocos2d.h"
#include "Singleton.h"

class BCWebRequest : public cocos2d::CCObject, public Singleton<BCWebRequest>
{
public:
	struct HttpResult {
		int code;
		std::string tag;
		std::string responseData;
		bool isError;
	};

	typedef void(*OnHttpCallback)(HttpResult);

public:
	BCWebRequest();
	~BCWebRequest();
	std::string get_url();
	void get(std::string url, OnHttpCallback callback);
	void post(std::string url, std::string tag, std::string data, OnHttpCallback callback);
	static BCWebRequest* getInstance() { return BCWebRequest::Get(); }

private:
	void onHttpRequestCompleted(cocos2d::CCNode *sender, void *data);
	
private:
	std::string url;
	OnHttpCallback onHttpCallback;
};


