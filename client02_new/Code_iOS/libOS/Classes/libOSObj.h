//
//  libOSObj.h
//  libOS
//
//  Created by lyg on 13-3-5.
// 
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#define YAPlatformStateLoginDone                @"YAPlatformStateLoginDone"
//#define YAPlatformStateInitDone                 @"YAPlatformStateInitDone"
//#define YAPlatformStateCheckUpdateDone          @"YAPlatformStateCheckUpdateDone"
//#define YAPlatformStateBuyBegin                 @"YAPlatformStateBuyBegin"
//#define YAPlatformStateBuyDone                  @"YAPlatformStateBuyDone"
//#define YAPlatformStateLogoutDone               @"YAPlatformStateLogoutDone"
//#define YAPlatformStateTryUserRegisterDone      @"YAPlatformStateTryUserRegisterDone"


@interface libOSObj : NSObject
{
    UIActivityIndicatorView *waitView;
}
@property (nonatomic,assign)BOOL bHideView;
-(void) showWait;
-(void) hideWait;
//-(void) appVersionUpdateDidFinish:(ND_APP_UPDATE_RESULT)updateResult;
@end
