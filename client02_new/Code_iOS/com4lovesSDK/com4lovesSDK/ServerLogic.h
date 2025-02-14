//
//  ServerLogic.h
//  com4lovesSDK
//
//  Created by fish on 13-8-28.
//  Copyright (c) 2013年 com4loves. All rights reserved.
//

#import <Foundation/Foundation.h>
#define UserListUserDefault             @"comHuTuoSDK_userList"
#define UserListUserDefaultJSON         @"comHuTuoSDK_userList_JSON"
#define LatestUserUserDefault           @"comHuTuoSDK_latestUser"
#define LatestUserUserPasswordDefault   @"comHuTuoSDK_latestUser_password"
#define TryUserUserDefault              @"ccomHuTuoSDK_tryUser"
#define DocumentsFolder                 [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

#warning 发布前记得改地址
#define SERVER_IP  @"http://192.168.50.150:6520/"
#define SERVER_URL @"http://192.168.50.150:6520/"
#define SERVER_TEST_URL @"http://192.168.50.150:8261/"


@class HuTuoUser;
@interface ServerLogic : NSObject

+(ServerLogic*) sharedInstance;

-(BOOL) initServer;
-(void) initUserList;
-(NSString *)getInterfaceByName:(NSString *) interfaceName;
-(NSMutableDictionary*)getUserList;
-(NSString *)getFeedBackUrl;
-(BOOL) removeUserInUserList:(HuTuoUser *)user;
-(NSString*) getLatestUser;
-(NSString*) getLatestUserPassword;
-(NSString*) getTryUser;
-(NSString*) getHuTuoID;
-(NSString*) getLoginedUserName;
-(NSString*) getPrecreatedHuTuoName;
-(NSString*) getPrecreatedPassword;
-(NSNumber*) getLoginUserType;
-(NSString*) getServerUrl;

-(NSArray *)getUserLoginedServers;

-(BOOL) createOrLoginTryUser:(NSString *) huTuoId;
-(BOOL) getyouaiNames;
-(BOOL) getServerPlayerList;

-(NSDictionary *) parseResult:(NSString *) _retValue;

-(void) setYouaiID:(NSString*)youaiID;
-(void) updateUserList;
-(void) clearLoginInfo;

-(BOOL) bindingGuestID:(NSString *)         youaiId
              withName:(NSString *)         youaiName
           andPassword:(NSString *)         youaiPsd;


-(BOOL) pushForClient:(int)         serverId
           playername:(NSString*)   name
             playerID:(int)         playerID
             rmbMoney:(long)        rmb
             gameCoin:(long long)   coin
             vipLevel:(int)         Vlevel
          playerLevel:(int)         level
              pushSer:(BOOL)        isPush;

-(BOOL) changeTryUser2OkUserWithName:(NSString *)    youaiName
                            password:(NSString *)    password
                            andEmail:(NSString *)    email;

-(BOOL) create:(NSString*)username
      password:(NSString*)password
         email:(NSString*)email;

-(BOOL) login:(NSString*)username
     password:(NSString*)password;

-(BOOL) preCreate;
-(BOOL) modify:(NSString*) password
   oldPassword:(NSString*) oldPassword;
-(int) putToServerForDeviceInfo;

@end
