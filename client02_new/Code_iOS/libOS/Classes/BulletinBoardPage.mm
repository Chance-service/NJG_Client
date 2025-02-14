
#import <string>
#import "BulletinBoardPage.h"
#import "BulletinBoardView.h"
#import <iostream>
BulletinBoardPage* BulletinBoardPage::mInstance = 0;

BulletinBoardView* pBulletinBoardView = 0;

void BulletinBoardPage::init(float left,float top, float width, float height, BulletinBoardPageListener *listener)
{
    close();
    
    pBulletinBoardView = [[BulletinBoardView alloc] initWithFrame:CGRectMake(left, top, width, height) isNavBarHiden:NO];
    pBulletinBoardView.webKitDelegate = listener;
    
//#ifndef PROJECTITools
//    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:pBulletinBoardView];
//    [[UIApplication sharedApplication].keyWindow.rootViewController.view bringSubviewToFront:pBulletinBoardView];
//#endif
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    [window.rootViewController.view addSubview:pBulletinBoardView];
    
//    NSArray *array= [[UIApplication sharedApplication] windows];
//    UIWindow *window = array[0];
//    [window addSubview:pBulletinBoardView];
//    [window bringSubviewToFront:pBulletinBoardView];

}

/*
void BulletinBoardPage::show()
{
    if (pBulletinBoardView == nil) {
        std::cout<<"Webview does not open, cancel open URL: "<<std::endl;
        return;
    }
    std::string url = "www.mxhzw.com";
    [pBulletinBoardView webViewOpenURL:[NSString stringWithCString:url.c_str() encoding:[NSString defaultCStringEncoding]]];
}
*/
void BulletinBoardPage::show(const std::string& url)
{
    if (pBulletinBoardView == nil) {
        std::cout<<"Webview does not open, cancel open URL: "<<url<<std::endl;
        return;
    }
    [pBulletinBoardView webViewOpenURL:[NSString stringWithCString:url.c_str() encoding:[NSString defaultCStringEncoding]]];
}

void BulletinBoardPage::showWithContent(const char* content)
{
    if (pBulletinBoardView == nil) {
        std::cout<<"Webview does not open, cancel open URL: "<<std::endl;
        return;
    }
    [pBulletinBoardView webViewShowContent:[NSString stringWithCString:content]];
}


void BulletinBoardPage::close()
{
    if (pBulletinBoardView != nil) {
        [pBulletinBoardView canselBtnAction:nil];
        pBulletinBoardView = nil;
    }
}

void BulletinBoardPage::webKitSetLoadingTimeOut(int seconds)
{
    if (pBulletinBoardView) {
        pBulletinBoardView.loadingTimeOut = seconds;
    }
}

