//
//  RyukPlatformListener.m
//  Game
//
//  Created by 黄可 on 16/5/23.
//
//

#import "RyukPlatformListener.h"
//#import "Google/Analytics.h"

std::string RyukPlatformListener::onReceiveCommonMessage(const std::string& tag,const std::string& msg)
{
   /* if ([[NSString stringWithUTF8String:tag.c_str()] isEqualToString:@"G2P_ENTER_RECHARGE_PAGE"]) {
        // May return nil if a tracker has not already been initialized with a property
        // ID.
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Event"     // Event category (required)
                                                              action:@"Action"  // Event action (required)
                                                               label:[NSString stringWithUTF8String:msg.c_str()]         // Event label
                                                               value:nil] build]];    // Event value
    }
    else if ([[NSString stringWithUTF8String:tag.c_str()] isEqualToString:@"G2P_ENTER_MAINSCENE_PAGE"]) {
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Event"     // Event category (required)
                                                              action:@"Action"  // Event action (required)
                                                               label:[NSString stringWithUTF8String:msg.c_str()]         // Event label
                                                               value:nil] build]];    // Event value
    }
    else if([[NSString stringWithUTF8String:tag.c_str()] isEqualToString:@"G2P_TOUCHRECHARGE"]) {
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Event"     // Event category (required)
                                                              action:@"Action"  // Event action (required)
                                                               label:[NSString stringWithUTF8String:msg.c_str()]         // Event label
                                                               value:nil] build]];    // Event value
        
    }*/
    return "";

}
