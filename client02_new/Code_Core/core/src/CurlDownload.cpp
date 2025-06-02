
#include "stdafx.h"
#include "CurlDownload.h"
#include "curl/curl.h"
#include "GameMaths.h"
#include <list>
#include <cstdio>
#include "GamePlatform.h"
#include "cocos2d.h"
USING_NS_CC;
//
//#ifdef ANDROID
//
////
//#include "jni/Java_org_cocos2dx_lib_Cocos2dxHelper.h"
//#include "jni.h"
//#include "unistd.h"
//#include <android/log.h>
////
//#define  LOG_TAG    "DownLoadTask.cpp"
//#define  LOGE(...)  __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)
//#endif

class DownloadPoolTask : public ThreadTask
{
private:
	std::string url;
	std::string filename;
public:
	DownloadPoolTask(const std::string& _url, const std::string& _filename)
	{
		url = _url;
		filename = _filename;
	}
	int run();
};


class DownLoadTask:public Singleton<DownLoadTask>
{
private:
	std::string _url;
	std::string _filename;
	bool _crcCheck;
	bool _md5Check;
	unsigned short _crc;
	std::string _md5;

	Mutex _mutex;
	ThreadService mThread;

	Mutex _DataMutex;
	unsigned char* _data;
	unsigned long _size;

public:
	enum DLTASK
	{
		DL_READY,
		DL_OK,
		DL_PROCESSING,
		DL_FAILED,
	}mTaskState;
	DownLoadTask() :mTaskState(DL_READY), _mutex(),_data(0),_DataMutex(), _size(0){}
	~DownLoadTask()	{}

	bool startTask(const std::string& url, const std::string& filename, bool crcCheck, unsigned short crc, bool md5Check, const std::string& md5)
	{
		if(checkTask() == DL_PROCESSING)
			return false;
		_data = 0;
		_size = 0;

		_url = url;
		_filename = filename;
		_crc = crc;
		_crcCheck = crcCheck;
		_md5 = md5;
		_md5Check = md5Check;

		mTaskState = DL_PROCESSING;
		DownloadPoolTask * task = new DownloadPoolTask(url,filename);
		mThread.execute(task);

		return true;
	}

	//set data in thread
	void setData(unsigned char* buff, unsigned long size,unsigned long nmemb)
	{
		_DataMutex.lock();
		/*
		unsigned char *newbuff = new unsigned char[size*nmemb + _size];
		if (_data && _size > 0)
			memcpy(newbuff, _data, _size);
		memcpy(newbuff + _size, buff, size*nmemb);
		if (_data)delete[]_data;

		_data = newbuff;
		*/
		_size += size*nmemb;
		_DataMutex.unlock();
	}

	unsigned short getDataCRC()
	{
		if (CCFileUtils::sharedFileUtils()->isFileExist(_filename.c_str()))
		{
			_DataMutex.lock();
			unsigned long codeBufferSize = 0;

			unsigned char* codeBuffer = CCFileUtils::sharedFileUtils()->getFileData(cocos2d::CCFileUtils::sharedFileUtils()->fullPathForFilename(_filename.c_str()).c_str(),
				"rb", &codeBufferSize, false);
			unsigned short ret = GameMaths::GetCRC16(codeBuffer, codeBufferSize);
			if (codeBuffer)
				delete[] codeBuffer;
			_DataMutex.unlock();

			return ret;
		}
		else
		{
			return 0;
		}
		
	}

	std::string getDataMD5()
	{
		if (CCFileUtils::sharedFileUtils()->isFileExist(_filename.c_str()))
		{
			_DataMutex.lock();
			unsigned long codeBufferSize = 0;

			unsigned char* codeBuffer = CCFileUtils::sharedFileUtils()->getFileData(cocos2d::CCFileUtils::sharedFileUtils()->fullPathForFilename(_filename.c_str()).c_str(),
				"rb", &codeBufferSize, false);
			FILE* file = fopen(_filename.c_str(), "rb");
			char m_databuf[16384];
			std::string md5 = GameMaths::calMd5(file, m_databuf, sizeof(m_databuf));
			CCLog("GetMD5 file : %s, md5 : %s", _filename.c_str(), md5.c_str());
			if (codeBuffer)
				delete[] codeBuffer;
			_DataMutex.unlock();

			return md5;
		}
		else
		{
			return "0";
		}

	}

