//
//  RyukExpand.m
//  lib91
//
//  Created by 黄可 on 16/5/26.
//  Copyright © 2016年 youai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RyukExpand.h"
#include "libPlatform.h"
#import "JSON.h"
#import "libOS.h"
#import "UIHelperAlert.h"
#define TIP_EMAIL_ERROR @"端末のメール設定をご確認ください。"
@interface RyukExpand ()

@end

@implementation RyukExpand

#pragma mark - facebookShare

- (void) FBSendPhoto:(NSDictionary *) dict
{
    libOS::getInstance()->setWaiting(true);

    NSString *caption = (NSString *)[dict valueForKey:@"caption"];
    NSString *picture = (NSString *)[dict valueForKey:@"picture"];
    
    FBSDKSharePhoto *sharePhoto = [[FBSDKSharePhoto alloc] init];
    sharePhoto.caption = caption;
    sharePhoto.image = [UIImage imageNamed:picture];
    sharePhoto.userGenerated = YES;
    
    FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
    content.photos = @[sharePhoto];
    /*
     FBSDKShareDialog *shareDialog = [[FBSDKShareDialog alloc] init];
     shareDialog.shareContent = content;
     shareDialog.delegate = (id)self;
     shareDialog.fromViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController ];
     NSError * error = nil;
     BOOL validation = [shareDialog validateWithError:&error];
     if (validation) {
     [shareDialog show];
     }
     */
    [FBSDKShareAPI shareWithContent:content delegate:self];
}
- (void) FBSharePhoto:(NSDictionary *)dict
{
    
    NSString *const publish_actions = @"publish_actions";
    if ([[FBSDKAccessToken currentAccessToken] hasGranted:publish_actions]) {
        
        [self FBSendPhoto:dict];
    }
    else {
        
        [[[FBSDKLoginManager alloc] init]
         logInWithPublishPermissions:@[publish_actions]
         fromViewController:nil
         handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
             if ([result.grantedPermissions containsObject:publish_actions]) {
                 [self FBSendPhoto:dict];
             } else {
                 // This would be a nice place to tell the user why publishing
                 // is valuable.
                 //[_delegate shareUtility:self didFailWithError:nil];
                 [self sendMessage :@"loginError" :@""];
             }
         }];
        
    }
}
- (void) sendMessage:(NSString* )state:(NSString* )ret
{
    
    NSMutableDictionary *m_dic = [NSMutableDictionary dictionary];
    [m_dic setValue:state forKey:@"state"];
    [m_dic setValue:ret forKey:@"ret"];
    
    NSLog(@"--------------sendMessageP2G:----------jsonData----%@",m_dic);
    NSError *parseError = nil;
    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:m_dic options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *productJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    libPlatformManager::getPlatform()->sendMessageP2G("P2G_FACEBOOK_SHARE",[productJson UTF8String]);
    libOS::getInstance()->setWaiting(false);
}
- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    NSLog(@"%@",@"didCompleteWithResults");
    [self sendMessage :@"shareSuccess" :@""];
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    NSLog(@"%@",@"didFailWithError");
    [self sendMessage :@"shareError" :@""];

}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    NSLog(@"%@",@"sharerDidCancel");
    [self sendMessage :@"shareError" :@""];

}

#pragma mark - sendEmail

- (void) sendEmail:(NSString* )msg
{
    // 不能发邮件
    if (![MFMailComposeViewController canSendMail]){
        [UIHelperAlert ShowAlertMessage:nil message:TIP_EMAIL_ERROR];
        return;
    }
    MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
    mailPicker.mailComposeDelegate = self;
    
    SBJsonParser* parser = [[[SBJsonParser alloc] init] autorelease];
    NSDictionary *receiveMsg = [parser objectWithString:msg];

    
    //设置主题
    [mailPicker setSubject: @"ホウチ帝国お問合せ"];
    //添加收件人
    NSArray *toRecipients = [NSArray arrayWithObject: @"leave-support@ryuk.co.jp"];
    [mailPicker setToRecipients: toRecipients];
    
    NSMutableString *emailBody = [[NSMutableString alloc] init];
    [emailBody appendString:@"<br/><p >------------------------</p>"];
    [emailBody appendString:@"<p >※以下は削除しないでください</p>"];
    [emailBody appendString:[NSString stringWithFormat:@"<p >サーバーID:%@</p>", [receiveMsg valueForKey:@"serverid"]]];
    [emailBody appendString:[NSString stringWithFormat:@"<p >プレイヤーID:%@</p>", [receiveMsg valueForKey:@"playerid"]]];
    [emailBody appendString:[NSString stringWithFormat:@"<p >最終ログイン時間:%@</p>", [receiveMsg valueForKey:@"time"]]];
    [emailBody appendString:[NSString stringWithFormat:@"<p >バージョン:%@</p>", [receiveMsg valueForKey:@"version"]]];
    [emailBody appendString:[NSString stringWithFormat:@"<p >ユーザエージェント:</p><p >%@</p>",[NSString stringWithUTF8String:libOS::getInstance()->getPlatformInfo().c_str()]]];
    NSLog(@"%@",emailBody);
    [mailPicker setMessageBody:emailBody isHTML:YES];
    [[[[UIApplication sharedApplication] keyWindow] rootViewController ] presentViewController:mailPicker animated:YES completion:nil];
}
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    //关闭邮件发送窗口
    [[[[UIApplication sharedApplication] keyWindow] rootViewController ] dismissViewControllerAnimated:YES completion:nil];
    NSString *msg;
    switch (result) {
        case MFMailComposeResultCancelled:
            msg = @"用户取消编辑邮件";
            break;
        case MFMailComposeResultSaved:
            msg = @"用户成功保存邮件";
            break;
        case MFMailComposeResultSent:
            msg = @"用户点击发送，将邮件放到队列中，还没发送";
            break;
        case MFMailComposeResultFailed:
            msg = @"用户试图保存或者发送邮件失败";
            break;
        default:
            msg = @"";
            break;
    }
}
@end
