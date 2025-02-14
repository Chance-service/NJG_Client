#import "KeyChainData.h"
#import <Security/Security.h>


/*
 KeyChainData 处理接口：
 GropItem：开发者对应的team + keychain sharing 配置的 grops name（以com.前缀），例如：AW66V9D6B6.com.jp.saka.fhr1
 KeyItem ：数据存储的key（自定义）
 */
@implementation KeyChainData

#pragma mark -
#pragma mark Helper Method for make identityForVendor consistency

+ (NSString*)getDataFromKeyChain:(NSString*)KeyItem grop:(NSString*) GropItem;
{
    NSMutableDictionary *dictForQuery = [[NSMutableDictionary alloc] init];
    [dictForQuery setValue:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    
    // set Attr Description for query
    [dictForQuery setValue:KeyItem forKey:kSecAttrDescription];
    
    // set Attr Identity for query
    NSData *keychainItemID = [KeyItem dataUsingEncoding:NSUTF8StringEncoding];
    [dictForQuery setObject:keychainItemID forKey:(id)kSecAttrGeneric];
    
    // The keychain access group attribute determines if this item can be shared
    // amongst multiple apps whose code signing entitlements contain the same keychain access group.
    if (GropItem != nil)
    {
        [dictForQuery setObject:GropItem forKey:(id)kSecAttrAccessGroup];
    }
    
    [dictForQuery setValue:(id)kCFBooleanTrue forKey:(id)kSecMatchCaseInsensitive];
    [dictForQuery setValue:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    [dictForQuery setValue:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    
    OSStatus queryErr   = noErr;
    NSData   *udidValue = nil;
    NSString *udid      = nil;
    
    queryErr = SecItemCopyMatching((CFDictionaryRef)dictForQuery, (CFTypeRef*)&udidValue);
    
    NSMutableDictionary *dict = nil;
    [dictForQuery setValue:(id)kCFBooleanTrue forKey:(id)kSecReturnAttributes];
    queryErr = SecItemCopyMatching((CFDictionaryRef)dictForQuery, (CFTypeRef*)&dict);
    
    if (queryErr == errSecItemNotFound) {
        NSLog(@"my KeyChainData Item: %@ not found!!!", KeyItem);
    }
    else if (queryErr != errSecSuccess) {
        NSLog(@"my KeyChainData Item query Error!!! Error code:%ld", queryErr);
    }
    if (queryErr == errSecSuccess) {
        NSLog(@"my KeyChainData Item: %@", udidValue);
        
        if (udidValue) {
            udid = [NSString stringWithUTF8String:udidValue.bytes];
        }
    }
    
    [dictForQuery release];
    return udid;
}

+ (BOOL)setDataToKeyChain:(NSString*)data Key:(NSString*)Keystr grop:(NSString*) Gropstr;
{
    NSMutableDictionary *dictForAdd = [[NSMutableDictionary alloc] init];
    
    [dictForAdd setValue:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    [dictForAdd setValue:Keystr forKey:kSecAttrDescription];
    
    [dictForAdd setValue:Keystr forKey:(id)kSecAttrGeneric];
    
    // Default attributes for keychain item.
    [dictForAdd setObject:@"" forKey:(id)kSecAttrAccount];
    [dictForAdd setObject:@"" forKey:(id)kSecAttrLabel];
    
    
    // The keychain access group attribute determines if this item can be shared
    // amongst multiple apps whose code signing entitlements contain the same keychain access group.
    if (Gropstr != nil)
    {
        [dictForAdd setObject:Gropstr forKey:(id)kSecAttrAccessGroup];
    }
    
    NSData *keyChainItemValue = [data dataUsingEncoding:NSUTF8StringEncoding];
    [dictForAdd setValue:keyChainItemValue forKey:(id)kSecValueData];
    
    OSStatus writeErr = noErr;
    if ([KeyChainData getDataFromKeyChain:Keystr grop:Gropstr]) {        // there is item in keychain
        [KeyChainData updateUDIDInKeyChain:data KeyItem:Keystr grop:Gropstr];
        [dictForAdd release];
        return YES;
    }
    else {          // add item to keychain
        writeErr = SecItemAdd((CFDictionaryRef)dictForAdd, NULL);
        if (writeErr != errSecSuccess) {
            NSLog(@"Add my KeyChainData Item Error!!! Error Code:%ld", writeErr);
            
            [dictForAdd release];
            return NO;
        }
        else {
            NSLog(@"Add my KeyChainData Item Success!!!");
            [dictForAdd release];
            return YES;
        }
    }
    
    [dictForAdd release];
    return NO;
}

+ (BOOL)removeUDIDFromKeyChain
{
    /*NSMutableDictionary *dictToDelete = [[NSMutableDictionary alloc] init];
     
     [dictToDelete setValue:(id)kSecClassGenericPassword forKey:(id)kSecClass];
     
     NSData *keyChainItemID = [NSData dataWithBytes:kKeychainUDIDItemIdentifier length:strlen(kKeychainUDIDItemIdentifier)];
     [dictToDelete setValue:keyChainItemID forKey:(id)kSecAttrGeneric];
     
     OSStatus deleteErr = noErr;
     deleteErr = SecItemDelete((CFDictionaryRef)dictToDelete);
     if (deleteErr != errSecSuccess) {
     NSLog(@"delete UUID from KeyChain Error!!! Error code:%d", (int)deleteErr);
     [dictToDelete release];
     return NO;
     }
     else {
     NSLog(@"delete success!!!");
     }
     
     [dictToDelete release];*/
    return YES;
}

+ (BOOL)updateUDIDInKeyChain:(NSString*)newUDID KeyItem:(NSString*)Keystr grop:(NSString*) Gropstr;
{
    
    NSMutableDictionary *dictForQuery = [[NSMutableDictionary alloc] init];
    
    [dictForQuery setValue:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    
    NSData *keychainItemID = [Keystr dataUsingEncoding:NSUTF8StringEncoding];
    [dictForQuery setValue:keychainItemID forKey:(id)kSecAttrGeneric];
    [dictForQuery setValue:(id)kCFBooleanTrue forKey:(id)kSecMatchCaseInsensitive];
    [dictForQuery setValue:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    [dictForQuery setValue:(id)kCFBooleanTrue forKey:(id)kSecReturnAttributes];
    
    NSDictionary *queryResult = nil;
    SecItemCopyMatching((CFDictionaryRef)dictForQuery, (CFTypeRef*)&queryResult);
    if (queryResult) {
        
        NSMutableDictionary *dictForUpdate = [[NSMutableDictionary alloc] init];
        [dictForUpdate setValue:Keystr forKey:kSecAttrDescription];
        [dictForUpdate setValue:keychainItemID forKey:(id)kSecAttrGeneric];
        
        NSData *keyChainItemValue = [newUDID dataUsingEncoding:NSUTF8StringEncoding];;
        [dictForUpdate setValue:keyChainItemValue forKey:(id)kSecValueData];
        
        OSStatus updateErr = noErr;
        
        // First we need the attributes from the Keychain.
        NSMutableDictionary *updateItem = [NSMutableDictionary dictionaryWithDictionary:queryResult];
        
        // Second we need to add the appropriate search key/values.
        // set kSecClass is Very important
        [updateItem setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
        
        updateErr = SecItemUpdate((CFDictionaryRef)updateItem, (CFDictionaryRef)dictForUpdate);
        if (updateErr != errSecSuccess) {
            NSLog(@"Update my KeyChainData Item Error!!! Error Code:%ld", updateErr);
            
            [dictForQuery release];
            [dictForUpdate release];
            return NO;
        }
        else {
            NSLog(@"Update my KeyChainData Item Success!!!");
            [dictForQuery release];
            [dictForUpdate release];
            return YES;
        }
    }
    
    [dictForQuery release];
    return NO;
}
@end
