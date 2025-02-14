//
//  GNetopSBankSharedManager.h
//  lib91
//
//  Created by fanleesong on 15/3/12.
//  Copyright (c) 2015年 youai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface GNetopSBankSharedManager : NSObject

+ (instancetype) shareSBankManager;
/**
 * ---------prama-----
 --------------required--------------
 * @orderId         订单号 (订单号，不可重复，测试时可以每次加1，推荐纯数字)
 * @customId        客户ID
 * @productId       产品ID
 * @productName     产品名 (目前只支持英文)
 * @taxMoney        税额
 * @amount          购买金额(信用卡支付测试用2日币以上。 其他的支付手段用1日币测试)
 * @payRequestDate  购买日期 (请求时间，必须保持和SBPayment服务器相差不超过60秒， ※正式使用时需要游戏中自行取得日本标准时间 格式：20141105174600)
 --------------optional--------------
 * @serverCode      服务器ID  <可选>
 * @roleId          角色ID    <可选>
 * @currencyType    币种 (人民币、美元等...)
 @ @payMethod       付款方式  (Credit3d,信用卡、银行卡等，空白为多种)
 * @payModel        模式设定类型   0:测试   1:正式
 **/
-(void)showSBPaymentViewBuyForOrderId:(NSString *) orderId
                              customId:(NSString *) customId
                             productId:(NSString *) productId
                           productName:(NSString *) productName
                              taxMoney:(NSString *) taxMoney
                                amount:(NSString *) amount
                        payRequestDate:(int) payRequestDate
                            serverCode:(NSString *) serverCode
                                roleId:(NSString *) roleId
                          currencyType:(NSString *) currencyType
                             payMethod:(NSString *) payMethod
                          payTestModel:(int) payModel;

@end
