//
//  RyukPlatformListener.hpp
//  Game
//
//  Created by 黄可 on 16/5/23.
//
//

#ifndef RyukPlatformListener_h
#define RyukPlatformListener_h

#include <stdio.h>
#include "libPlatform.h"
//#import <Google/Analytics.h>

class RyukPlatformListener : public platformListener
{
public:
    RyukPlatformListener()
    {
        libPlatformManager::getPlatform()->registerListener(this);
    };
    ~RyukPlatformListener()
    {
        libPlatformManager::getPlatform()->removeListener(this);
    };
    virtual std::string onReceiveCommonMessage(const std::string& tag,const std::string& msg);
};

#endif /* RyukPlatformListener_h */
