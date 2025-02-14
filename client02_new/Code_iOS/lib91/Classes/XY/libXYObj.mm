//
//  lib44755Obj.m
//  lib91
//
//  Created by GuoDong on 14-6-9.
//  Copyright (c) 2014年 youai. All rights reserved.
//

#import "libXYObj.h"
#import "libXY.h"



@implementation libXYObj
@synthesize isLogin;
-(void) SNSInitResult:(NSNotification *)notify
{
    [self registerNotification];
    self.isLogin = NO;
    self.isInGame = NO;
    self.isReLogin = NO;
}

-(void) registerNotification
{
    [self addSDKObserver];
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

-(void)addSDKObserver
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(SNSInitFinish:)
                                                 name:kXYPlatformInitDidFinishedNotification
                                               object:nil];

    /*登录通知*/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(SNSLoginResult:)
                                                 name:kXYPlatformLoginNotification
                                               object:nil];

    /* 注销登录通知 */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(PlatformLogout:)
                                                 name:kXYPlatformLogoutNotification
                                               object:nil];
}

-(void) unregisterNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kXYPlatformInitDidFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kXYPlatformLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kXYPlatformLogoutNotification object:nil];
}

#pragma mark
#pragma mark ----------------------------------- login call back ----------------------------------------
-(void) SNSInitFinish:(NSNotification*)notify
{
    libPlatformManager::getPlatform()->_boardcastUpdateCheckDone(true,"");
}


- (void)SNSLoginResult:(NSNotification*)notification
{
    // 登录完成, 提供token 以及 openuid 给游戏校验
    NSDictionary *userInfo = notification.userInfo;
    if ([userInfo[kXYPlatformErrorKey] intValue] == XY_PLATFORM_NO_ERROR) {
        self.isLogin = YES;
         libPlatformManager::getPlatform()->_boardcastLoginResult(true, "");
    }
    [[XYPlatform defaultPlatform]XYShowToolBar:XYToolBarAtTopRight isUseOldPlace:NO];
}

- (void)PlatformLogout:(NSNotification*)notification
{
    self.isLogin = NO;
    if(self.isReLogin && self.isInGame)
    {
        self.isInGame = false;
        libPlatformManager::getPlatform()->_boardcastPlatfromReLogin();
    }
    else
    {
        self.isInGame = false;
        libPlatformManager::getPlatform()->_boardcastPlatformLogout();
    }
}

#pragma mark
#pragma mark ----------------------------------- pay call back ----------------------------------------
//支付
-(void) NdUniPayAysnResult:(NSNotification *)notify
{
    
//    NSDictionary *dict = notify.userInfo;
//    NSNumber *codeNum = [dict objectForKey:@"code"];
//    if(codeNum)
//    {
//        int code = [codeNum intValue];
//        if(code == 0)
//        {
            libXY* plat = dynamic_cast<libXY*>(libPlatformManager::getPlatform());
            if(plat)
            {
                BUYINFO info = plat->getBuyInfo();
                std::string log("购买成功");
                libPlatformManager::getPlatform()->_boardcastBuyinfoSent(true, info, log);
            }
//        }
//
//    }
}

#pragma mark
#pragma mark ----------------------------------- XYPayDelegate  ----------------------------------------

/**
 * @brief 支付成功
 * 该方法在用户完成充值过程， 在充值成功界面点击“确定”时回调，该界面会显示"充值成功，返回游戏，自动发放道具...."
 */
- (void) XYPaySuccessWithOrder:(NSString *) orderId
{
    [self NdUniPayAysnResult:0];
}

/**
 * @brief 支付失败
 *  该方法在用户完成充值过程，充值失败界面点击“确定”时回调，该界面会显示“充值失败，请返回游戏重试或者联系客服”
 *  支付失败可能是 1、用户支付问题 2、支付成功，但回调游戏方服务器问题
 */
- (void) XYPayFailedWithOrder:(NSString *) orderId
{
    
}

/**
 * @brief 用户点击充值界面右上角叉叉取消充值
 * 注： 1、orderId若为空，则说明用户在选择“充值方式”界面上未点击“确认”进行下一步支付，用户取消点击右上角取消按钮取消支付
 *     2、orderId若不为空，则说明已生成订单号，用户在支付过程中点击界面右上角叉叉取消
 *     3、该回调不能说明充值成功或失败，若orderId不为空，用户可能会在支付宝支付完毕回调到商户的时间内点击界面右上角叉叉取消
 *        开发者应在该回调中调用sdk查询订单接口或者请求游戏服务端获取该笔订单是否成功
 */
- (void) XYPayDidCancelByUser:(NSString *)orderId
{
    
}


@end
