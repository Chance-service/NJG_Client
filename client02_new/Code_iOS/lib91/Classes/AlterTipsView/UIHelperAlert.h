//
//  UIHelper.h
//  GameCenterSDK
//
//  Created by fanleesong on 12-7-6.
//
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@interface UIHelperAlert : NSObject
/**
  jugement String length
 **/
+(BOOL) isEmptyString:(NSString *)string;
/**
 show Alert amoment
 **/
+(void)ShowAlertMessage:(NSString *)title message:(NSString *)msg;

@end