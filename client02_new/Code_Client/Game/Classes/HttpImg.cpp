#include "HttpImg.h"
#include "GamePlatform.h"
#include "CCLuaEngine.h"
NS_CC_EXT_BEGIN
#define HTTPIMGFOLDER "httpImg"
HttpImg::HttpImg()
{

}

HttpImg::~HttpImg()
{

}

void HttpImg::getHttpImg(const std::string& imgPath,const std::string& imgName )
{
	if (!isImgIsDowning(imgName))
	{
		CCLog("getHttpImg name =======================%s",imgPath.c_str());
		addImgToDowningSet(imgName);
		CCLog("mImgDowningSet:size =======================%d",mImgDowningSet.size());
		CCHttpRequest* request = new CCHttpRequest();
		request->setUrl(imgPath.c_str());
		request->setRequestType(CCHttpRequest::kHttpGet);
		request->setResponseCallback(this, httpresponse_selector(HttpImg::onHttpImgCompleted));
		request->setTag(imgName.c_str());
		CCHttpClient::getInstance()->send(request);
		
		request->release();
	}
}

void HttpImg::onHttpImgCompleted( CCHttpClient *sender, CCHttpResponse *response )
{
	if (!response)
	{
		return;
	}

	// You can get original request type from: response->request->reqType
	if (0 != strlen(response->getHttpRequest()->getTag())) 
	{
		CCLog("%s completed", response->getHttpRequest()->getTag());
	}

	removeImgFromDowningSet(response->getHttpRequest()->getTag());

	if (!response->isSucceed()) 
	{
		CCLog("response failed");
		CCLog("error buffer: %s", response->getErrorBuffer());
		return;
	}
	CCLog("image save =======================!11111111111111111");
	std::vector<char> *buffer = response->getResponseData();
	std::string fileName = response->getHttpRequest()->getTag();
	std::string saveFilePath = CCFileUtils::sharedFileUtils()->getWritablePath() + "/" + HTTPIMGFOLDER + "/" + fileName;
	saveFileInPath(saveFilePath,"wb",(unsigned char*)buffer->data(),buffer->size());
	CCLog("image save =======================22222222222222222222");
	
	/*
	CCImage* img = new CCImage;
	img->initWithImageData((unsigned char*)buffer->data(),buffer->size());

	CCTexture2D* texture = new CCTexture2D();
	bool isImg = texture->initWithImage(img);
	
	img->saveToFile(saveFilePath.c_str(),kCCImageFormatJPEG);
	img->release();
	*/
	std::multimap<std::string, HttpImgListener*>::iterator iter = mListeners.begin();

	while(iter!=mListeners.end())
	{
		if (iter->first == fileName)
		{
			iter->second->onHttpImgCompleted(fileName);
			mListeners.erase(iter++);
			//iter = mListeners.begin();
		}
		else
		{
			iter ++;
		}
		
	};
}

bool HttpImg::isImgIsDowning( const std::string& imgName )
{
	if(mImgDowningSet.find(imgName) != mImgDowningSet.end())
	{
		return true;
	}
	return false;
}

void HttpImg::addImgToDowningSet( const std::string& imgName )
{
	mImgDowningSet.insert(imgName);
}

void HttpImg::removeImgFromDowningSet( const std::string& imgName )
{
	mImgDowningSet.erase(imgName);
}

void HttpImg::addListener( HttpImgListener* listener,const std::string& imgName )
{
	mListeners.insert(std::make_pair(imgName, listener));
}

void HttpImg::removeListener( HttpImgListener* listener )
{
	std::multimap<std::string, HttpImgListener*>::iterator iter = mListeners.begin();
	for (; iter!=mListeners.end();)
	{
		if (iter->second == listener)
		{
            mListeners.erase(iter++);
			//break;
		}
		else
		{
			iter++;
		}
	}
}

NS_CC_EXT_END