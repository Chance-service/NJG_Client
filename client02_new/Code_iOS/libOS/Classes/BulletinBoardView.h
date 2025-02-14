
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "C4L_MBProgressHUD.h"

class BulletinBoardPageListener;

@interface BulletinBoardView : UIView <UIWebViewDelegate,MBProgressHUDDelegate>
{
    UIWebView* _webView;
    BOOL _shouldLoadRequest;
    BOOL _isClose;
    NSTimer* _timer;
    NSInteger _loadingTimeOut;
    C4L_MBProgressHUD* _HUD;
    BulletinBoardPageListener *_webKitDelegate;
}
@property(nonatomic, retain) UIWebView* webView;
@property(nonatomic, retain) C4L_MBProgressHUD* HUD;
@property(nonatomic, retain) NSTimer* timer;
@property(nonatomic, assign) BOOL shouldLoadRequest;
@property(nonatomic, assign) NSInteger loadingTimeOut;
@property(nonatomic, assign) BOOL isClose;
@property(readwrite) BulletinBoardPageListener *webKitDelegate;



- (id)initWithFrame:(CGRect)frame isNavBarHiden:(BOOL)isNavBarHiden;
- (void)webViewOpenURL:(NSString *)URL;
//- (void)webViewEvaluatingJavaScriptFromString:(NSString *)jsString;
- (void)closeTimer;
//由libOS接口调用 以后会用到
+ (void)bulletinOpenURL:(NSString *)URL;
- (void)webViewShowContent:(NSString *)content;
@end
