//
//  RyukExpand.h
//  lib91
//
//  Created by 黄可 on 16/5/26.
//  Copyright © 2016年 youai. All rights reserved.
//

#ifndef RyukNewExpand_h
#define RyukNewExpand_h

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface RyukNewExpand : NSObject <FBSDKSharingDelegate,MFMailComposeViewControllerDelegate>

- (void) init;
- (void) FBSharePhoto:(NSDictionary *)dict;
- (void) sendEmail:(NSString* )msg;
@end
#endif /* RyukExpand_h */
