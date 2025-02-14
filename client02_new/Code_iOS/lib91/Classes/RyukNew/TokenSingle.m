//
//  TokenSingle.m
//  Com4XGDemo
//
//  Created by finn on 2017/9/12.
//  Copyright © 2017年 wzm. All rights reserved.
//

#import "TokenSingle.h"

static TokenSingle *m_instance;
@implementation TokenSingle

+ (TokenSingle *)sharedObject{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        m_instance = [[TokenSingle alloc] init];
    });
    return m_instance;
}
@end
