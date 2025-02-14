#ifndef _CHECK_HH
#define _CHECK_HH

#include <string>

class Check
{
public:
    static bool finishInitCheckVersion;
    static void InitCheckVersion();
    static void CheckVersionCallBack(std::string str);
};

#endif 
