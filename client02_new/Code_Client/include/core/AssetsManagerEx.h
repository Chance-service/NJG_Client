#ifndef __AssetsManagerEx__
#define __AssetsManagerEx__

#include <string>
#include "Singleton.h"
class AssetsManagerEx : public Singleton<AssetsManagerEx>
{
public:
    AssetsManagerEx();
    virtual ~AssetsManagerEx();
	static AssetsManagerEx* getInstance(){ return AssetsManagerEx::Get(); }
	
	bool uncompress(const std::string& file,const std::string& stroge);
	bool createDirectory(const char *path);
};

#endif /* defined(__AssetsManagerEx__) */
