//
//  EFUN_IAP_SDK.h
//  SourceCode
//
//  Created by zhangguangyang on 11/8/13.
//  Copyright (c) 2013 zhangguangyang. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 用来监听购买成功或者失败的广播name。
 */
#define EFUN_PHCHASE_SUCCESS @"EFUNPHCHASESUCCESSFUL"//购买商品成功
#define EFUN_PHCHASE_FAIL @"EFUNPHCHASEFAIL"//购买商品失败

//----------------MT游戏相关---------------------------//
//我叫MT  发放游戏比成功时  返回给 厂商 的字典里的元素所对应的key值

#define EFUN_PlayID_KEY @"EFUNPLAYERIDKEY"//对在购买商品成功或失败的通知中的userInfo使用该键返回playerID值（成功通知中为服务器返回值，失败通知中为原本参数）
#define EFUN_ProductID_KEY @"EFUNPRODUCTIDKEY"//对在购买商品成功或失败的通知中的userInfo使用该键返回productID
#define EFUN_ReturnCode_KEY @"EFUNRETURNCODEKEY"//对在购买商品成功的通知中的userInfo使用该键返回状态码（区别补单还是购买）
#define EFUN_EFUNOrderID_KEY @"EFUNORDERIDKEY"//对在购买商品成功的通知中的userInfo使用该键返回efunOrderID（efun订单号）
//---------------------------------------------------//
@interface EFUN_IAP_SDK : NSObject

/*
 初始化购买功能。用户登陆进游戏服务器的时候调用。
 */
+(void)start;

/*
 获取商品信息列表。
 */
+(NSArray *)getProductsInfo;

/*
 通过 商品ID 执行购买商品操作，需要传递用户购买的商品的ID，和用户的相关信息。用户点击某个商品的“购买”按钮的时候调用。
 */
+(void)userDidClickBuyBtnWithProductID:(NSString *)aWantBuyProductID
                             andUserID:(NSString *)aUserID
                           andPlayerID:(NSString *)aPlayerID
                         andServerCode:(NSString *)aServerCode
                                remark:(NSString *)aRemark
                                aLevel:(NSString *)alevel
                                 aRole:(NSString *)aRole;

@end
