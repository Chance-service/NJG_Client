
#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "C4L_MBProgressHUD.h"

class BulletinBoardPageListener;

@interface BulletinBoardView : WKWebView <WKNavigationDelegate,MBProgressHUDDelegate>
{
    WKWebView* _webView;
    BOOL _shouldLoadRequest;
    BOOL _isClose;
    NSTimer* _timer;
    NSInteger _loadingTimeOut;
    C4L_MBProgressHUD* _HUD;
    BulletinBoardPageListener *_webKitDelegate;
}
@property(nonatomic, retain) WKWebView* webView;
@property(nonatomic, retain) C4L_MBProgressHUD* HUD;
@property(nonatomic, retain) NSTimer* timer;
@property(nonatomic, assign) BOOL shouldLoadRequest;
@property(nonatomic, assign) NSInteger loadingTimeOut;
@property(nonatomic, assign) BOOL isClose;
@property(readwrite) BulletinBoardPageListener *webKitDelegate;



- (id)initWithFrame:(CGRect)frame isNavBarHiden:(BOOL)isNavBarHiden;
- (void)webViewOpenURL:(NSString *)URL;
- (void)closeTimer;
//由libOS接口调用 以后会用到
+ (void)bulletinOpenURL:(NSString *)URL;
- (void)webViewShowContent:(NSString *)content;
@end
