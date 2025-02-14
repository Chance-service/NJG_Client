//
//  ViewController.m
//  test3
//
//  Created by fish on 13-8-21.
//  Copyright (c) 2013年 com4loves. All rights reserved.
//

#import "RegisterView.h"
#import "comHuTuoSDK.h"
#import "JSON.h"
#import "SDKUtility.h"
#import "ServerLogic.h"
#import <regex.h>

@interface RegisterView ()
@property (nonatomic) RegisterViewStyle viewStyle;
@property (retain, nonatomic) IBOutlet UILabel *lableTitle;
@property (retain, nonatomic) IBOutlet UILabel *lableNotice;
@property (retain, nonatomic) IBOutlet UILabel *lableAccount;
@property (retain, nonatomic) IBOutlet UILabel *lablePassword;
@property (retain, nonatomic) IBOutlet UILabel *lableEmail;
@property (retain, nonatomic) IBOutlet UILabel *viewLabelTitle;
@property (retain, nonatomic) IBOutlet UIButton *btnComplete;

@end
@implementation RegisterView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"com4lovesBundle" ofType:@"bundle"]];
        NSString *alertImagePath = [bundle pathForResource:@"background" ofType:@"png"];
        self.agreeImagePath = [bundle pathForResource:@"cb_glossy_on" ofType:@"png"];
        self.disAgreeImagePath = [bundle pathForResource:@"cb_glossy_off" ofType:@"png"];
        UIImage* backImage =  [UIImage imageWithContentsOfFile:alertImagePath];
        self.view.backgroundColor = [UIColor colorWithPatternImage:backImage];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.bSelected = YES;
    [self.view setFrame:CGRectMake(0,0,320,240)];
    [self.btnBack setTitle:[comHuTuoSDK getLang:@"back"] forState:UIControlStateNormal];
    [self.btnBack setTitle:[comHuTuoSDK getLang:@"back"] forState:UIControlStateSelected];
    [self.btnBack setTitle:[comHuTuoSDK getLang:@"back"] forState:UIControlStateHighlighted];
    
    [self.btnComplete setTitle:[comHuTuoSDK getLang:@"finish"] forState:UIControlStateNormal];
    [self.btnComplete setTitle:[comHuTuoSDK getLang:@"finish"] forState:UIControlStateSelected];
    [self.btnComplete setTitle:[comHuTuoSDK getLang:@"finish"] forState:UIControlStateHighlighted];
    [self.btnComplete setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [self.viewLabelTitle setText:[comHuTuoSDK getLang:@"viewtitle"]];
    [self.lableTitle setText:[comHuTuoSDK getLang:@"registerview_register"]];
    [self.lableAccount setText:[comHuTuoSDK getLang:@"registerview_account"]];
    [self.lableEmail setText:[comHuTuoSDK getLang:@"registerview_email"]];
    [self.lableNotice setText:[comHuTuoSDK getLang:@"registerview_notice"]];
    [self.lablePassword setText:[comHuTuoSDK getLang:@"registerview_password"]];
    [self.emailTextField setText:[comHuTuoSDK getLang:@"registerview_email_cint"]];
    UIImage* backImage =  [UIImage imageWithContentsOfFile:self.agreeImagePath];
    self.selectImageView.image = backImage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)selectUserAgreement:(id)sender {
    UIImage* backImage;
    if(self.bSelected)
    {
        backImage =  [UIImage imageWithContentsOfFile:self.disAgreeImagePath];
        self.button.enabled = NO;
        self.bSelected = NO;
    }
    else
    {
        backImage =  [UIImage imageWithContentsOfFile:self.agreeImagePath];
        self.button.enabled = YES;
        self.bSelected = YES;
    }
    if(backImage)
         self.selectImageView.image = backImage;
}

- (IBAction)gotoUserAgreement:(id)sender {
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http:///Agreement.html"]];

}

- (IBAction)gobackLogin:(id)sender {
    switch (self.viewStyle) {
        case stylePositive:
            [[comHuTuoSDK sharedInstance] hideAll];
            break;
        case styleRegister:
            [[comHuTuoSDK sharedInstance] showLogin];
            break;
        case sytleBingding:
            [[comHuTuoSDK sharedInstance] showLogin];
            break;
    }
}

