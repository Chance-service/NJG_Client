//
//  LoginViewController.m
//  LoginViewController
//
//  Created by fanleesong on 2015. 3. 15..
//  Copyright (c) 2015年 com4loves. All rights reserved.
//

#import "LoginViewController.h"
#import <ILoveGameSDKFramework/ILoveGameSDK.h>
#include "libPlatform.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize delegate = _delegate;
@synthesize btnLogin, btnCheck;

BOOL checkBoxSelected = NO;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self) {
        // Custom initialization
        bProgressLogin = NO;
        
        UIImage * btnImageLogin = [UIImage imageNamed:@"kakaologin_up.png"];
        [btnLogin setImage:btnImageLogin forState:UIControlStateSelected];

    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    NSLog(@"%s",__FUNCTION__);
}

- (void)viewDidLoad
{
    

//    self.bgImageView = [[[UIImageView alloc] initWithFrame:[[UIApplication sharedApplication].keyWindow frame]] autorelease];
//    self.bgImageView.layer.frame = [[UIApplication sharedApplication].keyWindow frame];
//    [self.bgImageView.layer layoutSublayers];
//    [self.bgImageView.layer masksToBounds];
//    UIImage *image = [UIImage imageNamed:@"logo_login_kakaotalk.png"];
//    [image setAccessibilityFrame:[UIApplication sharedApplication].keyWindow.frame];
//    self.bgImageView.image = image;
//    [self.bgImageView setAccessibilityFrame:[UIApplication sharedApplication].keyWindow.frame];
//    [self.view addSubview:self.bgImageView];
//    [self.view sendSubviewToBack:self.bgImageView];
    
    
//    [self.bgImageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
//    [self.view autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    

    BOOL isVisibleGuest = [[ILoveGameSDK getInstance] isVisibleGuest];
    if (isVisibleGuest) {
        [self.BtnGuestLogin setHidden:NO];
    }else{
        [self.BtnGuestLogin setHidden:YES];
    }
    //测试时控制Guest按钮显示隐藏
//    [self.BtnGuestLogin setHidden:NO];
    
    [super viewDidLoad];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != (UIInterfaceOrientationPortrait|UIInterfaceOrientationPortraitUpsideDown));
}

- (IBAction)invokeCheckWithTarget:(id)sender {
    btnCheck.selected = !btnCheck.selected;
    
    if(btnCheck.selected == YES) {
        [btnCheck setImage:[UIImage imageNamed:@"bt_checkbox_on.png"]
                            forState:UIControlStateNormal];

    } else {
        [btnCheck setImage:[UIImage imageNamed:@"bt_checkbox.png"]
                            forState:UIControlStateNormal];
        
    }
}

- (IBAction)invokeAgreement:(id)sender {
    
    [[ILoveGameSDK getInstance] openAgreement:self];
}
// 游客登录
- (IBAction)invikeGuestWithTarget:(id)sender {
    
    NSLog(@"------%s----",__FUNCTION__);
//    [[ILoveGameSDK getInstance] showCoverView:self.view];
    [[ILoveGameSDK getInstance] guest:^(BOOL success, NSError *error) {
//        [[ILoveGameSDK getInstance] hideCoverView:self.view];
        if(success) {
            NSLog(@"Guest login......");
            [[NSUserDefaults standardUserDefaults] setValue:[[ILoveGameSDK getInstance] get_username] forKey:@"guestID"];
            //username
            NSLog(@"guestID---------%@",[[ILoveGameSDK getInstance] get_username]);
            NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:[[ILoveGameSDK getInstance] get_username],@"result",nil];
            //发送监听通知中心
            [[NSNotificationCenter defaultCenter] postNotificationName:ENTERMATELOGINNOTIFACATION object:nil userInfo:userDic];
            //登陆成功，获取服务器列表
            [[ILoveGameSDK getInstance] get_server_lists:^(BOOL success, NSError *error) {
                NSDictionary* info = error.userInfo;
                if(error.code == -1)
                {
                    NSLog(@"%@",info);
                }
                NSDictionary * serverlist = [info valueForKey:@"serverlist"];
                // 利用ServerList信息，进行必要的处理。
                NSLog(@"%s---%@",__FUNCTION__,info);
                NSLog(@"-----GuestLogin----serverlist----%@",serverlist);
                
                NSError *parseError = nil;
                if(serverlist != nil){
                    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:serverlist options:NSJSONWritingPrettyPrinted error:&parseError];
                    NSString *serverStrig = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    libPlatformManager::getPlatform()->sendMessageP2G("SERVERLIST",[serverStrig UTF8String]);
                }
                
            }];
            [[NSNotificationCenter defaultCenter] postNotificationName:ENTERMATESHOWLOGINVIEW object:nil userInfo:nil];
            //登陆成功后将该视图移除
//            if (_delegate && [_delegate respondsToSelector:@selector(authLoginViewControllerdidFinishLogin:)]) {
//                [_delegate authLoginViewControllerdidFinishLogin:self];
//            }
            
        } else {
            NSLog(@"%@",error);

            NSDictionary* detail = error.userInfo;

            int nResultCode = [[detail valueForKey:@"result"] intValue];
            NSString* nsMessage = [detail valueForKey:@"error"];

            if(nResultCode == 3000){
                [[ILoveGameSDK getInstance] Update:error];
            } else {
                UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"에러"
                                                                    message:nsMessage
                                                                   delegate:nil
                                                          cancelButtonTitle:@"확인"
                                                          otherButtonTitles:nil] autorelease];
                [alertView show];
            }

        }
    }];

    
    
}

