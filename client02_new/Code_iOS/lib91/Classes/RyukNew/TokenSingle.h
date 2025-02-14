//
//  TokenSingle.h
//  Com4XGDemo
//
//  Created by finn on 2017/9/12.
//  Copyright © 2017年 wzm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TokenSingle : NSObject

@property (nonatomic,strong)NSData *deviceToken;
@property (nonatomic,strong)NSString *pushParam;
+ (TokenSingle *)sharedObject;

@end
