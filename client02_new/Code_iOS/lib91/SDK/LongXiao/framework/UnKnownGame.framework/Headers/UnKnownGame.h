
#import <Foundation/Foundation.h>

// 登陆成功后的 回调
typedef void(^loginSuccessBlock)(NSString *sessionID, NSString *uid);

@protocol PlatformBuyDelegate;
@interface UnKnownGame : NSObject
@property (nonatomic, weak) id <PlatformBuyDelegate> delegate;
@property (nonatomic, copy) loginSuccessBlock loginSuccessBlcok;

+ (instancetype)sharedPlatform;

// SDK 初始化
- (void)initWithGameID:(NSString *)gameid gameKey:(NSString *)gameKey channelID:(NSString *)channelID;

// 登陆
- (void)loginWithSuccessCallBack:(loginSuccessBlock)callBackBlock;

// 判断是否是临时账号
- (BOOL)isTempUser;

// 登录游戏成功上传当前用户的游戏角色信息
- (void)uploadTheGameRoleInfo:(NSDictionary *)roleInfo;

// 个人中心(请在SDK登陆成功后调用)
- (void)userCenter;


// 购买
- (void)buyGoods:(NSDictionary *)goodsDict;

@end

@protocol PlatformBuyDelegate <NSObject>
// 购买成功
- (void)PlatformBuySuccessUsePayType:(NSInteger)payType;

// 购买失败
- (void)PlatformBuyFailure:(NSString *)errorMsg;

// 可选页面关闭
@optional
- (void)PlatformBuyViewClose;
@end
