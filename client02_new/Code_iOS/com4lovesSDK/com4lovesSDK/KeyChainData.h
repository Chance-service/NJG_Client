
#import <Foundation/Foundation.h>

@interface KeyChainData : NSObject
/*
 KeyChainData 处理接口：
 GropItem：开发者对应的team + keychain sharing 配置的 grops name（以com.前缀），例如：AW66V9D6B6.com.jp.saka.fhr1
 KeyItem ：数据存储的key（自定义）
 */
+ (NSString*)getDataFromKeyChain:(NSString*)Keystr grop:(NSString*) Gropstr;
+ (BOOL)setDataToKeyChain:(NSString*)data Key:(NSString*)Keystr grop:(NSString*) Gropstr;

@end
