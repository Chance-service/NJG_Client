//
//  SModuleManager.h
//
//  Created by dev on 2017/8/31.
//  Copyright © 2017年 dev. All rights reserved.
//

#import "SModule.h"

@interface SModuleManager : NSObject

enum SModuleTag
{
    SModuleTagPlatform,
    SModuleTagShare
};

+ (instancetype)getInstance;
- (void)addModule:(SModule *)module;
- (SModule *)getModule:(enum SModuleTag)tag;

@end
