//
//  ViewController.m
//  test3
//
//  Created by fish on 13-8-21.
//  Copyright (c) 2013年 com4loves. All rights reserved.
//

#import "LoginView.h"
#import "comHuTuoSDK.h"
#import "JSON.h"
#import "InAppPurchaseManager.h"
#import "SDKUtility.h"
#import "ServerLogic.h"

@interface LoginView ()<UIAlertViewDelegate>
@property (retain, nonatomic) IBOutlet UILabel *lableTitle;
@property (retain, nonatomic) IBOutlet UILabel *lableAccount;
@property (retain, nonatomic) IBOutlet UILabel *label_password;
@property (retain, nonatomic) IBOutlet UILabel *lableViewTitle;
@property (retain, nonatomic) IBOutlet UILabel *lableForgetPassword;

@property (retain, nonatomic) IBOutlet UIButton *lableFindPassword;
@property (retain, nonatomic) IBOutlet UIButton *btnLogin;
@property (retain, nonatomic) IBOutlet UIButton *closeBtn;

@end

@implementation LoginView
@synthesize button;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"com4lovesBundle" ofType:@"bundle"]];
        NSString *alertImagePath = [bundle pathForResource:@"background" ofType:@"png"];
        UIImage* backImage =  [UIImage imageWithContentsOfFile:alertImagePath];
        self.view.backgroundColor = [UIColor colorWithPatternImage:backImage];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view setFrame:CGRectMake(0,0,320,240)];
    [self.lableViewTitle setText:[comHuTuoSDK getLang:@"viewtitle"]];
    [self.label_password setText:[comHuTuoSDK getLang:@"loginview_password"]];
    [self.lableAccount setText:[comHuTuoSDK getLang:@"loginview_account"]];
    [self.lableTitle setText:[comHuTuoSDK getLang:@"loginview_login"]];
    [self.lableForgetPassword setText:[comHuTuoSDK getLang:@"loginview_forget_password"]];

    [self.lableFindPassword setTitle:[comHuTuoSDK getLang:@"loginview_find_password"] forState:UIControlStateNormal];
    [self.lableFindPassword setTitle:[comHuTuoSDK getLang:@"loginview_find_password"] forState:UIControlStateSelected];
    [self.lableFindPassword setTitle:[comHuTuoSDK getLang:@"loginview_find_password"] forState:UIControlStateHighlighted];
    
    [self.btnRegister setTitle:[comHuTuoSDK getLang:@"register"] forState:UIControlStateNormal];
    [self.btnRegister setTitle:[comHuTuoSDK getLang:@"register"] forState:UIControlStateSelected];
    [self.btnRegister setTitle:[comHuTuoSDK getLang:@"register"] forState:UIControlStateHighlighted];
    
    [self.btnLogin setTitle:[comHuTuoSDK getLang:@"loginview_login"] forState:UIControlStateNormal];
    [self.btnLogin setTitle:[comHuTuoSDK getLang:@"loginview_login"] forState:UIControlStateSelected];
    [self.btnLogin setTitle:[comHuTuoSDK getLang:@"loginview_login"] forState:UIControlStateHighlighted];
    
    [self.closeBtn setTitle:[comHuTuoSDK getLang:@"close"] forState:UIControlStateNormal];
    [self.closeBtn setTitle:[comHuTuoSDK getLang:@"close"] forState:UIControlStateSelected];
    [self.closeBtn setTitle:[comHuTuoSDK getLang:@"close"] forState:UIControlStateHighlighted];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) gotoRegisterResp
{
    //一秒注册代码在这里
//    if([[ServerLogic sharedInstance] preCreate]==YES)
//    {
        [[comHuTuoSDK sharedInstance] showRegister];
//    }
    [[SDKUtility sharedInstance] setWaiting:NO];
}
- (IBAction)gotoRegister:(id)sender {
    NSString *tryUser = [[ServerLogic sharedInstance] getTryUser];
    NSString *UserID = [[ServerLogic sharedInstance]getHuTuoID];
    if (tryUser!=nil && UserID != nil)
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您的试玩账号尚未绑定，是否进行绑定" delegate:self cancelButtonTitle:@"不绑定" otherButtonTitles:@"绑定", nil];
        [alertView setTag:100];
        [alertView show];
        [alertView release];
    }
    else
    {
        [[SDKUtility sharedInstance] setWaiting:YES];
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(gotoRegisterResp) userInfo:nil repeats:NO];
    }
}

