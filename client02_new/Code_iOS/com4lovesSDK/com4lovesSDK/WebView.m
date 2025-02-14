//
//  WebView.m
//  com4lovesSDK
//
//  Created by fish on 13-8-26.
//  Copyright (c) 2013年 com4loves. All rights reserved.
//

#import "WebView.h"
#import "SDKUtility.h"
#import "comHuTuoSDK.h"

@implementation WebView

-(void) showWeb:(NSString*)url
{
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.view];
    [self.view setFrame:[[UIScreen mainScreen] applicationFrame]];
    
#ifdef WEB_R2
    
//    NSLog(@"--%s--show webView to r2-----",__FUNCTION__);
//反转视图
//    self.view.transform = CGAffineTransformMakeRotation(M_PI * 1.5);
//    self.mWebView.scalesPageToFit = YES;
    [self.btnClose setTitle:@"Close" forState:UIControlStateNormal];
    [self.btnClose setTitle:@"Close" forState:UIControlStateSelected];
    [self.btnClose setTitle:@"Close" forState:UIControlStateHighlighted];
#else
    [self.btnClose setTitle:[comHuTuoSDK getLang:@"close"] forState:UIControlStateNormal];
    [self.btnClose setTitle:[comHuTuoSDK getLang:@"close"] forState:UIControlStateSelected];
    [self.btnClose setTitle:[comHuTuoSDK getLang:@"close"] forState:UIControlStateHighlighted];
#endif
    NSURL *nsurl = [NSURL URLWithString:url];
    NSURLRequest *reqObject =  [NSURLRequest requestWithURL:nsurl];
    [self.mWebView setUserInteractionEnabled: YES ]; //是否支持交互
    [self.mWebView loadRequest:reqObject];
    [self.mWebView setDelegate:self];
 
}

-(void) hideWeb
{
    [[comHuTuoSDK sharedInstance] hideAll];
    [self.view removeFromSuperview];
}

- (IBAction)onEnd:(id)sender
{
    [self hideWeb];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[SDKUtility sharedInstance] setWaiting:YES];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
        [[SDKUtility sharedInstance] setWaiting:NO];
    
//    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
//        SEL selector = NSSelectorFromString(@"setOrientation:");
//        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
//        [invocation setSelector:selector];
//        [invocation setTarget:[UIDevice currentDevice]];
//        int val = UIInterfaceOrientationLandscapeLeft;
//        [invocation setArgument:&val atIndex:2];
//        [invocation invoke];
//    }

}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //;
    YALog(@"%@",request);
    NSString* rurl=[[request URL] absoluteString];
    if ([rurl hasPrefix:@"objc://cmd/close"]) {
        [self hideWeb];
    }
    return true;
}
- (void)dealloc {
    [_btnClose release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setBtnClose:nil];
    [super viewDidUnload];
}
@end
