
#import <string>
#import "BulletinBoardView.h"
#import "BulletinBoardPage.h"
#include "libOS.h"
#define isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
static BulletinBoardView *sigBullentionBoardView = nil;

@implementation BulletinBoardView

@synthesize webView = _webView;
@synthesize webKitDelegate = _webKitDelegate;
@synthesize shouldLoadRequest = _shouldLoadRequest;
@synthesize HUD = _HUD;
@synthesize timer = _timer;
@synthesize loadingTimeOut = _loadingTimeOut;
@synthesize isClose = _isClose;

+ (void)bulletinOpenURL:(NSString *)URL
{
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    if(sigBullentionBoardView == nil)
    {
        sigBullentionBoardView = [[BulletinBoardView alloc]initWithFrame:window.rootViewController.view.frame isNavBarHiden:YES];
        [window.rootViewController.view addSubview:sigBullentionBoardView];
        [sigBullentionBoardView release];
    }
    [window.rootViewController.view bringSubviewToFront:sigBullentionBoardView];
    [sigBullentionBoardView webViewOpenURL:URL];
}

- (id)initWithFrame:(CGRect)frame isNavBarHiden:(BOOL)isNavBarHiden
{
    //self = [super initWithFrame:CGRectMake(0, 0, screen.size.height, screen.size.width)];
    CGRect screen;
    CGRect initFrame;
    std::string gameID = libOS::getInstance()->getGameID();
    if(gameID == "5")
    {
        screen = [UIApplication sharedApplication].keyWindow.rootViewController.view.frame;
        initFrame = screen;
    }
    else
    {
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        screen = window.frame;
        initFrame = CGRectMake(0, 0, 640, 960);
    }
    self = [super initWithFrame:initFrame];
    if (self) {
        self.shouldLoadRequest = YES;
        self.webKitDelegate = NULL;
        self.timer = nil;
        self.isClose = FALSE;
        if(gameID == "5")
            [self initViewSaint:screen];
        else
            [self initView:screen];
        [self initLoadingTime];
        [self initHUD];
    }
    return self;
}

