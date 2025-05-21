//
//  Hyena.h
//  analytics-sdk-ios-framework
//
//  Created by gary_lai on 2022/3/31.
//

#import "Tracker.h"
#import "AnalyticsBuilder.h"


@interface Hyena : NSObject


+ (BOOL) appStart :(NSString *) appKey ;


+ (BOOL) login:(NSString *)userId and:(NSString *)platformUserId ;


+ (BOOL) logout ;


+ (BOOL) charge:(NSString *)orderId and:(NSString *)currencyCode and:(NSNumber *)amount and:(NSString *)product;


+ (void) setAdvertiserIDCollectionEnabled :(BOOL) result ;

+ (Tracker *) getTracker ;

@end


#if __cplusplus
extern "C" {
#endif
    bool appStart(const char* appKey);
    bool login(const char* userId, const char* platformUserId) ;
    bool logout(void) ;
    bool charge(const char* orderId, const char* currencyCode, int amount,const char* product) ;
    void setAdvertiserIDCollectionEnabled (bool result) ;
    Tracker* getTracker(void) ;

#if __cplusplus
}   // Extern C
#endif
    
    

