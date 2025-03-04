//
//  AccountCenterView.m
//  com4lovesSDK
//
//  Created by fish on 13-8-28.
//  Copyright (c) 2013年 com4loves. All rights reserved.
//

#import "AccountCenterView.h"
#import "comHuTuoSDK.h"

@interface AccountCenterView ()
@property (retain, nonatomic) IBOutlet UILabel *lableTitle;
@property (retain, nonatomic) IBOutlet UILabel *lablePassword;
@property (retain, nonatomic) IBOutlet UILabel *lableAccount;

@property (retain, nonatomic) IBOutlet UIButton *btnBack;

@end

@implementation AccountCenterView

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
    
    [self.lableTitle setText:[comHuTuoSDK getLang:@"accountcenter_title"]];
    [self.lableAccount setText:[comHuTuoSDK getLang:@"accountcenter_account"]];
    [self.lablePassword setText:[comHuTuoSDK getLang:@"accountcenter_change_password"]];
    
    [self.btnBack setTitle:[comHuTuoSDK getLang:@"back"] forState:UIControlStateNormal];
    [self.btnBack setTitle:[comHuTuoSDK getLang:@"back"] forState:UIControlStateSelected];
    [self.btnBack setTitle:[comHuTuoSDK getLang:@"back"] forState:UIControlStateHighlighted];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goBack:(id)sender {
        [[comHuTuoSDK sharedInstance] showAccountManager];
}

- (IBAction)changePassword:(id)sender {
        [[comHuTuoSDK sharedInstance] showChangePassword];
}
- (void)dealloc {
    [_lableTitle release];
    [_lablePassword release];
    [_lableAccount release];
    [_btnBack release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setLableTitle:nil];
    [self setLablePassword:nil];
    [self setLableAccount:nil];
    [self setBtnBack:nil];
    [super viewDidUnload];
}
@end
