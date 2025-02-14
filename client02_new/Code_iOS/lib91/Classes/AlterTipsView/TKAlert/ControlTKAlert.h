//
//  ControlTKAlert.h
//  testAlertShow
//
//  Created by fanlees on 11-12-12.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "TKAlertCenter.h"

@interface ControlTKAlert : TKAlertCenter

+ (ControlTKAlert*) defaultCenter;

- (void)openAlertViewWithMessage:(NSString *)message
                      duringtime:(double)howManry;

- (void)stopAlertView;

- (void)animationStep2;

- (void)animationStep3;

- (void) showAlerts;

@end
