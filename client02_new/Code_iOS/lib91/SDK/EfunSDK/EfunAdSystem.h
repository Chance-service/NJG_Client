//
//  EfunAdSystem.h
//  Project_01_AD
//
//  Created by czf on 13-6-22.
//  Copyright (c) 2013年 efun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EfunAdSystem : NSObject

+(void)startSystemWhenLoaded;

+(void)startSystemWhenBecomeActive;

+ (BOOL)handleADURL:(NSURL *)url;
@end
