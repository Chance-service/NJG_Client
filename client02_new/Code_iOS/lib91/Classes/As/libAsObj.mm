//
//  lib44755Obj.m
//  lib91
//
//  Created by GuoDong on 14-6-9.
//  Copyright (c) 2014年 youai. All rights reserved.
//

#import "libAsObj.h"
#import "libAs.h"
#import "SBJSON.h"
#import "NSObject+SBJSON.h"
#import "NSString+SBJSON.h"

#import <CommonCrypto/CommonDigest.h>
#define RequestTimeOut 4

#define BASE_URL @"https://pay.i4.cn/member_third.action"

@implementation libAsObj

-(void) SNSInitResult:(NSNotification *)notify
{
    self.isInGame = NO;
    self.isReLogin = NO;
    [self registerNotification];
    //std::string outstr = "";
    //    libPlatformManager::getPlatform()->_boardcastUpdateCheckDone(true,outstr);
}

-(void) registerNotification
{
    CGRect rect = [UIScreen mainScreen].applicationFrame; //获取屏幕大小
    waitView = [[UIActivityIndicatorView alloc] initWithFrame:rect];//定义图标大小，此处为32x32
    [waitView setCenter:CGPointMake(rect.size.width/2,rect.size.height/2)];//根据屏幕大小获取中心点
    [waitView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];//设置图标风格，采用灰色的，其他还有白色设置
    [waitView setBackgroundColor:[ UIColor colorWithWhite: 0.0 alpha: 0.5 ]];
    //[self.view addSubview:waitView];//添加该waitView
    if ([[UIDevice currentDevice] systemVersion].floatValue<=4.4) {
        [waitView setBounds:CGRectMake(0, 0, 50, 50)];
    }
    [[[UIApplication sharedApplication] keyWindow] addSubview:waitView];
}

-(void) unregisterNotification
{
    
}


#pragma mark
#pragma mark ----------------------------------- login call back ----------------------------------------

- (void)PlatformLogout:(NSNotification *)notify
{
    self.userID = nil;
    self.userName = nil;
    if(self.isReLogin && self.isInGame)
    {
        self.isInGame = NO;
        libPlatformManager::getPlatform()->_boardcastPlatfromReLogin();
    }
    else
    {
        self.isInGame = NO;
        libPlatformManager::getPlatform()->_boardcastPlatformLogout();
    }
}

- (void)SNSLoginResult:(NSNotification *)notify
{
	
}

#pragma mark
#pragma mark ----------------------------------- pay call back ----------------------------------------


-(void)NdUniPayAysnResult:(NSNotification*)notify
{
    
}



#pragma mark
#pragma mark ----------------------------------- AsPlatformSDKDelegate ----------------------------------
//-SDK 1.5.2 - 新增的支付宝app支付的结果回调
/**
 * @brief   支付宝app的支付结果回调
 * @param   INPUT   statusCode       接口返回的结果编码
 * 9000     订单支付成功
 * 8000     正在处理
 * 4000     订单支付失败
 * 6001     用户中途取消
 * 6002     网络连接出错
 * @return  无返回
 */
- (void)asAlixPayResultCallBack:(int)statusCode
{
    
}

//-SDK 1.5.2 - 新增的银联sdk支付的结果回调
/**
 * @brief   银联sdk的支付结果回调
 * @param   INPUT   result       接口返回的结果
 * success  支付成功
 * fail     支付失败
 * cancel   用户取消支付。
 * @return  无返回
 */
- (void)asUPPayPluginResultCallBack:(NSString *)result
{
    
}

//-SDK 1.4.1 - 新增的关闭用户中心回调
/**
 * @brief   关闭用户中心的回调
 * @param   INPUT   paramCenterViewCode       接口返回的结果编码
 * @return  无返回
 */

- (void)asClosedCenterViewCallBack
{
    
}

/**
 * @brief   余额大于所购买道具
 * @param   INPUT   paramAsPayResultCode       接口返回的结果编码
 * @return  无返回
 */
