//
//  ChangePasswordView.m
//  com4lovesSDK
//
//  Created by fish on 13-8-28.
//  Copyright (c) 2013年 com4loves. All rights reserved.
//

#import "ChangePasswordView.h"
#import "comHuTuoSDK.h"
#import "ServerLogic.h"
#import "SDKUtility.h"
@interface ChangePasswordView ()

@property (retain, nonatomic) IBOutlet UILabel *lableTitle;
@property (retain, nonatomic) IBOutlet UILabel *lableOldPsd;
@property (retain, nonatomic) IBOutlet UILabel *lableNewPsd;
@property (retain, nonatomic) IBOutlet UILabel *viewLableTitle;

@property (retain, nonatomic) IBOutlet UIButton *btnBack;
@property (retain, nonatomic) IBOutlet UIButton *btnComplete;


@end

@implementation ChangePasswordView

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
    
    [self.lableTitle setText:[comHuTuoSDK getLang:@"changepsd_title"]];
    [self.lableOldPsd setText:[comHuTuoSDK getLang:@"changepsd_oldpsd"]];
    [self.lableNewPsd setText:[comHuTuoSDK getLang:@"changepsd_newpsd"]];
    [self.viewLableTitle setText:[comHuTuoSDK getLang:@"viewtitle"]];

    [self.btnBack setTitle:[comHuTuoSDK getLang:@"back"] forState:UIControlStateNormal];
    [self.btnBack setTitle:[comHuTuoSDK getLang:@"back"] forState:UIControlStateSelected];
    [self.btnBack setTitle:[comHuTuoSDK getLang:@"back"] forState:UIControlStateHighlighted];
    
    [self.btnComplete setTitle:[comHuTuoSDK getLang:@"finish"] forState:UIControlStateNormal];
    [self.btnComplete setTitle:[comHuTuoSDK getLang:@"finish"] forState:UIControlStateSelected];
    [self.btnComplete setTitle:[comHuTuoSDK getLang:@"finish"] forState:UIControlStateHighlighted];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goBack:(id)sender {
    [[comHuTuoSDK sharedInstance] showAccountCenter];
}
-(void) changeDoneResp
{
    if([[SDKUtility sharedInstance] checkInput:[[ServerLogic sharedInstance] getLoginedUserName] password:self.newSecretText.text email:nil])
    {
        if([[ServerLogic sharedInstance] modify:self.newSecretText.text oldPassword:self.oriSecretText.text] == YES)
        {
            [[comHuTuoSDK sharedInstance] showAccountManager];
            [[SDKUtility sharedInstance] showAlertMessage:[comHuTuoSDK getLang:@"notice_modify_password_ok"]];
        }
    }
    [[SDKUtility sharedInstance] setWaiting:NO];
}
- (IBAction)changeDone:(id)sender {
    [[SDKUtility sharedInstance] setWaiting:YES];
    
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(changeDoneResp) userInfo:nil repeats:NO] ;
}

- (IBAction)initPasswordOri:(id)sender {
    [self.oriSecretText setText:@""];
}

- (IBAction)initPasswordNew:(id)sender {
    [self.newSecretText setText:@""];
}

- (IBAction)didEnd:(id)sender {
    [sender resignFirstResponder];
}
- (void)dealloc {
    [_lableTitle release];
    [_lableOldPsd release];
    [_lableNewPsd release];
    [_btnBack release];
    [_btnComplete release];
    [_viewLableTitle release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setLableTitle:nil];
    [self setLableOldPsd:nil];
    [self setLableNewPsd:nil];
    [self setBtnBack:nil];
    [self setBtnComplete:nil];
    [self setViewLableTitle:nil];
    [super viewDidUnload];
}
@end
