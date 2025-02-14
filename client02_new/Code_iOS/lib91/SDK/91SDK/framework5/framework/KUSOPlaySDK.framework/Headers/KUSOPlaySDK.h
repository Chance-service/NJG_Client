#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSError.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSString.h>
#import <Foundation/NSValue.h>

@class KotlinEnumCompanion, KotlinEnum<E>, Currency, KotlinArray<T>, GatewayCompanion, Gateway, GatewayCode, OrderCompanion, Order, PlayCenter, PlayCenterServices, UIViewController, PlayCenterConfig, PlayCenterError, PlayCenterConfigCompanion;

@protocol KotlinComparable, Kotlinx_serialization_coreKSerializer, PlayCenterCheckOrderListener, PlayCenterLoginListener, PlayCenterLogoutListener, PlayCenterPayOrderListener, PlayCenterQueryGatewayListener;

NS_ASSUME_NONNULL_BEGIN
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunknown-warning-option"
#pragma clang diagnostic ignored "-Wincompatible-property-type"
#pragma clang diagnostic ignored "-Wnullability"

#pragma push_macro("_Nullable_result")
#if !__has_feature(nullability_nullable_result)
#undef _Nullable_result
#define _Nullable_result _Nullable
#endif

__attribute__((swift_name("KotlinBase")))
@interface Base : NSObject
- (instancetype)init __attribute__((unavailable));
+ (instancetype)new __attribute__((unavailable));
+ (void)initialize __attribute__((objc_requires_super));
@end

@interface Base (BaseCopying) <NSCopying>
@end

__attribute__((swift_name("KotlinMutableSet")))
@interface MutableSet<ObjectType> : NSMutableSet<ObjectType>
@end

__attribute__((swift_name("KotlinMutableDictionary")))
@interface MutableDictionary<KeyType, ObjectType> : NSMutableDictionary<KeyType, ObjectType>
@end

@interface NSError (NSErrorKotlinException)
@property (readonly) id _Nullable kotlinException;
@end

@protocol KotlinComparable
@required
- (int32_t)compareToOther:(id _Nullable)other __attribute__((swift_name("compareTo(other:)")));
@end

