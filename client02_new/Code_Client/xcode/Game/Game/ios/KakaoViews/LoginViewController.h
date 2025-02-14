//
//  LoginViewController.h
//  LoginViewController
//
//  Created by fanleesong on 2015. 3. 15..
//  Copyright (c) 2015年 com4loves. All rights reserved.
//
#import <UIKit/UIKit.h>

#define ENTERMATELOGINNOTIFACATION @"ENTERMATELOGINNOTIFACATION"
#define ENTERMATESHOWLOGINVIEW @"ENTERMATESHOWLOGINVIEW"

@protocol AuthLoginViewControllerDelegate;

@interface LoginViewController : UIViewController<UIAlertViewDelegate> {
@private
    id<AuthLoginViewControllerDelegate> __unsafe_unretained _delegate;
    BOOL bProgressLogin;
}
@property (nonatomic, unsafe_unretained) id<AuthLoginViewControllerDelegate> delegate;
@property(nonatomic, retain) IBOutlet UIButton *btnLogin;
@property(nonatomic, retain) IBOutlet UIButton* btnCheck;
@property (retain, nonatomic) IBOutlet UIButton *BtnGuestLogin;
@property (retain, nonatomic) IBOutlet UIImageView *bgImageView;
@property (retain, nonatomic) IBOutlet UIButton *btnAjust;

@end


@protocol AuthLoginViewControllerDelegate <NSObject>
//@required
@optional
- (void)authLoginViewControllerdidFinishLogin:(LoginViewController *)LoginViewController;
@end