// 不使用 Bind
- (IBAction)invokeBind:(id)sender {
    //    if( bProgressLogin == YES ) {
    //        [[ILoveGameSDK getInstance] logout:^(BOOL success, NSError *error) {
    //
    //        }];
    //    }
    //
    //    bProgressLogin = YES;
    /*
     NSString* strGuestID = [[NSUserDefaults standardUserDefaults] stringForKey:@"guestID"];
     
     if( strGuestID != nil || ![strGuestID isEqualToString:@""]) {
     
     [[ILoveGameSDK getInstance] login:^(BOOL success, NSError *error) {
     dispatch_async(dispatch_get_main_queue(), ^{
     
     if(success) {
     NSLog(@"error:%@",error);
     bProgressLogin = NO;
     NSLog(@"로그인 성공");
     
     [[ILoveGameSDK getInstance] bind:strGuestID response:^(BOOL success, NSError *error) {
     if(success == YES) {
     NSLog(@"Binding 성공");
     } else {
     NSLog(@"Binding 실패");
     }
     }];
     
     // DeviceToken Regist.
     [[ILoveGameSDK getInstance] sendRegistrationID:[(AppDelegate* )[[UIApplication sharedApplication] delegate] m_strDeviceToken]];
     
     [_delegate authLoginViewControllerdidFinishLogin:self];
     } else {
     NSLog(@"%@",error);
     
     bProgressLogin = NO;
     
     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"에러"
     message:error.localizedDescription
     delegate:nil
     cancelButtonTitle:@"확인"
     otherButtonTitles:nil];
     [alertView show];
     }
     
     });
     }];
     } else {
     [[ILoveGameSDK getInstance] login:^(BOOL success, NSError *error) {
     dispatch_async(dispatch_get_main_queue(), ^{
     
     if(success) {
     NSLog(@"error:%@",error);
     bProgressLogin = NO;
     NSLog(@"로그인 성공");
     
     // DeviceToken Regist.
     [[ILoveGameSDK getInstance] sendRegistrationID:[(AppDelegate* )[[UIApplication sharedApplication] delegate] m_strDeviceToken]];
     
     [_delegate authLoginViewControllerdidFinishLogin:self];
     } else {
     NSLog(@"%@",error);
     
     bProgressLogin = NO;
     
     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"에러"
     message:error.localizedDescription
     delegate:nil
     cancelButtonTitle:@"확인"
     otherButtonTitles:nil];
     [alertView show];
     }
     
     });
     }];
     }
     */
}

// 普通登录
- (IBAction)invokeLoginWithTarget:(id)sender
{
    
    if(btnCheck.selected == NO) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"약관 동의"
                                                            message:@"게임 이용약관에 동의해 주세요."
                                                           delegate:nil
                                                  cancelButtonTitle:@"확인"
                                                  otherButtonTitles:nil] autorelease];
        [alertView show];

        return;
    }
    
    if( bProgressLogin == YES ) {
        [[ILoveGameSDK getInstance] logout:^(BOOL success, NSError *error) {
            
        }];
    }
    
    bProgressLogin = YES;
    
