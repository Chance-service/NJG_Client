//
//  WebView.h
//  com4lovesSDK
//
//  Created by fish on 13-8-26.
//  Copyright (c) 2013年 com4loves. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface WebView : UIViewController<WKNavigationDelegate>
{
    UIViewController * mOriRootViewController;
}

-(void) showWeb:(NSString*)url;
-(void) hideWeb;
@property (retain, nonatomic) IBOutlet UIButton *btnClose;

- (IBAction)onEnd:(id)sender;


@property(nonatomic, retain) IBOutlet WKWebView * mWebView;
@end