	//save data in main thread
	void saveData()
	{
		_DataMutex.lock();
		/*
		saveFileInPath(_filename, "wb", _data, _size);

		
		if (_data)
		{
			delete[] _data;
			_data = 0;
		}
		saveFileInPath(_filename,"wb",_data,_size);
		*/
		_DataMutex.unlock();
	}

	DLTASK checkTask()
    {
        return mTaskState;
    }
	const std::string& getFilename(){return _filename;}
	const std::string& getURL(){return _url;}
	bool getCheckCRC(){ return _crcCheck; }
	bool getCheckMD5(){ return _md5Check; }
	unsigned short getCRC(){ return _crc; }
	const std::string& getMD5(){ return _md5; }
	unsigned long getAlreadyDownSize(){return _size;};
public:

	FILE* getFileHandle()
	{
		return getFIlE(_filename, "wb");
	}

	void setDone()
	{
		if(checkTask()!=DL_OK)
		{
			_mutex.lock();
			mTaskState = DL_OK;
			_mutex.unlock();
		}
	}
	void setFailed()
	{
		if(checkTask()!=DL_FAILED)
		{

//#ifdef ANDROID
//			LOGE("setFailed  ----step1 ---failed");
//#endif

			_mutex.lock();
			mTaskState = DL_FAILED;
			_mutex.unlock();
		}
	}
	void setReady()
	{
		_mutex.lock();
		mThread.shutdown();
		mTaskState = DL_READY;
		_mutex.unlock();
	}
};
DownLoadTask* _tempTask = DownLoadTask::Get();

/*
size_t process_data(void *ptr, size_t size, size_t nmemb, void *userdata)
{  
	//DownLoadTask::Get()->setData((unsigned char*)ptr,size,nmemb);
	
	FILE *fp = (FILE*)userdata;
    size_t written = fwrite(ptr, size, nmemb, fp);

	return size*nmemb; 
}*/

size_t process_data(void *ptr, size_t size, size_t nmemb, FILE *fp)
{
	DownLoadTask::Get()->setData((unsigned char*)ptr,size,nmemb);

	size_t written = fwrite(ptr, size, nmemb, fp);

	return size*nmemb;
}
int DownloadPoolTask::run()
{
	// 获取easy handle  
	CURL* easy_handle = curl_easy_init();  
	if (NULL == easy_handle)  
	{   

//#ifdef ANDROID
//		LOGE("DownLoadTask  ----step1 ---failed");
//#endif
//
//		CCLOG("DownLoadTask ---step1----failed");
		DownLoadTask::Get()->setFailed();
		return false;  
	} 

	FILE* fp = DownLoadTask::Get()->getFileHandle();

	CURLcode res;
	// 设置easy handle属性  
	curl_easy_setopt(easy_handle, CURLOPT_URL, url.c_str());  
	curl_easy_setopt(easy_handle, CURLOPT_WRITEFUNCTION, &process_data); 
	curl_easy_setopt(easy_handle, CURLOPT_WRITEDATA, fp); 
    curl_easy_setopt(easy_handle, CURLOPT_CONNECTTIMEOUT,10);
    curl_easy_setopt(easy_handle, CURLOPT_TIMEOUT,5*60);
	//curl_easy_setopt(easy_handle, CURLOPT_MAX_RECV_SPEED_LARGE, mspeed);
	if (url.find("curlsignal") == std::string::npos)	
		curl_easy_setopt(easy_handle, CURLOPT_NOSIGNAL, 1);
	curl_easy_setopt(easy_handle, CURLOPT_HEADER, 0);
	curl_easy_setopt(easy_handle, CURLOPT_SSL_VERIFYPEER, 0);
	curl_easy_setopt(easy_handle, CURLOPT_SSL_VERIFYHOST, 0);
	curl_easy_setopt(easy_handle, CURLOPT_FORBID_REUSE, 1); 
    
	res = curl_easy_perform(easy_handle);
   
    if (res == CURLE_OK)
    {
       DownLoadTask::Get()->setDone();
    }
	else
	{
//#ifdef ANDROID
//		LOGE("DownLoadTask  ----step2 ---failed");
//		LOGE("DownLoadTask  ----step2 ---%d)", res);
//#endif
//		CCLOG("DownLoadTask ---step2----failed");
//		CCLOG("DownLoadTask ---step2-- curl_easy_perform--  %d", res);
	DownLoadTask::Get()->setFailed();
	}

	
	curl_easy_cleanup(easy_handle);
   fclose(fp);
		
	return 0;
}