//    [[ILoveGameSDK getInstance] showCoverView:self.view];
    [[ILoveGameSDK getInstance] login:^(BOOL success, NSError *error) {
//        [[ILoveGameSDK getInstance] hideCoverView:self.view];
        NSDictionary* details = error.userInfo;
        NSLog(@"%s-------details---------%@",__FUNCTION__,details);
        if(success && [[details valueForKey:@"result"] integerValue] == 1000) {
            NSLog(@"error:%@",error);
            bProgressLogin = NO;
            NSDictionary * serverlist = [details valueForKey:@"serverlist"];
            // 利用ServerList信息，进行必要的处理。
            NSLog(@"%s---%@",__FUNCTION__,details);
            NSLog(@"----NormalLogin----serverlist----%@",serverlist);
            
            NSError *parseError = nil;
            if(serverlist != nil){
                NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:serverlist options:NSJSONWritingPrettyPrinted error:&parseError];
                NSString *serverStrig = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                libPlatformManager::getPlatform()->sendMessageP2G("SERVERLIST",[serverStrig UTF8String]);
            }
            /*
             userinfo =     {
             "mb_adult" = 1;
             "mb_nick" = "\Ubc15\Ucca0\Ud6c8(\U6734\U54f2\U52cb)";
             "mb_nickname" = "\Ubc15\Ucca0\Ud6c8(\U6734\U54f2\U52cb)";
             "mb_profile_image" = "http://th-p.talk.kakao.co.kr/th/talkp/wkfnSKR1MH/IO6sNx8IXkgE5QLPCzLUiK/1taqug_110x110_c.jpg";
             "mb_sid" = 4106350;
             rules = N;
             };
             */
            NSLog(@"%s-------details---------%@",__FUNCTION__,details);
            NSString *username = [[ILoveGameSDK getInstance] get_username]; // 平台账号（游戏内用户唯一编号）
            NSString *userid = [[ILoveGameSDK getInstance]get_user_id]; // 这个是合作平台ID，千万不要用这个作为登录游戏的唯一账号，而应该用上面的username）
            NSLog(@"username--%@-----userId--%@",username,userid);
            // 登录成功，进入游戏
            NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:username,@"result", nil];
            NSLog(@"----NormalLogin----userDic----%@",userDic);
            //发送监听通知中心
            [[NSNotificationCenter defaultCenter] postNotificationName:ENTERMATELOGINNOTIFACATION object:nil userInfo:userDic];
            
            //登陆成功后，移除视图
            [[NSNotificationCenter defaultCenter] postNotificationName:ENTERMATESHOWLOGINVIEW object:nil userInfo:nil];
//            if (_delegate && [_delegate respondsToSelector:@selector(authLoginViewControllerdidFinishLogin:)]) {
//                [_delegate authLoginViewControllerdidFinishLogin:self];
//            }

        } else {

            NSDictionary* detail = error.userInfo;

            int nResultCode = [[detail valueForKey:@"result"] intValue];
            NSString* nsMessage = [detail valueForKey:@"error"];

            if(nResultCode == 3000){
                [[ILoveGameSDK getInstance] Update:error];
            } else {

                NSLog(@"%@",error);

                bProgressLogin = NO;

                UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"에러"
                                                            message:nsMessage
                                                            delegate:nil
                                                    cancelButtonTitle:@"확인"
                                                    otherButtonTitles:nil] autorelease];
                [alertView show];
            }
        }
    }];
}
- (void)dealloc {
    [self.BtnGuestLogin release],self.BtnGuestLogin = nil;
    [self.btnCheck release],self.btnCheck = nil;
    [self.btnLogin release],self.btnLogin = nil;
    [self.bgImageView release],self.bgImageView = nil;
    [self.btnAjust release],self.btnAjust = nil;
    [super dealloc];
}
- (void)viewDidUnload {
    [self setBtnGuestLogin:nil];
    [self setBtnCheck:nil];
    [self setBtnLogin:nil];
    [self setBgImageView:nil];
    [self setBtnAjust:nil];
    [super viewDidUnload];
}
@end
