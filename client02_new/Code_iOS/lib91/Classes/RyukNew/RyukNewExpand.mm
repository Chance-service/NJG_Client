//
//  RyukExpand.m
//  lib91
//
//  Created by 黄可 on 16/5/26.
//  Copyright © 2016年 youai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RyukNewExpand.h"
#include "libPlatform.h"
#import "JSON.h"
#include "libOS.h"
#import "UIHelperAlert.h"
#define TIP_EMAIL_ERROR @"端末のメール設定をご確認ください。"
@interface RyukNewExpand ()

@end

@implementation RyukNewExpand

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
    [mailPicker setSubject: @"一騎学園お問い合わせ"];
    //添加收件人
    NSArray *toRecipients = [NSArray arrayWithObject: @"school-support@crossmagic.co.jp"];
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
    [mailPicker release];
}
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    
    UIWindow *rootview =  [[UIApplication sharedApplication] keyWindow];
    
//    int num = [[UIApplication sharedApplication] windows]
//    NSLog("num %d",)
   
    for (UIWindow *win in [[UIApplication sharedApplication].windows  reverseObjectEnumerator]) {
//        if ([win isEqual: rootview])
//        {
//            continue;
//
//        }
//        if (win.windowLevel > rootview.windowLevel && win.hidden != YES )
//
//        {rootview =win;}
        
        NSArray *subviews = [win  subviews];
        int k =0;
        for (UIView *uiView in subviews)
        {
            int tag =[uiView tag];
             if (tag == 2)
            {
                //k++;
                //NSLog(@"---------%d   %d", [uiView tag],k);
                  //  uiView.backgroundColor = [UIColorwhiteColor];
                rootview =win;
                break;
            }
            
        }
        
        
    }
    

    //UIViewController *rootview =  [[[UIApplication sharedApplication] keyWindow] rootViewController];.
    
    //[rootview viewSafeAreaInsetsDidChange ];
    
    //[[[[UIApplication sharedApplication] keyWindow] rootViewController ] viewSafeAreaInsetsDidChange];
    
    if (@available(iOS 11.0, *)) {
        CGRect rect = [[UIScreen mainScreen]bounds];
        CGSize size = rect.size;
        CGFloat width = size.width;
        CGFloat height = size.height;
        CGFloat scale_screen = [UIScreen mainScreen].scale;
        //通过分辨率判断是否是iPhoneX手机
        if ((width*scale_screen ==1125 and height*scale_screen ==2436)||
            (width*scale_screen ==1242 and height*scale_screen ==2688)||
            (width*scale_screen ==828 and height*scale_screen ==1792))
        {
            
            CGFloat leftX = 0;
            CGFloat leftY = 0;
            CGFloat leftW = 500;
            CGFloat leftH = 200;
            
            if (width*scale_screen ==1125 and height*scale_screen ==2436) {
                leftX = 0;
                leftY = 30;
                leftW = 375;
                leftH = 760;
                
            }else if (width*scale_screen ==1242 and height*scale_screen ==2688)
            {
                leftX = 0;
                leftY = 30;
                leftW = 414;
                leftH = 840;
            }else if (width*scale_screen ==828 and height*scale_screen ==1792)
            {
                leftX = 0;
                leftY = 30;
                leftW = 414;
                leftH = 840;
            }
            if (rootview)
            {
                //                CGRect s = CGRectMake(self.view.safeAreaInsets.left,0,self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right,self.view.frame.size.height - self.view.safeAreaInsets.bottom);
                //x,y,width,height
                CGRect s = CGRectMake(leftX,leftY,leftW,leftH);
                rootview.frame = s;
                // 只需要记录一次，因为每次change view frame 都会改变一次这个
            }
            
            
            //[self rootview]
            
            CGFloat TopX = 0;
            CGFloat TopY = 0;
            CGFloat TopW = 500;
            CGFloat TopH = 200;
            
            if (width*scale_screen ==1125 and height*scale_screen ==2436) {
                TopX = 0;
                TopY = 0;
                TopW = 500;
                TopH = 200;
                
            }else if (width*scale_screen ==1242 and height*scale_screen ==2688)
            {
                TopX = 0;
                TopY = 0;
                TopW = 500;
                TopH = 200;
            }else if (width*scale_screen ==828 and height*scale_screen ==1792)
            {
                TopX = 0;
                TopY = 0;
                TopW = 500;
                TopH = 200;
                
            }
            
            
            
            
            
            UIView *subView = [rootview viewWithTag:1];
            
           // subView
            
            subView.frame = CGRectMake(0, -100, 500, 200);
            
            

//            NSArray *subviews = [rootview  subviews];
//            int k =0;
//            for (UIView *uiView in subviews)
//            {
//                int tag =[uiView tag];
//               // if (tag == 2)
//                {
//                    //k++;
//                NSLog(@"---------%d   %d", [uiView tag],k);
//                    if(tag == 2)
//                    {
//                        CGRect rect =[uiView frame];
//                        
//                          NSLog(@"view2  %f  %f %f %f",rect.origin.x,rect.origin.y,rect.size.width, rect.size.height);
//                        
//                    }
//                    
//                    if(tag == 1)
//                    {
//                         CGRect rect =[uiView frame];
//                       NSLog(@"view1  %f  %f %f %f",rect.origin.x,rect.origin.y,rect.size.width, rect.size.height);
//                        
//                    }
//                      //  uiView.backgroundColor = [UIColorwhiteColor];
//                  //  rootview =win;
//                }
//
//            }

//
           // [rootview subviews]
            
//            UIView *viewTop = [[UIView alloc]initWithFrame:CGRectMake(TopX,TopY,TopW,100)];
//            UIImageView* imageViewL = [[UIImageView alloc]initWithFrame:viewTop.bounds];
//            //UIImage *image = [UIImage imageNamed:@"loadingScene/u_announcement.png"];
//            //UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
//            imageViewL.image = [UIImage imageNamed:@"LoadingUI_JP/loadingUI_AdaptiveUp.png"];
//
//            [viewTop addSubview:imageViewL];
//
//            [[[UIApplication sharedApplication] keyWindow] addSubview:viewTop];
//
//            [[[UIApplication sharedApplication] keyWindow] sendSubviewToBack:viewTop];
//
        }
    }
    
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