- (void)asPayResultCallBack:(AsPayResultCode)paramPayResultCode
{
    if(paramPayResultCode == AsPayResultCodeSucceed)
    {
        libAs* plat = dynamic_cast<libAs*>(libPlatformManager::getPlatform());
        if(plat)
        {
            BUYINFO info = plat->getBuyInfo();
            std::string log("购买成功");
            libPlatformManager::getPlatform()->_boardcastBuyinfoSent(true, info, log);
        }
    }
}

/**
 * @brief   验证更新成功后
 * @noti    分别在非强制更新点击取消更新和暂无更新时触发回调用于通知弹出登录界面
 * @return  无返回
 */
- (void)asVerifyingUpdatePassCallBack
{
    
}

/**
 * @brief   登录成功回调
 * @param   INPUT   paramToken       字符串token
 * @return  无返回
 */
- (void)asLoginCallBack:(NSString *)paramToken
{
    [self userLoginWithserviceTokenKey:paramToken];
}

/**
 * @brief   关闭Web页面后的回调
 * @param   INPUT   paramWebViewCode    接口返回的页面编码
 * @return  无返回
 */
- (void)asCloseWebViewCallBack:(AsWebViewCode)paramWebViewCode
{
    
}

/**
 * @brief   关闭SDK客户端页面后的回调
 * @param   INPUT   paramAsPageCode       接口返回的页面编码
 * @return  无返回
 */
- (void)asClosePageViewCallBack:(AsPageCode)paramPPPageCode
{
    
}

/**
 * @brief   注销后的回调
 * @return  无返回
 */
- (void)asLogOffCallBack
{
    [self PlatformLogout:0];
}

#pragma mark
#pragma mark ----------------------------------------- token 验证 ---------------------------------------------

-(void)userLoginWithserviceTokenKey:(NSString *)tokenKey
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //        NSString *postStr = [self buildData:data];
        NSMutableString* actionUrl = [NSMutableString stringWithString:BASE_URL];
     //   NSString *sign = [self md5sign:[NSString stringWithFormat:@"16976d3257423c6310fc662e98a7598a%@",tokenKey]];
        [actionUrl appendString:[NSString stringWithFormat:@"?token=%@",tokenKey]];
        NSString *retValue = [self httpPost:actionUrl postData:tokenKey md5check:nil];
        NSLog(@"token back %@",retValue);
        dispatch_async(dispatch_get_main_queue(), ^{
            id repr = retValue.JSONValue;
            if (repr)
            {
                NSDictionary *dic = repr;
                NSLog(@"%@",dic);
                self.userID = [NSString stringWithFormat:@"%@",[dic objectForKey:@"userid"] ];
                self.userName =  [dic objectForKey:@"username"];
                libPlatformManager::getPlatform()->_boardcastLoginResult(true, "");
            }
            else
            {
                NSLog(@"解析失败");
            }
        });
    });
}

- (NSString *) md5sign:(NSString *) data
{
    const char *original_str = [data UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}

-(NSString*) httpPost: (NSString*) actionUrl postData:(NSString *)postStr md5check:(NSString*) check
{
    return [self httpRequest:actionUrl postData:postStr md5check:check method:@"GET"];
}

-(NSString*) httpRequest: (NSString*) actionUrl postData:(NSString *)postStr md5check:(NSString*) check method:(NSString*) method
{
    NSURL *url=[NSURL URLWithString:actionUrl];//把相关的网络请求的接口存放到url里
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:url];//
    NSMutableData *mutabledata = [[NSMutableData alloc] init];
    NSURLResponse *response;
    NSError *err;
    [mutabledata appendData:[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err]];//同步请求连接服务器，并且告诉服务器，请求的内容是什么，把同步方法返回的NSData加到刚刚创建的可变数组mutabledata中
    NSString *datastr=[[[NSString alloc]initWithData:mutabledata encoding:NSUTF8StringEncoding] autorelease];//data数据转换成string类型
    [request release];
    [mutabledata release];
    NSLog(@"token datastr %@",datastr);
    return datastr;
}

@end
