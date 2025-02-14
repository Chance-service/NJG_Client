//
//  cpupdate.h
//  cpupdate
//
//  Created by rong on 14-7-25.
//  Copyright (c) 2014年 rong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface HmcpUpdate : NSObject<UIAlertViewDelegate>

+ (HmcpUpdate *)sharedUpdate;

/**
 *	@brief	通过海马服务器检查更新
 *
 *	@param 	force 	是否强制更新(默认为NO)  如果不再支持旧版本用户，请设置该字段为YES。
 *	@param 	test 	是否是debug模式。 Debug模式下，若海马服务器中有该应用，则不论版本号，肯定提示更新；若海马服务器中没有该应用，则需要CP将安装包提供到海马服务器，并提示"马技术人员将会协助进行进一步的更新测试"。
 *
 */
- (void)checkUpdateForce:(BOOL)force Test:(BOOL)test;

@end
