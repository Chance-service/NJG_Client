
#import <Foundation/Foundation.h>

@interface SvUDIDTools : NSObject


/*
 * @brief obtain Unique Device Identity
 */
+ (NSString*)UDID;
+ (void)setKeyChainUDIDGroup:(NSString*)keyChainUDIDAccessGroup;
+ (NSString*)IDFAWithKeychain;
+ (NSString*)getDeviceIdIDFAOrMAC;
+ (NSString*)getMacAddressOnly;
@end
