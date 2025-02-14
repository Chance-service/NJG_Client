//
//  R2SDK.h
//  R2SDK
//
//  Created by luxing on 7/24/15.
//  Copyright (c) 2015 luxing. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "R2SDKBaseResponse.h"
#import "R2RegisterResponse.h"
#import "R2LoginResponse.h"
#import "R2BindResponse.h"
#import "R2QueryResponse.h"

#define R2_OK 0


typedef void (^R2GameCenterLoginCompletionHandler)(NSDictionary* playerData);


typedef void (^R2CompletionHandler)(int code,NSString* msg,id<R2SDKResponse> result);
typedef void (^R2BaseCompletionHandler)(int code,NSString* msg,R2SDKBaseResponse* result);
typedef void (^R2RegisterCompletionHandler)(int code,NSString* msg,R2RegisterResponse* result);
typedef void (^R2LoginCompletionHandler)(int code,NSString* msg,R2LoginResponse* result);
typedef void (^R2BindCompletionHandler)(int code,NSString* msg,R2BindResponse* result);
typedef void (^R2QueryCompletionHandler)(int code,NSString* msg,R2QueryResponse* result);

@interface R2SDKApi : NSObject



+(void) doGameCenterLoginWithViewController:(UIViewController*)viewController completionHandler:(R2GameCenterLoginCompletionHandler)handler;


/* r2 account register*/
+(R2RegisterResponse*) registerWithAccount:(NSString*)account andPassword:(NSString*)password;

+(void) registerASyncWithAccount:(NSString*)account andPassword:(NSString*)password completionHandler:(R2RegisterCompletionHandler)handler;


+(void)loginWithGameCenter:(UIViewController*)viewController completionHandler:(R2LoginCompletionHandler)handler;


/* r2 account login */
+(R2LoginResponse*) loginWithR2Account:(NSString*)account andPassword:(NSString*)password;

+(void) loginAsyncWithR2Account:(NSString*)account andPassword:(NSString*)password completionHandler:(R2LoginCompletionHandler)handler;

/* third-party account login */
+(R2LoginResponse*) loginWithThirdPartyAccount:(NSString*)account andType:(NSString*)type;

+(void) loginAsyncWithThirdPartyAccount:(NSString*)account andType:(NSString*)type completionHandler:(R2LoginCompletionHandler)handler;

/* token login */
+(R2LoginResponse*) loginWithToken:(NSString*)token ThirdPartyAccount:(NSString*)account ThirdPartyType:(NSString*)type;

+(void) loginAsyncWithToken:(NSString*)token ThirdPartyAccount:(NSString*)account ThirdPartyType:(NSString*)type completionHandler:(R2LoginCompletionHandler)handler;


/* new account login */
+(R2LoginResponse*) loginWithNewAccount;

+(void) loginAsyncWithNewAccount:(R2LoginCompletionHandler)handler;


/* bind r2 account*/
+(R2BindResponse*) bindWithR2Uid:(NSString*)r2Uid R2Account:(NSString*)account R2Password:(NSString*)password;
+(void) bindAsyncWithR2Uid:(NSString*)r2Uid R2Account:(NSString*)account R2Password:(NSString*)password completionHandler:(R2BindCompletionHandler)handler;

/* bind third party account*/
+(R2BindResponse*) bindWithR2Uid:(NSString*)r2Uid ThirdPartyAccount:(NSString*)account ThirdPartyType:(NSString*)type;

+(void) bindAsyncWithR2Uid:(NSString*)r2Uid ThirdPartyAccount:(NSString*)account ThirdPartyType:(NSString*)type completionHandler:(R2BindCompletionHandler)handler;

/* single query third party uid*/
+(R2QueryResponse*) queryThirdPartyAccountWithR2Uid:(NSString*)r2Uid;

+(void) queryAsyncThirdPartyAccountWithR2Uid:(NSString*)r2Uid completionHandler:(R2QueryCompletionHandler)handler;

/* single query r2 uid*/
+(R2QueryResponse*) queryR2UidWithThirdPartyAccount:(NSString*)account ThirdPartyType:(NSString*)type;

+(void) queryAsyncR2UidWithThirdPartyAccount:(NSString*)account ThirdPartyType:(NSString*)type completionHandler:(R2QueryCompletionHandler)handler;

/* batch query r2 uid*/
+(R2QueryResponse*) queryR2UidsWithThirdPartyAccounts:(NSArray*)accounts ThirdPartyType:(NSString*)type;

+(void) queryR2UidsWithThirdPartyAccounts:(NSArray*)accounts ThirdPartyType:(NSString*)type completionHandler:(R2QueryCompletionHandler)handler;

/* activate */
+(R2SDKBaseResponse*) activate;
+(void) activateAsyncWithCompletionHandler:(R2BaseCompletionHandler)handler;




@end