#pragma mark
#pragma mark --------------------------------- Init ---------------------------------------
- (void)initView:(CGRect)screen
{
  //  CGRect screen = [UIApplication sharedApplication].keyWindow.rootViewController.view.frame;
    self.center = CGPointMake(screen.size.width/2,screen.size.height/2);
    self.transform = CGAffineTransformMakeScale(screen.size.width / 640, screen.size.height / 960);
    self.backgroundColor = [UIColor clearColor];
    NSLog(@"Creat a webKit!");
    UIImage *image = [UIImage imageNamed:@"loadingScene/u_announcement.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setFrame:CGRectMake(0, 0, 609, 695)];
    //imageView.center = CGPointMake(self.frame.size.width/2,self.frame.size.height/2);
    imageView.center = CGPointMake(320,460);
    [self addSubview:imageView];
    [imageView release];
    
    CGRect webviewFrame = CGRectMake(0, 0, 500, 450);
    UIWebView *webView = [[UIWebView alloc] initWithFrame:webviewFrame];
    webView.center = CGPointMake(320,410);
    webView.opaque = YES;
    webView.backgroundColor = [UIColor whiteColor];
    webView.delegate = self;
    webView.scalesPageToFit = YES;
    [webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [webView setAllowsInlineMediaPlayback:YES];
    [self addSubview:webView];
    [webView release];
    self.webView = webView;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 205, 103);
    button.center = CGPointMake(320,712);
    UIImage *image1 = [UIImage imageNamed:@"loadingScene/u_announcementB.png"];
    [button setBackgroundImage:image1 forState:UIControlStateNormal];
    UIImage *image2 = [UIImage imageNamed:@"loadingScene/u_announcementC.png"];
    [button setBackgroundImage:image2 forState:UIControlStateSelected];
    [button addTarget:self action:@selector(canselBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
}

- (void)initViewSaint:(CGRect)screen
{
    self.center = CGPointMake(screen.size.width/2,screen.size.height/2);
    self.backgroundColor = [UIColor clearColor];
    UIImage *image = [UIImage imageNamed:@"loadingScene/u_announcement.png"];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    CGRect webviewFrame;
    CGRect buttonFrame;
    CGRect titleFrame;
    if(isPad == true){
        [imageView setFrame:CGRectMake(0, 0, 564, 594)];
        webviewFrame = CGRectMake(22, 40, 520, 530);
        buttonFrame = CGRectMake(0, 0, 160, 160);
        titleFrame = CGRectMake(0, 0, 256, 76);
    }else{
        [imageView setFrame:CGRectMake(0, 0, 564/2, 594/2)];
        webviewFrame = CGRectMake(12, 20, 520/2, 530/2);
        buttonFrame = CGRectMake(0, 0, 160/2, 160/2);
        titleFrame = CGRectMake(0, 0, 256/2, 76/2);
    }
    imageView.center = CGPointMake(screen.size.width/2,screen.size.height/2);
    [self addSubview:imageView];
    UIWebView *m_webView = [[UIWebView alloc] initWithFrame:webviewFrame];
    m_webView.delegate = self;
    m_webView.scalesPageToFit = YES;
    [m_webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    //[m_webView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [m_webView setAllowsInlineMediaPlayback:YES];
    [imageView addSubview:m_webView];
    [imageView setUserInteractionEnabled:YES];
    [m_webView setAllowsInlineMediaPlayback:YES];
    self.webView = m_webView;
    [m_webView release];
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = buttonFrame;
    if(isPad)
        button.center = CGPointMake(imageView.frame.size.width-15,5);
    else
        button.center = CGPointMake(imageView.frame.size.width-15,5);
    [button setContentMode:UIViewContentModeCenter];
    [button setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
    
    UIImage *image1 = [UIImage imageNamed:@"loadingScene/u_announcementB.png"];
    [button setBackgroundImage:image1 forState:UIControlStateNormal];
    UIImage *image2 = [UIImage imageNamed:@"loadingScene/u_announcementC.png"];
    [button setBackgroundImage:image2 forState:UIControlStateSelected];
    [button addTarget:self action:@selector(canselBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [imageView addSubview:button];
    
    UIButton* boxTitle = [UIButton buttonWithType:UIButtonTypeCustom];
    boxTitle.frame = titleFrame;
    if(isPad)
        boxTitle.center = CGPointMake(85,0);
    else
        boxTitle.center = CGPointMake(55,5);
    UIImage *imageT = [UIImage imageNamed:@"loadingScene/u_announcement_t.png"];
    
    [boxTitle setBackgroundImage:imageT forState:UIControlStateNormal];
    UIImage *imageT2 = [UIImage imageNamed:@"loadingScene/u_announcement_t.png"];
    
    [boxTitle setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
    [boxTitle setBackgroundImage:imageT2 forState:UIControlStateSelected];
    [boxTitle setUserInteractionEnabled:YES];
    [imageView addSubview:boxTitle];

}


- (void)initLoadingTime
{
    self.loadingTimeOut = 50;
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"ALSystemConfig" ofType:@"plist"];
    NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:bundlePath];
    if(dict) {
        NSString* value = [dict valueForKey:@"loadingTimeOut"];
        if (value) {
            self.loadingTimeOut = [value integerValue];
        }
        else {
            NSLog(@"Cannot find value for loadingTimeOut, loadingTimeOut will be set to 50");
        }
    }
    else {
        NSLog(@"Cannot Find  ALSystemConfig.plist, loadingTimeOut will be set to 50");
    }
    NSLog(@"loadingTimeOut = %ld",(long)self.loadingTimeOut);
}

- (void)initHUD
{
    C4L_MBProgressHUD *HUD = [[C4L_MBProgressHUD alloc] initWithView:self];
    [self addSubview:HUD];
    HUD.labelText = @"操作成功";
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.customView = self;  //设置自定义view
    [HUD show:YES];
    self.HUD = HUD;
    [HUD release];
}

- (void) canselBtnAction:(id)sender
{
    [self closeTimer];
    [self.HUD hide:NO];
    self.webKitDelegate = NULL;
    self.isClose = TRUE;
    [self removeFromSuperview];
    sigBullentionBoardView = nil;
//    if (self.webKitDelegate != NULL) {
//        self.webKitDelegate->onBtnAction();
//    }
}

- (void)timeOut
{
    [self.webView stopLoading];
    [self canselBtnAction:nil];
    const std::string stdErrorStr("WebKit loading time out!");
    NSLog(@"WebKit loading time out! %ld seconds", (long)self.loadingTimeOut);
//    if (self.webKitDelegate != NULL) {
//        self.webKitDelegate->onLoadingTimeOut();
//    }
    [self canselBtnAction:nil];
}

#pragma mark
#pragma mark ------------------------ UIWebViewDelegate -------------------------------

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"WebKit will open URL: %@",[[request URL] absoluteString]);
    return self.shouldLoadRequest;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.HUD show:YES];
    [self closeTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)self.loadingTimeOut target:self selector:@selector(timeOut) userInfo:nil repeats:NO];
//    if (self.webKitDelegate != NULL) {
//        self.webKitDelegate->onStartLoad();
//    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.HUD hide:NO];
    [self closeTimer];
//    if (self.webKitDelegate != NULL) {
//        self.webKitDelegate->onFinishLoad();
//    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.HUD hide:NO];
    [self closeTimer];
    if (self.webKitDelegate != NULL) {
        NSString* errorStr = [NSString stringWithString:[error description]];
        const std::string stdErrorStr([errorStr UTF8String]);
        self.webKitDelegate->onFailLoadWithError(stdErrorStr);
    }
}

#pragma mark
#pragma mark ------------------------------ Touch -------------------------------------

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch* touch = [touches anyObject];
	if([touch tapCount]>0)
	{
	}
}
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch* touch = [touches anyObject];
	CGPoint  lastpoint = [touch locationInView:self];
}

#pragma mark
#pragma mark ------------------------------- 外部接口 ------------------------------------

- (void)webViewEvaluatingJavaScriptFromString:(NSString *)jsString
{
    if (self.webView != NULL) {
        [self.webView stringByEvaluatingJavaScriptFromString:jsString];
    }
}


- (void)webViewOpenURL:(NSString *)URL
{
    if(self.webView)
    {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URL]]];
    }
    //#ifdef PROJECTITools
    //    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(delayShow) userInfo:nil repeats:NO];
    //#endif
}

- (void)webViewShowContent:(NSString *)content
{
    [self.webView loadHTMLString:content baseURL:nil];
}

//-(void)delayShow
//{
//    if (self.isClose) {
//        return;
//    }
//    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self];
//    [[UIApplication sharedApplication].keyWindow.rootViewController.view bringSubviewToFront:self];
//    [self setHidden:NO];
//}

- (void)closeTimer
{
    if (self.timer) {
        if ([self.timer isValid] == TRUE) {
            [self.timer invalidate];
        }
       self.timer = nil;
    }
}


- (void) dealloc
{
    NSLog(@"Close a webKit!");
    self.webView = nil;
    self.HUD = nil;
    self.timer = nil;
    self.webKitDelegate = NULL;
    [super dealloc];
}

@end