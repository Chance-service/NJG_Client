#ifndef  _CORESDK_API_UTIL_H_
#define  _CORESDK_API_UTIL_H_

#include "cocos2d.h"
#include "coresdk/Result.h"

namespace coresdk {
	class APIUtil : public cocos2d::CCObject
	{
	public:
		struct RawResponse {
			int StatusCode;
			std::string Data;
			std::string Exception;
		};

	public:
		typedef void(*OnRequestAPICallback)(RawResponse);
		
	public:
		static APIUtil *create();

	public:
		void requestAPI(
			std::string url, 
			std::map<std::string, std::string> queryStringMap, 
			std::string authorization, 
			std::string body, 
			OnRequestAPICallback callback);

	private:
		void onHttpRequestCompleted(cocos2d::CCNode *sender, void *data);
	};
}

#endif // _CORESDK_API_UTIL_H_