@interface KotlinEnum<E> : Base <KotlinComparable>
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer));
@property (class, readonly, getter=companion) KotlinEnumCompanion *companion __attribute__((swift_name("companion")));
- (int32_t)compareToOther:(E)other __attribute__((swift_name("compareTo(other:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) NSString *name __attribute__((swift_name("name")));
@property (readonly) int32_t ordinal __attribute__((swift_name("ordinal")));
@end

__attribute__((objc_subclassing_restricted))
@interface Currency : KotlinEnum<Currency *>
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
@property (class, readonly) Currency *usd __attribute__((swift_name("usd")));
@property (class, readonly) Currency *hkd __attribute__((swift_name("hkd")));
@property (class, readonly) Currency *cny __attribute__((swift_name("cny")));
+ (KotlinArray<Currency *> *)values __attribute__((swift_name("values()")));
@property (class, readonly) NSArray<Currency *> *entries __attribute__((swift_name("entries")));
@property (readonly) NSString *currency __attribute__((swift_name("currency")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
@interface Gateway : Base
- (instancetype)initWithGatewayCode:(NSString *)gatewayCode name:(NSString *)name currency:(NSString *)currency icon:(NSString *)icon minAmount:(int32_t)minAmount maxAmount:(int32_t)maxAmount __attribute__((swift_name("init(gatewayCode:name:currency:icon:minAmount:maxAmount:)"))) __attribute__((objc_designated_initializer));
@property (class, readonly, getter=companion) GatewayCompanion *companion __attribute__((swift_name("companion")));
- (Gateway *)doCopyGatewayCode:(NSString *)gatewayCode name:(NSString *)name currency:(NSString *)currency icon:(NSString *)icon minAmount:(int32_t)minAmount maxAmount:(int32_t)maxAmount __attribute__((swift_name("doCopy(gatewayCode:name:currency:icon:minAmount:maxAmount:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) NSString *currency __attribute__((swift_name("currency")));
@property (readonly) NSString *gatewayCode __attribute__((swift_name("gatewayCode")));
@property (readonly) NSString *icon __attribute__((swift_name("icon")));
@property (readonly) int32_t maxAmount __attribute__((swift_name("maxAmount")));
@property (readonly) int32_t minAmount __attribute__((swift_name("minAmount")));
@property (readonly) NSString *name __attribute__((swift_name("name")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Gateway.Companion")))
@interface GatewayCompanion : Base
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) GatewayCompanion *shared __attribute__((swift_name("shared")));
- (id<Kotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end

__attribute__((objc_subclassing_restricted))
@interface GatewayCode : KotlinEnum<GatewayCode *>
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
@property (class, readonly) GatewayCode *all __attribute__((swift_name("all")));
@property (class, readonly) GatewayCode *web __attribute__((swift_name("web")));
@property (class, readonly) GatewayCode *creditCard __attribute__((swift_name("creditCard")));
@property (class, readonly) GatewayCode *googlePlay __attribute__((swift_name("googlePlay")));
@property (class, readonly) GatewayCode *alipay __attribute__((swift_name("alipay")));
@property (class, readonly) GatewayCode *alipayQr __attribute__((swift_name("alipayQr")));
@property (class, readonly) GatewayCode *wechat __attribute__((swift_name("wechat")));
@property (class, readonly) GatewayCode *wechatQr __attribute__((swift_name("wechatQr")));
@property (class, readonly) GatewayCode *unionPay __attribute__((swift_name("unionPay")));
@property (class, readonly) GatewayCode *unionPayQr __attribute__((swift_name("unionPayQr")));
@property (class, readonly) GatewayCode *kiwi __attribute__((swift_name("kiwi")));
+ (KotlinArray<GatewayCode *> *)values __attribute__((swift_name("values()")));
@property (class, readonly) NSArray<GatewayCode *> *entries __attribute__((swift_name("entries")));
@property (readonly) NSString *code __attribute__((swift_name("code")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
@interface Order : Base
- (instancetype)initWithId:(NSString *)id nonce:(NSString *)nonce items:(NSString *)items amount:(int32_t)amount status:(NSString *)status currency:(NSString *)currency createdAt:(int64_t)createdAt updatedAt:(int64_t)updatedAt __attribute__((swift_name("init(id:nonce:items:amount:status:currency:createdAt:updatedAt:)"))) __attribute__((objc_designated_initializer));
@property (class, readonly, getter=companion) OrderCompanion *companion __attribute__((swift_name("companion")));
- (Order *)doCopyId:(NSString *)id nonce:(NSString *)nonce items:(NSString *)items amount:(int32_t)amount status:(NSString *)status currency:(NSString *)currency createdAt:(int64_t)createdAt updatedAt:(int64_t)updatedAt __attribute__((swift_name("doCopy(id:nonce:items:amount:status:currency:createdAt:updatedAt:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) int32_t amount __attribute__((swift_name("amount")));
@property (readonly) int64_t createdAt __attribute__((swift_name("createdAt")));
@property (readonly) NSString *currency __attribute__((swift_name("currency")));
@property (readonly) NSString *id __attribute__((swift_name("id")));

/**
 * @note annotations
 *   kotlinx.serialization.Serializable(with=NormalClass(value=com/kusoplay/sdk/internal/serializer/JsonAsStringSerializer))
*/
@property (readonly) NSString *items __attribute__((swift_name("items")));
@property (readonly) NSString *nonce __attribute__((swift_name("nonce")));
@property (readonly) NSString *status __attribute__((swift_name("status")));
@property (readonly) int64_t updatedAt __attribute__((swift_name("updatedAt")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Order.Companion")))
@interface OrderCompanion : Base
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) OrderCompanion *shared __attribute__((swift_name("shared")));
- (id<Kotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end

__attribute__((objc_subclassing_restricted))
@interface PlayCenter : Base
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)playCenter __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) PlayCenter *shared __attribute__((swift_name("shared")));
- (void)bind __attribute__((swift_name("bind()")));
- (void)checkOrderOrderId:(NSString *)orderId listener:(id<PlayCenterCheckOrderListener>)listener __attribute__((swift_name("checkOrder(orderId:listener:)")));
- (void)checkOrderByNonceNonce:(NSString *)nonce listener:(id<PlayCenterCheckOrderListener>)listener __attribute__((swift_name("checkOrderByNonce(nonce:listener:)")));
- (void)closeServiceServiceName:(PlayCenterServices *)serviceName __attribute__((swift_name("closeService(serviceName:)")));
- (void)loginListener:(id<PlayCenterLoginListener>)listener __attribute__((swift_name("login(listener:)")));
- (void)logoutListener:(id<PlayCenterLogoutListener>)listener __attribute__((swift_name("logout(listener:)")));
- (void)payOrderAmount:(int32_t)amount currency:(Currency *)currency gatewayCode:(GatewayCode *)gatewayCode callbackUrl:(NSString *)callbackUrl description:(NSString *)description nonce:(NSString *)nonce items:(NSString * _Nullable)items listener:(id<PlayCenterPayOrderListener> _Nullable)listener __attribute__((swift_name("payOrder(amount:currency:gatewayCode:callbackUrl:description:nonce:items:listener:)")));
- (void)profile __attribute__((swift_name("profile()")));
- (void)queryGatewayCurrency:(Currency *)currency gatewayCode:(GatewayCode *)gatewayCode listener:(id<PlayCenterQueryGatewayListener>)listener __attribute__((swift_name("queryGateway(currency:gatewayCode:listener:)")));
- (void)queryGatewayCurrency:(Currency *)currency gatewayCode:(GatewayCode *)gatewayCode amount:(int32_t)amount listener:(id<PlayCenterQueryGatewayListener>)listener __attribute__((swift_name("queryGateway(currency:gatewayCode:amount:listener:)")));
- (void)setupViewController:(UIViewController *)viewController config:(PlayCenterConfig *)config __attribute__((swift_name("setup(viewController:config:)")));
- (void)setupViewController:(UIViewController *)viewController appId:(NSString *)appId __attribute__((swift_name("setup(viewController:appId:)")));
- (void)setupViewController:(UIViewController *)viewController appId:(NSString *)appId isSandbox:(BOOL)isSandbox __attribute__((swift_name("setup(viewController:appId:isSandbox:)")));
- (void)setupViewController:(UIViewController *)viewController appId:(NSString *)appId isSandbox:(BOOL)isSandbox currency:(Currency *)currency subId:(NSString * _Nullable)subId __attribute__((swift_name("setup(viewController:appId:isSandbox:currency:subId:)")));
- (void)showServiceServiceName:(PlayCenterServices *)serviceName __attribute__((swift_name("showService(serviceName:)")));
- (void)showServiceServiceName:(PlayCenterServices *)serviceName value:(NSString * _Nullable)value __attribute__((swift_name("showService(serviceName:value:)")));
@property (readonly) NSString * _Nullable accountID __attribute__((swift_name("accountID")));
@property (readonly) BOOL isBinded __attribute__((swift_name("isBinded")));
@property (readonly) BOOL isLoggedIn __attribute__((swift_name("isLoggedIn")));
@property (readonly) BOOL isSandbox __attribute__((swift_name("isSandbox")));
@property (readonly) NSString * _Nullable token __attribute__((swift_name("token")));

/**
 * @note annotations
 *   kotlin.jvm.JvmStatic
*/
@property (readonly) NSString *version __attribute__((swift_name("version")));
@end

@protocol PlayCenterCheckOrderListener
@required
- (void)onCheckedSuccess:(BOOL)success order:(Order * _Nullable)order error:(PlayCenterError * _Nullable)error __attribute__((swift_name("onChecked(success:order:error:)")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
@interface PlayCenterConfig : Base
- (instancetype)initWithAppId:(NSString *)appId __attribute__((swift_name("init(appId:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithAppId:(NSString *)appId isSandbox:(BOOL)isSandbox __attribute__((swift_name("init(appId:isSandbox:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithAppId:(NSString *)appId isSandbox:(BOOL)isSandbox currency:(Currency *)currency __attribute__((swift_name("init(appId:isSandbox:currency:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithAppId:(NSString *)appId isSandbox:(BOOL)isSandbox currency:(Currency *)currency subId:(NSString * _Nullable)subId __attribute__((swift_name("init(appId:isSandbox:currency:subId:)"))) __attribute__((objc_designated_initializer));
@property (class, readonly, getter=companion) PlayCenterConfigCompanion *companion __attribute__((swift_name("companion")));
- (PlayCenterConfig *)doCopyAppId:(NSString *)appId isSandbox:(BOOL)isSandbox currency:(Currency *)currency subId:(NSString * _Nullable)subId __attribute__((swift_name("doCopy(appId:isSandbox:currency:subId:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) NSString *appId __attribute__((swift_name("appId")));
@property (readonly) Currency *currency __attribute__((swift_name("currency")));
@property (readonly) BOOL isSandbox __attribute__((swift_name("isSandbox")));
@property (readonly) NSString * _Nullable subId __attribute__((swift_name("subId")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PlayCenterConfig.Companion")))
@interface PlayCenterConfigCompanion : Base
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@property (class, readonly, getter=shared) PlayCenterConfigCompanion *shared __attribute__((swift_name("shared")));
- (id<Kotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end

__attribute__((objc_subclassing_restricted))
@interface PlayCenterError : Base
- (instancetype)initWithMessage:(NSString * _Nullable)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer));
- (NSString *)description __attribute__((swift_name("description()")));
@property (readonly) NSString * _Nullable message __attribute__((swift_name("message")));
@end

@protocol PlayCenterLoginListener
@required
- (void)onLoginSuccess:(BOOL)success id:(NSString * _Nullable)id token:(NSString * _Nullable)token error:(PlayCenterError * _Nullable)error __attribute__((swift_name("onLogin(success:id:token:error:)")));
@end

@protocol PlayCenterLogoutListener
@required
- (void)onLogoutSuccess:(BOOL)success __attribute__((swift_name("onLogout(success:)")));
@end

@protocol PlayCenterPayOrderListener
@required
- (BOOL)onPaymentReadySuccess:(BOOL)success url:(NSString * _Nullable)url orderId:(NSString * _Nullable)orderId error:(PlayCenterError * _Nullable)error __attribute__((swift_name("onPaymentReady(success:url:orderId:error:)")));
@end

@protocol PlayCenterQueryGatewayListener
@required
- (void)onCompletedSuccess:(BOOL)success gateways:(NSArray<Gateway *> * _Nullable)gateways error:(PlayCenterError * _Nullable)error __attribute__((swift_name("onCompleted(success:gateways:error:)")));
@end

__attribute__((objc_subclassing_restricted))
@interface PlayCenterServices : KotlinEnum<PlayCenterServices *>
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
@property (class, readonly) PlayCenterServices *news __attribute__((swift_name("news")));
@property (class, readonly) PlayCenterServices *web __attribute__((swift_name("web")));
@property (class, readonly) PlayCenterServices *cs __attribute__((swift_name("cs")));
+ (KotlinArray<PlayCenterServices *> *)values __attribute__((swift_name("values()")));
@property (class, readonly) NSArray<PlayCenterServices *> *entries __attribute__((swift_name("entries")));
@property (readonly) NSString *value __attribute__((swift_name("value")));
@end

#pragma pop_macro("_Nullable_result")
#pragma clang diagnostic pop
NS_ASSUME_NONNULL_END
