//
//  EfunAdSystem.h
//  Project_01_AD
//
//  Created by czf on 13-6-22.
//  Copyright (c) 2013年 efun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EfunAdSystem : NSObject

+(void)startSystemWhenLoaded
    __attribute__((deprecated(" use EfunSDK's + application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions")));

+(void)startSystemWhenBecomeActive
    __attribute__((deprecated(" use EfunSDK's + applicationDidBecomeActive:(UIApplication *)application")));

+ (BOOL)handleADURL:(NSURL *)url
    __attribute__((deprecated(" use EfunSDK's + application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation")));

@end