-(void) clickResp
{
    if([[SDKUtility sharedInstance] checkInput:self.plainTextField.text password:self.secretTextField.text email:self.emailTextField.text])
    {
        switch (self.viewStyle) {
            case stylePositive:
                if ([[ServerLogic sharedInstance] changeTryUser2OkUserWithName:self.plainTextField.text password:self.secretTextField.text andEmail:self.emailTextField.text]==YES)
//                if([[ServerLogic sharedInstance] create:self.plainTextField.text password:self.secretTextField.text email:self.emailTextField.text] == YES)
                {
                    [[comHuTuoSDK sharedInstance] hideAll];
                    [[SDKUtility sharedInstance] showAlertMessage:[comHuTuoSDK getLang:@"notice_bindingok"]];
                    [[comHuTuoSDK sharedInstance] tryUser2SucessNotify];
                }
                break;
            case styleRegister:
                if([[ServerLogic sharedInstance] create:self.plainTextField.text password:self.secretTextField.text email:self.emailTextField.text] == YES)
                {
                    [[comHuTuoSDK sharedInstance] hideAll];
                }
                break;
            case sytleBingding:

                break;
        }  
    }
   
    [[SDKUtility sharedInstance] setWaiting:NO];
}

#warning  轮询检测改为事件会掉
- (IBAction)click:(id)sender {

    [[SDKUtility sharedInstance] setWaiting:YES];

    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(clickResp) userInfo:nil repeats:NO] ;
    
}

- (IBAction)didEnd:(id)sender {
    [sender resignFirstResponder];
    
    [[SDKUtility sharedInstance] checkInput:self.plainTextField.text password:self.secretTextField.text email:self.emailTextField.text];
    
}

- (IBAction)initEmail:(id)sender {
    [self.emailTextField setText:@""];
}

- (void) initWithViewStyle:(RegisterViewStyle)style
{
    self.button.enabled = YES;
    self.bSelected = YES;
    UIImage* backImage =  [UIImage imageWithContentsOfFile:self.agreeImagePath];
    self.selectImageView.image = backImage;
    [self.emailTextField setText:[comHuTuoSDK getLang:@"registerview_email_cint"]];
    self.plainTextField.text = @"";
    self.secretTextField.text = @"";
    [self.btnBack setTitle:[comHuTuoSDK getLang:@"back"] forState:UIControlStateNormal];
    [self.btnBack setTitle:[comHuTuoSDK getLang:@"back"] forState:UIControlStateSelected];
    self.viewStyle = style;
    YALog(@"style %d",style);
    switch (style) {
        case stylePositive:
            [self.viewTitle setText:[comHuTuoSDK getLang:@"register_bind"]];
            [self.btnBack setHidden:NO];
            [self.btnBack setTitle:[comHuTuoSDK getLang:@"close"]  forState:UIControlStateNormal];
            [self.btnBack setTitle:[comHuTuoSDK getLang:@"close"]  forState:UIControlStateSelected];
            break;
        case styleRegister:
            [self.viewTitle setText:[comHuTuoSDK getLang:@"register"]];
            [self.btnBack setHidden:NO];

            break;
        case sytleBingding:
            [self.viewTitle setText:[comHuTuoSDK getLang:@"binding"]];
            [self.btnBack setHidden:NO];
            break;
    }
}
- (void)dealloc {
    [_viewTitle release];
    [_btnBack release];
    [_lableTitle release];
    [_lableNotice release];
    [_lableAccount release];
    [_lablePassword release];
    [_lableEmail release];
    [_btnComplete release];
    [_viewLabelTitle release];
    [_selectImageView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setViewTitle:nil];
    [self setLableTitle:nil];
    [self setLableNotice:nil];
    [self setLableAccount:nil];
    [self setLablePassword:nil];
    [self setLableEmail:nil];
    [self setBtnBack:nil];
    [self setBtnComplete:nil];
    [self setViewLabelTitle:nil];
    [self setSelectImageView:nil];
    [super viewDidUnload];
}
@end
