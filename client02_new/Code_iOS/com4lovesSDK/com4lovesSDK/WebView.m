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
    CGRect frame = [UIScreen mainScreen].bounds;
    [self.view setFrame:frame];
    
#ifdef WEB_R2
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
    [self.mWebView setNavigationDelegate:self];
 
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

// Equivalent to webViewDidStartLoad
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [[SDKUtility sharedInstance] setWaiting:YES];
}

// Equivalent to webViewDidFinishLoad
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [[SDKUtility sharedInstance] setWaiting:NO];
}

// Equivalent to shouldStartLoadWithRequest
- (void)webView:(WKWebView *)webView
    decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
    decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    if ([navigationAction.request.URL.absoluteString hasPrefix:@"objc://cmd/close"])
    {
        [self hideWeb];
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)dealloc
{
    [_btnClose release];
    [super dealloc];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self setBtnClose:nil];
}

@end
