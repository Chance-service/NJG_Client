//
//  testAlertView.m
//  AlertViewAnimation
//
//  Created by GuoDong on 14-8-15.
//  Copyright (c) 2014年 steven. All rights reserved.
//

#import "InputView.h"
#import <QuartzCore/QuartzCore.h>

@interface InputView()

@property (nonatomic,retain)UIView *bgView;
@property (nonatomic,assign)int textViewHeight;
@property (nonatomic,assign)int buttonHeight;
@property (nonatomic,assign)CGRect frameRect;
@property (nonatomic,assign)BOOL bMutiline;
@end

@implementation InputView

- (id)initWithFrame:(CGRect)frame bMultiline:(BOOL)multiline
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code 19 27 60
        self.backgroundColor = [UIColor clearColor];
        self.bMutiline = multiline;
//        if(multiline)
//        {
            self.textViewHeight = 90;
//        }
//        else
//            self.textViewHeight = 40;
        self.buttonHeight = 25;
        CGRect rect;
        rect = CGRectMake(35,self.center.y, frame.size.width-70, self.textViewHeight+self.buttonHeight);

        UIView *backView = [[UIView alloc]init];
        backView.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.7];
        backView.frame = rect;
        backView.layer.cornerRadius = 7;
        backView.center = self.center;
        backView.clipsToBounds = YES;
        [self addSubview:backView];
        self.bgView = backView;
        [backView release];
        
        UITextView *TextView = [[UITextView alloc]init];
        TextView.frame = CGRectMake(3, 7, backView.frame.size.width-6, self.textViewHeight);
        TextView.layer.cornerRadius = 7;
        TextView.font = [UIFont systemFontOfSize:16];
        [backView addSubview:TextView];
        TextView.returnKeyType = UIReturnKeyDone;
        TextView.backgroundColor = [UIColor clearColor];
        TextView.delegate = self;
        //textView.showsHorizontalScrollIndicator = YES;
        [backView addSubview:TextView];
        self.textView = TextView;
        [TextView release];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, rect.size.height-25, rect.size.width, self.buttonHeight);
        button.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
        //button.layer.cornerRadius = 7;
        [button setTitle:@"OK" forState:UIControlStateNormal];
        button.titleLabel.textColor = [UIColor blackColor];
        [backView addSubview:button];
        [button addTarget:self action:@selector(buttonOK) forControlEvents:UIControlEventTouchUpInside];
        
        [self registerForKeyboardNotifications];
        [self.textView becomeFirstResponder];
    }
    return self;
}

- (void)registerForKeyboardNotifications
{
    //使用NSNotificationCenter 鍵盤出現時
//  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
//   //使用NSNotificationCenter 鍵盤隐藏時
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHidden:) name:UIKeyboardDidHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
}

-(void)keyboardDidHidden:(NSNotification*)notification
{
    [self buttonOK];
}

- (void)keyboardWillShow:(NSNotification*)notification
{
    double animationDuaration;
    UIViewAnimationOptions animationOption;
    [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey]getValue:&animationDuaration];
    [[notification.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey]getValue:&animationOption];
    NSDictionary* info = [notification userInfo];
    //kbSize即為鍵盤尺寸 (有width, height)
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:animationDuaration delay:0.0f options:animationOption animations:^{
        [UIView animateWithDuration:0.5 delay:0.0f options:0 animations:^{self.bgView.center = CGPointMake(self.frame.size.width/2, (self.frame.size.height-kbSize.height)/2);} completion:^(BOOL finished){}];
    }completion:^(BOOL finished)
     {
         
     }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self buttonOK];
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text; {
    
    if ([@"\n" isEqualToString:text] == YES) {
        [self.textView resignFirstResponder];
        [self buttonOK];
        return NO;
    }
    return YES;
}


-(void) buttonOK
{
    if(self.delegate != nil)
    {
       // if(self.bMutiline)
        if(self.textView.text != nil && ![self.textView.text isEqualToString:@""])
            [self.delegate buttonOKTag:1002 content:self.textView.text];
        [self.delegate hideView];
       // else
       //     [self.delegate buttonOKTag:1001 content:self.textView.text];
        self.hidden = YES;
        [self removeFromSuperview];
    }
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardDidHideNotification object:nil];

    self.textView = nil;
    self.bgView = nil;
    [super dealloc];
}

@end