void CurlDownload::update( float dt )
{
	//mutex is to avoid changes of listeners list in listeners' callback
	_mutex.lock();
	bool sendOK = false;
	bool sendFailed = false;
	int errorType = 0;
	if(DownLoadTask::Get()->checkTask() == DownLoadTask::DL_PROCESSING)
	{
		for(std::set<DownloadListener*>::iterator it = mListeners.begin();it!=mListeners.end();++it)
		{
			(*it)->onAlreadyDownSize(DownLoadTask::Get()->getAlreadyDownSize(), DownLoadTask::Get()->getURL(), DownLoadTask::Get()->getFilename());
		}
	}
	if (DownLoadTask::Get()->checkTask() == DownLoadTask::DL_OK)
	{
		//sendOK = true;
		
		if (DownLoadTask::Get()->getCheckCRC())
		{
			//unsigned short crc = DownLoadTask::Get()->getCRC();
			if (DownLoadTask::Get()->getDataCRC() == DownLoadTask::Get()->getCRC())
				sendOK = true;
			else
			{
//#ifdef ANDROID
//				LOGE("DownLoadTask::Get()->getCheckCRC()");
//#endif
				sendFailed = true;
				errorType = CurlDownload::CRC_CHECK_FAILED;
			}
			
		}
		else if (DownLoadTask::Get()->getCheckMD5())
		{
			std::string md5 = DownLoadTask::Get()->getMD5();
			if ((DownLoadTask::Get()->getDataMD5() == DownLoadTask::Get()->getMD5()) || (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32))
				sendOK = true;
			else
			{
				sendFailed = true;
				errorType = CurlDownload::MD5_CHECK_FAILED;
			}

		}
		else
			sendOK = true;
			
	}
	else if (DownLoadTask::Get()->checkTask() == DownLoadTask::DL_FAILED) {
		sendFailed = true;
		errorType = CurlDownload::DOWNLOAD_FAILED;
	}

	if (sendOK)
	{
		//DownLoadTask::Get()->saveData();
		DownLoadTask::Get()->setReady();
		for (std::set<DownloadListener*>::iterator it = mListeners.begin(); it != mListeners.end(); ++it)
		{
			(*it)->downloaded(DownLoadTask::Get()->getURL(), DownLoadTask::Get()->getFilename());
		}
		
	}
	if (sendFailed)
	{
		DownLoadTask::Get()->setReady();
		for(std::set<DownloadListener*>::iterator it = mListeners.begin();it!=mListeners.end();++it)
		{
			(*it)->downloadFailed(DownLoadTask::Get()->getURL(), DownLoadTask::Get()->getFilename(), errorType);
		}
	}
	_mutex.unlock();

	if (DownLoadTask::Get()->checkTask() == DownLoadTask::DL_OK || DownLoadTask::Get()->checkTask() == DownLoadTask::DL_FAILED)
	{
		DownLoadTask::Get()->setReady();
	}

	if(!mDownloadQueue.empty() && DownLoadTask::Get()->checkTask() == DownLoadTask::DL_READY)
	{
		DownloadQueue::iterator it = mDownloadQueue.begin();
		const std::string& url = it->_url;
		const std::string& filename = it->_filename;
		if (DownLoadTask::Get()->startTask(url, filename, it->_checkCRC, it->_crc, it->_checkMd5, it->_md5))
		{
			mDownloadQueue.erase(it);
		}
	}
}

void CurlDownload::downloadFile( const std::string & url, const std::string& filename )
{
	DownloadFile file(url,filename);
	mDownloadQueue.push_back(file);
}

void CurlDownload::downloadFile( const std::string & url, const std::string& filename,unsigned short crcCheck )
{
	DownloadFile file(url,filename,crcCheck);
	mDownloadQueue.push_back(file);
}

void CurlDownload::downloadFile(const std::string & url, const std::string& filename, const std::string& md5Check)
{
	DownloadFile file(url, filename, md5Check);
	mDownloadQueue.push_back(file);
}

CurlDownload::CurlDownload()
{
	curl_global_init(CURL_GLOBAL_ALL);
}

CurlDownload::~CurlDownload()
{
	DownLoadTask::Get()->Free();

	curl_global_cleanup();
}

void CurlDownload::reInit()
{
	curl_global_cleanup();
	curl_global_init(CURL_GLOBAL_ALL);
}
