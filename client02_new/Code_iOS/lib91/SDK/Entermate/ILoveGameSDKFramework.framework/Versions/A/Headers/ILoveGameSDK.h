//
//  ILoveGameSDK.h
//  ILoveGameSDK
//
//  Created by 이 태현 on 13. 10. 23..
//  Copyright (c) 2013년 Entermate. All rights reserved.
//

#if BAND_ENABLE
#import <BandSDK/BandSDK.h>
#endif
#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

typedef void (^ResponseCompletionHandler)(BOOL success, NSError * error);
typedef void (^SplashCompletionHandler)(BOOL complete);

@class IloveSettings;
@class WebViewController;

extern IloveSettings *_settings;
static NSString *SDKVERSION = @"1.1";

typedef enum
{
    ExecuteModeList = 0,
    ExecuteModeFriend,
    ExecuteModeInvite,
    ExecuteModeGift,
    ExecuteModePosting,
}ExecuteMode;

typedef enum
{
    POSTMODE_DIRECTPOST = 0,
    POSTMODE_WEBDIALOGPOST = 1,
}POSTINGMODE;

typedef enum
{
    SUCCESS = 1000,
}RESPONSCODE;

@interface ILoveGameSDK : NSObject <SKProductsRequestDelegate, UIAlertViewDelegate>{

    @private
    BOOL bProgressLogin;
    BOOL bAgreement;
    
    WebViewController *webView;
    NSArray *_products;
    ResponseCompletionHandler _completionHandler;
    UIView* _view;
    
    id m_Delegate;
}

+ (IloveSettings *) getSettings;
+ (ILoveGameSDK *) getInstance;

- (NSString *)version;
- (void) setupKakao:(id)delegate;
- (BOOL) isValidLogin;
- (void) setToken:(NSString *)accesstoken;
- (void) initialize:(ResponseCompletionHandler) completionHandler setDelegate:(id)newDelegate setLanguage:(NSString*)nsLanguage;
- (void) login:(ResponseCompletionHandler) completionHandler;
- (void) loginWithToken:(ResponseCompletionHandler) completionHandler Token:(NSString*) strToken;
- (void) logout:(ResponseCompletionHandler) completionHandler;
- (void) unregister:(ResponseCompletionHandler) completionHandler;
- (void) setMessageBlock:(ResponseCompletionHandler) completionHandler enable:(BOOL)enable;
- (void) setAgreement:(BOOL) success;
- (void) sendInvite:(ResponseCompletionHandler) completionHandler setUserid:(NSString *)user_id;
- (void) sendGift:(ResponseCompletionHandler) completionHandler setUserid:(NSString *)username;
- (void) guest:(ResponseCompletionHandler) completionHandler;
- (NSString *) getinfo:(NSString *)name;
- (NSArray*) get_giftlists;
- (void) receiveGift:(ResponseCompletionHandler) completionHandler setGiftId:(NSString *)gift_id setServerId:(NSString*)serverId;
- (void) openIntro:(id)delegate;
- (void) openAgreement:(id)delegate;
- (void) openEvent:(id) delegate;
- (void) openHelp:(id) delegate;
- (void) openHomepage:(id) delegate;
- (void) charge:(ResponseCompletionHandler) completionHandler setView:(UIView *)view ;
- (int) getLoginType;
- (NSString *) get_username;
- (NSString *) get_user_id;
- (NSString *) get_nickname;
- (NSString *) get_profileimageurl;
- (BOOL) IsGuestPopup;
- (BOOL) IsGuest;
- (BOOL) IsIntro;
- (BOOL) isPossibleKakaoFriend;
- (NSArray*) get_friendlists;
- (NSArray*) get_invitelists;
- (int) get_invite_count;
- (int) get_gift_count;
- (int) get_send_gift_count;
- (void) updateFriendLists;
- (void)handleDidBecomeActive:(UIApplication *)application;
- (void)handleWillResignActive:(UIApplication *)application;
- (BOOL) handleOpenURL:(NSURL *)url;
- (void) checkURL:(NSURL*)url;
- (void) setServerId:(NSString *) serverid;
- (void) setProductId:(NSString *) productid;
- (void) setOrderID:(NSString *)orderid;
//- (void) addFriend:(ResponseCompletionHandler) completionHandler setUsername:(NSString *)username;
- (void) Coupon:(ResponseCompletionHandler) completionHandler setNumber:(NSString *)number;
- (void) get_server_lists:(ResponseCompletionHandler) completionHandler;
- (NSString*) get_user_image;
- (BOOL) openCheckUrl: (NSURL *)url setSourceApplication:(NSString *) sourceApplication setAnnotation: (id) annotation;
- (void) playerinfo:(ResponseCompletionHandler) completionHandler setPlayerInfo:dict;
- (BOOL) getMessageBlock;
- (void)setSimpleLoginId:(NSString*)_simpleLoginId;
- (void)setSimpleLoginPW:(NSString*)_simpleLoginPW;
- (void)setSimpleLoginEmail:(NSString*)_simpleLoginEmail;
- (void) registeration:(ResponseCompletionHandler) completionHandler;
/*
 * Kakao Message 전송
 * _nsUserName : IloveGameID
 * _nsTempletID : Kakao Message Templet ID
 */
- (void) sendMessage:(NSString*)_nsUserName templetid:(NSString*)_nsTempletID handler:(ResponseCompletionHandler)completionHandler;

/*
 * Facebook 친구 초대 Web Dialog
 */
//- (void) sendInviteFBWebDialogWithMessage:(NSString*)message handler:(ResponseCompletionHandler) completionHandler;

/*
 * Facebook Posting
 * postingMode : POSTMODE_DIRECTPOST / POSTMODE_WEBDIALOGPOST
 */
- (void) sendPosting:(ResponseCompletionHandler) completionHandler
             setName:(NSString*)name
          setCaption:(NSString*)caption
      setDescription:(NSString*)description
             setLink:(NSString*)link
       setPictureURL:(NSString*)pictureurl
             setMode:(POSTINGMODE)postMode
             setType:(NSString*)postType;

- (BOOL) isVisibleFriend;
- (BOOL) isVisibleGuest;

- (void) sendAttack:(ResponseCompletionHandler) completionHandler setUserid:(NSString *)user_id isWin:(BOOL)isWin;

- (void) sendRegistrationID:(NSString*) deviceToken;
- (void) sendUnRegistrationID;

- (void) sendPushMessage:(NSArray*) arrReciverUser message:(NSString*) strMessage;
- (NSString*) getPrivateKey;
//- (void) bind:(ResponseCompletionHandler) completionHandler;
- (void) Update:(NSError*) error;
- (NSString *)getBase62:(int)length;

- (void)showSplash:(UIWindow*)windows
  isShowChanneling:(BOOL)showChanneling
     isShowCompany:(BOOL)showCompany
       setGradeEtc:(NSArray*)arrGradeEtc
           handler:(SplashCompletionHandler) completionHandler;

- (void)showSplash:(UIWindow*)windows
  isShowChanneling:(BOOL)showChanneling
setChannelingDisplayTime:(int)nDisplayTime
     isShowCompany:(BOOL)showCompany
       setGradeEtc:(NSArray*)arrGradeEtc
           handler:(SplashCompletionHandler) completionHandler;

- (void) showCoverView:(UIView *)view;
- (void) showCoverView:(UIView *)view touchDisable:(BOOL)_isTouchDisable;
- (void) hideCoverView:(UIView *)view;

- (NSString*) getConfirmMessage:(int)_messageIndex;

@end