- (IBAction)onEditChange:(id)sender {
    if (0 == self.plainTextField.text.length) {
        [self.btnArrow setHidden:NO];
        [self.btnNameDel setHidden:YES];
    } else{
        [self.btnArrow setHidden:YES];
        [self.btnNameDel setHidden:NO];
    }
    
}
- (IBAction)onPasswordChange:(id)sender {
    if (0 == self.secretTextField.text.length) {
        [self.btnPsdDel setHidden:YES];
    } else{
        [self.btnPsdDel setHidden:NO];
    }
}
- (IBAction)onNameDelClick:(id)sender {
    [self.plainTextField setText:@""];
    [self.btnArrow setHidden:NO];
    [self.btnNameDel setHidden:YES];
}
- (IBAction)onPsdDelClick:(id)sender {
    [self.secretTextField setText:@""];
    [self.btnPsdDel setHidden:YES];

}

-(void) clickResp
{
    if([[ServerLogic sharedInstance] login:self.plainTextField.text password:self.secretTextField.text] == YES)
    {
        [[comHuTuoSDK sharedInstance] hideAll];
    }
    [[SDKUtility sharedInstance] setWaiting:NO];
}
- (IBAction)click:(id)sender {
    
    if([[SDKUtility sharedInstance] checkInput:self.plainTextField.text password:self.secretTextField.text email:nil] ==NO)
        return;

    [[SDKUtility sharedInstance] setWaiting:YES];
    
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(clickResp) userInfo:nil repeats:NO] ;

}

- (IBAction)didEnd:(id)sender {
    [sender resignFirstResponder];
    [[SDKUtility sharedInstance] checkInput:self.plainTextField.text password:self.secretTextField.text email:nil];
}

- (IBAction)forgetPassword:(id)sender {
    //[[com4lovesSDK sharedInstance] showWeb:@"http://jsp/public/help"];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"找回密码请联系我们的客服：\n忘记密码" message:@"1号客服QQ：384652357\n2号客服QQ：3032141679\n3号客服QQ：315492199" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
    [alert release];
}

- (IBAction)showUserList:(id)sender {
    [[comHuTuoSDK sharedInstance] showUserList];
    [sender resignFirstResponder];
    [_secretTextField resignFirstResponder];
    [_plainTextField resignFirstResponder];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [[SDKUtility sharedInstance] setWaiting:YES];
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(gotoRegisterResp) userInfo:nil repeats:NO];
    }
    else if(buttonIndex == 1)
    {
        [[comHuTuoSDK sharedInstance]showBinding];
    }
}

-(void)clearInfo
{
    [self.plainTextField setText:@""];
    [self.secretTextField setText:@""];
    [self.btnArrow setHidden:NO];
    [self.btnNameDel setHidden:YES];
    [self.btnArrow setHidden:NO];
    [self.btnNameDel setHidden:YES];
}


- (void)dealloc {
    [_btnRegister release];
    [_btnNameDel release];
    [_btnPsdDel release];
    [_btnArrow release];
    [_lableTitle release];
    [_closeBtn release];
    [_lableAccount release];
    [_label_password release];
    [_btnLogin release];
    [_lableViewTitle release];
    [_lableForgetPassword release];
    [_lableFindPassword release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setBtnRegister:nil];
    [self setBtnNameDel:nil];
    [self setBtnPsdDel:nil];
    [self setBtnArrow:nil];
    [self setLableTitle:nil];
    [self setCloseBtn:nil];
    [self setLableAccount:nil];
    [self setLabel_password:nil];
    [self setBtnRegister:nil];
    [self setBtnLogin:nil];
    [self setLableViewTitle:nil];
    [self setLableForgetPassword:nil];
    [self setLableFindPassword:nil];
    [super viewDidUnload];
}
- (void)initWithViewStyle:(LoginViewStyle)style
{
//    switch (style) {
//        case styleLogin:
//            [self.btnRegister setHidden:YES];
//            self.button.frame = CGRectMake(18, 262, 265, 44);
//            break;
//        case styleLoginWithRegister:
//            [self.btnRegister setHidden:NO];
//            self.button.frame = CGRectMake(158, 262, 125, 44);
//            break;
//    }
}
- (IBAction)onBack:(id)sender {
    [[comHuTuoSDK sharedInstance] hideAll];
}
@end
