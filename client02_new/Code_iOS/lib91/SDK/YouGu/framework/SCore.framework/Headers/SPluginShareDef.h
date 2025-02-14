//
//  SPluginShareDef.h
//  SCore
//
//  Created by dev on 2017/9/26.
//  Copyright © 2017年 . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPluginShareDef : NSObject

typedef NS_ENUM(NSUInteger, SShareSocial)
{
    /** 微信 */
    SShareSocialWechat,
    /** 手机QQ */
    SShareSocialQQ,
    /** 新浪微博 */
    SShareSocialSina,
    /** facebook */
    SShareSocialFacebook
};

typedef NS_ENUM(NSUInteger, SShareToSocial)
{
    /** 微信聊天界面 */
    SShareToWechatSession,
    /** 微信朋友圈 */
    SShareToWechatTimeLine,
    /** 手机QQ */
    SShareToQQ,
    /** QQ空间 */
    SShareToQZone,
    /** 新浪微博 */
    SShareToSina,
    /** facebook */
    SShareToFacebook
};

typedef NS_ENUM(NSUInteger, SShareAction)
{
    /** 分享成功 */
    SShareActionSuccess,
    /** 分享失败 */
    SShareActionFailure
};

/** 分享标题(NSString) */
extern NSString *kSShareTitle;
/** 分享文本(NSString) */
extern NSString *kSShareText;
/** 分享描述(NSString) */
extern NSString *kSShareDescription;

/** 分享图片(NSData) */
extern NSString *kSShareImageData;
/** 分享图片链接(NSString) */
extern NSString *kSShareImageURL;
/** 分享本地图片路径(NSString) */
extern NSString *kSShareImageLocalPath;

/** 分享图片缩略图(NSData) */
extern NSString *kSShareThumbImageData;
/** 分享图片缩略图链接(NSString) */
extern NSString *kSShareThumbImageURL;
/** 分享缩略图路径 */
extern NSString *kSShareThumbImageLocalPath;

/** 分享链接(NSString) */
extern NSString *kSShareLinkURL;
/** 透传字段(NSString) */
extern NSString *kSShareExtend;

@end
