//
//  libPPObj.h
//  libPP
//
//  Created by wzy on 13-3-5.
//  Copyright (c) 2013年 youai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//#import <NdComPlatform/NdComPlatform.h>
//#import <NdComPlatform/NdComPlatformAPIResponse.h>
//#import <NdComPlatform/NdCPNotifications.h>


#import <PPAppPlatformKit/PPAppPlatformKit.h>

@interface libAGObj :  NSObject <PPAppPlatformKitDelegate>
{
    UIActivityIndicatorView *waitView;
}
-(void) SNSInitResult:(NSNotification *)notify;
-(void) unregisterNotification;
-(NSString *) getUserName;
-(NSString *) getUserID;
@end
