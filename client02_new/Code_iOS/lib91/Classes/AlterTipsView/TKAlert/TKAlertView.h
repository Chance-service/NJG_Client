//
//  TKAlertView.h
//  SinaMusic
//
//  Created by fanlees on 11-9-8.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TKAlertView : UIView {
	CGRect _messageRect;
	NSString *_text;
	UIImage *_image;
}

- (id) init;
- (void) setMessageText:(NSString*)str;
- (void) setImage:(UIImage*)image;

@end
