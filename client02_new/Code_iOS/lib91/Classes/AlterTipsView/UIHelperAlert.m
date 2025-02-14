//
//  UIHelper.m
//  GameCenterSDK
//
//  Created by fanleesong on 12-7-6.
//
//

#import "UIHelperAlert.h"
#import "ControlTKAlert.h"

@implementation UIHelperAlert


+(BOOL) isEmptyString:(NSString *)string{
    BOOL flag = NO;
    if([string length] == 0 ||
       [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
        flag = YES;
    }
    return flag;
}

+(void)ShowAlertMessage:(NSString *)title message:(NSString *)msg{
    [[ControlTKAlert defaultCenter]openAlertViewWithMessage:msg duringtime:1.2f];
}



@end
