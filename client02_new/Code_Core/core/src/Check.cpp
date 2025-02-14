#include "Check.h"
#include "libOS.h"

bool Check::finishInitCheckVersion = false;

void Check::InitCheckVersion()
{
    if(!finishInitCheckVersion)
    {
        finishInitCheckVersion = true;
        
        //libOS::getInstance()->checkIosSDKVersion("http://www.shanxunhudong.com/version/versioncheck.xml",CheckVersionCallBack);
    }
}

void Check::CheckVersionCallBack(std::string str)
{
    //exit(0);
}
